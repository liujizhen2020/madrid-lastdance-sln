package bussiness

import (
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/models"
	"mac-central-ctrl/mongoc"
	"math/rand"
	"strings"
	"sync"
	"time"
)

var (
	BIMESSAGE_SERVE        = &BIMessageServe{}
	im_mbase               = mongoc.NewMongoColl("imessage", 20*time.Second)
	indexOfPrimaryIMessage = 0
	indexLock              sync.Mutex
)

type BIMessageServe struct {
	imessage_cache []entities.IMessage
}

func init() {
	BIMESSAGE_SERVE.ReloadIMessageCache()
	BMACRO_SERVE.InitMacro()
	ticker := time.NewTicker(time.Second * 30)
	go func() {
		for range ticker.C {
			BIMESSAGE_SERVE.ReloadIMessageCache()
			fmt.Println("ReloadIMessageCache!")
		}
	}()
}

func (b *BIMessageServe) constructIMessage(item entities.IMessageContent) entities.IMessage {
	ret := entities.IMessage{Identifier: item.Identifier, Status: 1, TargetNum: 100000, MacroSwitch: 1000, Content: item, MessageInterval: 6, CreateAt: time.Now()}

	ret.MessageInterval = 0
	ret.CreateAt = time.Now()

	return ret
}

func (b *BIMessageServe) ReloadIMessageCache() {
	cached, err := b.loadIMessageFromMDB()
	if err == nil {
		b.imessage_cache = cached
	}
}

func (b *BIMessageServe) loadIMessageFromMDB() ([]entities.IMessage, error) {
	var im_list []entities.IMessage
	err := im_mbase.Find(bson.M{}, &im_list)
	return im_list, err
}

func (b *BIMessageServe) GetAllIMessage() ([]entities.IMessage, error) {
	if b.imessage_cache == nil || len(b.imessage_cache) == 0 {
		return nil, errors.New("No IMessage")
	}
	return b.imessage_cache, nil
}

// validate identifier
func (b *BIMessageServe) ValidateIdentifier(identifier string) bool {
	for _, im := range b.imessage_cache {
		if im.Identifier == identifier {
			return true
		}
	}
	return false
}

// pick a random IMessage
func (b *BIMessageServe) PrimaryIMessage() (entities.IMessage, error) {
	imessages, err := b.ActiveIMessage()
	if err != nil {
		return entities.IMessage{}, errors.New("No IMessage")
	}
	return imessages[rand.Intn(len(imessages))], nil
}

// pick an IMessage sequentially
func (b *BIMessageServe) PrimaryIMessageSequentially() (entities.IMessage, error) {
	imessages, err := b.ActiveIMessage()
	if err != nil {
		return entities.IMessage{}, errors.New("No IMessage")
	}
	imLen := len(imessages)
	indexLock.Lock()
	indexOfPrimaryIMessage = indexOfPrimaryIMessage % imLen
	message := imessages[indexOfPrimaryIMessage]
	indexOfPrimaryIMessage++
	indexLock.Unlock()

	return message, nil
}

func (b *BIMessageServe) ActiveIMessage() ([]entities.IMessage, error) {
	if b.imessage_cache == nil || len(b.imessage_cache) == 0 {
		return nil, errors.New("No IMessage")
	}
	var active_slice []entities.IMessage
	for _, item := range b.imessage_cache {
		if item.Status == 1 {
			active_slice = append(active_slice, item)
		}
	}
	if active_slice == nil || len(active_slice) == 0 {
		return nil, errors.New("No Active IMessage")
	}
	return active_slice, nil
}

func (b *BIMessageServe) FindByIdentifier(identifier string) (entities.IMessage, error) {
	if b.imessage_cache == nil || len(b.imessage_cache) == 0 {
		return entities.IMessage{}, errors.New("Not IMessage")
	}
	for _, item := range b.imessage_cache {
		if item.Identifier == identifier {
			return item, nil
		}
	}
	return entities.IMessage{}, errors.New("Not Matched")
}

