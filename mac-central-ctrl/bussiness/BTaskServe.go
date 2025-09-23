package bussiness

import (
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/models"
	"strings"
	"time"
)

var (
	BTASK_SERVE = &BTaskServe{}
)

type TraceData struct {
	SuccPhone  []string  `json:"SuccPhone,omitempty" bson:"SuccPhone,omitempty"`
	Serial     string    `json:"Serial,omitempty" bson:"Serial,omitempty"`
	Identifier string    `json:"Identifier,omitempty" bson:"Identifier,omitempty"`
	CreateAt   time.Time `json:"CreateAt,omitempty" bson:"CreateAt,omitempty"`
}

type BTaskServe struct {
}

func (s *BTaskServe) WriteSuccessNum() {
	im_list, err := BIMESSAGE_SERVE.GetAllIMessage()
	if err != nil {
		fmt.Println("GetAllIMessage Error While WriteSuccessNum,err:", err.Error())
		return
	}
	for _, im := range im_list {
		succNum, _ := getColl(im.Identifier, pType_100).EstimatedSize()
		im_mbase.UpdateOne(bson.M{"Identifier": im.Identifier}, bson.M{"$set": bson.M{"SuccNum": succNum}})
	}
	BIMESSAGE_SERVE.ReloadIMessageCache()
}

func (s *BTaskServe) QueryIMessageTask(need int64, pool int64) (entities.BindingTask, error) {
	sp_task, err := s.specialTaskToSend(pool)
	if err == nil {
		return sp_task, nil
	}
	pri_task, err := s.primaryTaskToSent(need, pool)
	return pri_task, err
}

func (s *BTaskServe) buildTaskCtlInfo() entities.CtlInfo {
	sendInterval := models.METACACHE_MODEL.QueryMETAInteger(models.SEND_MSG_INTERVAL, 1)
	waitAfterSend := models.METACACHE_MODEL.QueryMETAInteger(models.SEND_WAIT_AFTERSEND, 90)
	failureStop := models.METACACHE_MODEL.QueryMETAInteger(models.SEND_FAILURE_STOP, 15)
	return entities.CtlInfo{SendInterval: sendInterval, WaitAfterSend: waitAfterSend, FailureStop: failureStop}
}

func (s *BTaskServe) specialTaskToSend(pool int64) (entities.BindingTask, error) {
	// traverse in order
	item, err := BIMESSAGE_SERVE.PrimaryIMessageSequentially()
	if err != nil {
		return entities.BindingTask{}, err
	}
	send_content, err := BIMESSAGE_SERVE.ReplaceSystemMacro(item.Content, item.Identifier)
	if err != nil {
		return entities.BindingTask{}, err
	}
	sp_tasks, err := BSPECIALSEND_SERVE.SpecialItems()
	if err != nil {
		return entities.BindingTask{}, err
	}
	ckList, err := BCERT_SERVE.CertToWork(pool)
	if err != nil {
		BSPECIALSEND_SERVE.RepushWhileError()
		return entities.BindingTask{}, err
	}
	ctlInfo := s.buildTaskCtlInfo()
	ctList := []entities.CertTarget{}
	tag := ""
	for _, item := range ckList {
		ct := entities.CertTarget{CertBox: item.Cert, PhoneNoList: sp_tasks}
		ctList = append(ctList, ct)
		tag = item.AppleIdTag
	}
	return entities.BindingTask{CtlInfo: ctlInfo, MsgInfo: send_content, CertTargetInfo: ctList, Tag: tag}, nil
}

func (s *BTaskServe) primaryTaskToSent(need int64, pool int64) (entities.BindingTask, error) {
	im, err := BIMESSAGE_SERVE.PrimaryIMessage()
	if err != nil {
		return entities.BindingTask{}, err
	}
	if !im.IsActive() {
		return entities.BindingTask{}, errors.New("关闭状态....")
	}
	if im.SuccNum >= im.TargetNum {
		return entities.BindingTask{}, errors.New("已达到发送目标量")
	}
	send_content, err := BIMESSAGE_SERVE.ReplaceSystemMacro(im.Content, im.Identifier)
	if err != nil {
		return entities.BindingTask{}, err
	}
	ckList, err := BCERT_SERVE.CertToWork(pool)
	if err != nil {
		return entities.BindingTask{}, err
	}
	phone_list, err := BPHONE_SERVE.PopPhone(need*int64(len(ckList)), im.Identifier)
	if err != nil {
		for _, item := range ckList {
			BCERT_SERVE.RepushWhileError(item)
		}
		return entities.BindingTask{}, errors.New("主任务没有手机号了")
	}
	number_list, err := BPHONE_SERVE.ExtractPhoneNumber(phone_list...)
	if err != nil {
		for _, item := range ckList {
			BCERT_SERVE.RepushWhileError(item)
		}
		return entities.BindingTask{}, errors.New("手机号提取失败...")
	}
	tag := ""
	ctList := []entities.CertTarget{}
	for idx, item := range ckList {
		tgs := number_list[int64(idx)*need : int64(idx+1)*need-1]
		ct := entities.CertTarget{CertBox: item.Cert, PhoneNoList: tgs}
		ctList = append(ctList, ct)
		tag = item.AppleIdTag
	}
	ctlInfo := s.buildTaskCtlInfo()
	return entities.BindingTask{CtlInfo: ctlInfo,
		MsgInfo:        send_content,
		CertTargetInfo: ctList,
		Tag:            tag}, nil

}

func (s *BTaskServe) SaveTaskStatus(imTaskResult entities.IMTaskResult) {
	var fmt_succ_pn []string
	succ_inc := int64(0)
	if imTaskResult.Success != nil && len(imTaskResult.Success) != 0 {
		for _, orig_phone := range imTaskResult.Success {
			fmt_phone := strings.TrimSpace(orig_phone)
			if fmt_phone == "" {
				continue
			}
			if !strings.HasPrefix(fmt_phone, "+") && !strings.Contains(fmt_phone, "@") {
				fmt_phone = fmt.Sprintf("+%s", fmt_phone)
			}
			fmt_succ_pn = append(fmt_succ_pn, fmt_phone)
		}
		succ_inc, _ = BPHONE_SERVE.HandlerSuccess(imTaskResult.Identifier, imTaskResult.Success)
		err := BLOG_SERVE.SettleLog(succ_inc)
		if err != nil {
			fmt.Println("settle err:", err.Error())
		}
	}
	_, err := BIMESSAGE_SERVE.FindByIdentifier(imTaskResult.Identifier)
	if err != nil {
		return
	}
	if imTaskResult.Serial == "" {
		fmt.Println("Serial Is Null,Cannnot Logging")
		return
	}
	BCERT_SERVE.CertWorked(imTaskResult.Serial, succ_inc)
}

func (s *BTaskServe) InitializeNewTask(identifier string) error {
	// init an IMessage by identifier
	_, err := getColl(identifier, pType_0).DeleteMany(bson.M{})
	if err != nil {
		return err
	}
	_, err = getColl(identifier, pType_1).DeleteMany(bson.M{})
	if err != nil {
		return err
	}
	_, err = getColl(identifier, pType_100).DeleteMany(bson.M{})
	if err != nil {
		return err
	}

	err = im_mbase.UpdateOne(bson.M{"Identifier": identifier}, bson.M{"$set": bson.M{"SuccNum": 0}})
	if err != nil {
		return err
	}

	BIMESSAGE_SERVE.ReloadIMessageCache()
	return nil
}