func (b *BIMessageServe) IsAllIMessageDisabled() bool {
	_, err := b.ActiveIMessage()
	return err != nil
}

func (b *BIMessageServe) ReplaceSystemMacro(item entities.IMessageContent, identifier string) (entities.IMessageContent, error) {
	if item.Text != "" {
		if strings.Contains(item.Text, "{.MacroVal}") {
			macro_val, err := BMACRO_SERVE.GetMacroByIdentifier(identifier)
			if err == nil {
				item.Text = strings.Replace(item.Text, "{.MacroVal}", macro_val, -1)
			} else {
				return item, errors.New("宏替换失败,没有可替换的内容")
			}
		}
	}
	return item, nil
}

func (b *BIMessageServe) AddIMessage(sc entities.IMessageContent) error {
	im := b.constructIMessage(sc)
	err := im_mbase.PushOne(im)
	if err == nil {
		b.ReloadIMessageCache()
		return nil
	}
	return errors.New("新增IM数据库操作失败")
}

func (b *BIMessageServe) ModifyIMessage(sc entities.IMessageContent) error {
	err := im_mbase.UpdateOne(bson.M{"Identifier": sc.Identifier}, bson.M{"$set": bson.M{"Content": sc}})
	if err == nil {
		b.ReloadIMessageCache()
		return nil
	}
	return errors.New("修改IM数据库操作失败")
}

func (b *BIMessageServe) DeleteIMessage(identifier string) error {
	im_mbase.DeleteOne(bson.M{"Identifier": identifier})
	err := BPHONE_SERVE.Unregister(identifier)

	if err == nil {
		b.ReloadIMessageCache()
		return nil
	} else {
		return errors.New(fmt.Sprintf("删除 [%s] 附属表失败", identifier))
	}
}

func (b *BIMessageServe) SwitchIMessageStatus(identifier string) error {
	var im entities.IMessage
	err := im_mbase.FindOne(bson.M{"Identifier": identifier}, &im)
	if err != nil {
		return err
	}
	err = im_mbase.UpdateOne(bson.M{"Identifier": identifier}, bson.M{"$set": bson.M{"Status": 1 - im.Status}})
	if err == nil {
		b.ReloadIMessageCache()
		return nil
	}
	return errors.New("切换IM状态失败")
}

func (b *BIMessageServe) ModifyItemMeta(identifier string, field string, val int64) error {
	var im entities.IMessage
	err := im_mbase.FindOne(bson.M{"Identifier": identifier}, &im)
	if err != nil {
		return err
	}
	err = im_mbase.UpdateOne(bson.M{"Identifier": identifier}, bson.M{"$set": bson.M{field: val}})
	if err == nil {
		b.ReloadIMessageCache()
		return nil
	}
	return errors.New("修改IM元数据失败")
}

func (b *BIMessageServe) BuildIMessageIndexView() []entities.IMessageView {
	all_message, err := b.GetAllIMessage()
	var message_slice []entities.IMessageView
	for i, item := range all_message {
		item_content := item.Content
		if err != nil {
			fmt.Println("message unmarshal err:", err.Error())
			continue
		}
		item_content, _ = b.ReplaceSystemMacro(item_content, item.Identifier)
		item.Content = item_content
		status_alias := "关闭"
		if item.Status == 1 {
			status_alias = "开启"
		}

		// Analyse phone status by identifier
		p_free, _ := BPHONE_SERVE.SizeOfCollIndex(models.X_PhoneFree, item.Identifier)
		p_working, _ := BPHONE_SERVE.SizeOfCollIndex(models.X_PhoneWorking, item.Identifier)
		p_succ, _ := BPHONE_SERVE.SizeOfCollIndex(models.X_PhoneSent, item.Identifier)
		phoneStatus := entities.PhoneStatus{
			Free:    p_free,
			Working: p_working,
			Succ:    p_succ,
		}

		wrapper := entities.IMessageView{
			Index:       (i + 1),
			IMessage:    item,
			PhoneStatus: phoneStatus,
			StatusAlias: status_alias,
		}
		message_slice = append(message_slice, wrapper)
	}
	return message_slice
}
