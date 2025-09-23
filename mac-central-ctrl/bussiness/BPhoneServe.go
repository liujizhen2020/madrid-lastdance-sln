package bussiness

import (
	"encoding/csv"
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/x/bsonx"
	"mac-central-ctrl/common"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/models"
	"mac-central-ctrl/mongoc"
	"mime/multipart"
	"strings"
	"time"
)

var (
	BPHONE_SERVE = &BPhoneServe{
		PortableTemplate: PortableTemplate{Impl: &BPhonePortableImpl{}},
	}

	p0_mbases   = make(map[string]*mongoc.MongoColl)
	p1_mbases   = make(map[string]*mongoc.MongoColl)
	p100_mbases = make(map[string]*mongoc.MongoColl)
)

type BPhoneServe struct {
	PortableTemplate
}

const (
	pType_0 = iota
	pType_1
	pType_100
)

//get mongo coll by identifier and type
func getColl(identifier string, pType int) *mongoc.MongoColl {
	var coll *mongoc.MongoColl
	switch pType {
	case pType_0:
		if _, ok := p0_mbases[identifier]; !ok {
			mongoColl := mongoc.NewMongoColl(fmt.Sprintf("phone_0_%s", identifier), 20*time.Second)
			_ = mongoColl.CreateIndex(mongo.IndexModel{
				Keys:    bsonx.Doc{{"Number", bsonx.Int32(1)}},
				Options: options.Index().SetUnique(true),
			})
			p0_mbases[identifier] = mongoColl
		}
		coll = p0_mbases[identifier]

	case pType_1:
		if _, ok := p1_mbases[identifier]; !ok {
			mongoColl := mongoc.NewMongoColl(fmt.Sprintf("phone_1_%s", identifier), 20*time.Second)
			_ = mongoColl.CreateIndex(mongo.IndexModel{
				Keys:    bsonx.Doc{{"Number", bsonx.Int32(1)}},
				Options: options.Index().SetUnique(true),
			})
			p1_mbases[identifier] = mongoColl
		}
		coll = p1_mbases[identifier]
	case pType_100:
		if _, ok := p100_mbases[identifier]; !ok {
			mongoColl := mongoc.NewMongoColl(fmt.Sprintf("phone_100_%s", identifier), 20*time.Second)
			_ = mongoColl.CreateIndex(mongo.IndexModel{
				Keys:    bsonx.Doc{{"Number", bsonx.Int32(1)}},
				Options: options.Index().SetUnique(true),
			})
			p100_mbases[identifier] = mongoColl
		}
		coll = p100_mbases[identifier]
	}
	return coll
}

// clean phone_*_* collection
func (*BPhoneServe) Unregister(identifier string) error {
	coll0 := getColl(identifier, pType_0)
	err := coll0.Destory()
	if err != nil {
		return err
	}
	coll1 := getColl(identifier, pType_1)
	err = coll1.Destory()
	if err != nil {
		return err
	}
	coll100 := getColl(identifier, pType_100)
	err = coll100.Destory()
	if err != nil {
		return err
	}
	return nil
}

func (b *BPhoneServe) ImportFromCSV(file multipart.File, identifier string) int64 {
	return b.LineImport(getColl(identifier, pType_0), file)
}

type BPhonePortableImpl struct {
}

func (b *BPhonePortableImpl) ImportParse(line string) (interface{}, error) {
	fmt_line := line
	if strings.Contains(fmt_line, "@") || strings.HasPrefix(fmt_line, "+") {
	} else if strings.HasPrefix(fmt_line, "86") {
		fmt_line = fmt.Sprint("+", fmt_line)
	} else {
		fmt_line = fmt.Sprint("+86", fmt_line)
	}
	return entities.Phone{Number: fmt_line, CreateAt: time.Now(), DispNum: 0}, nil
}

func (p *BPhonePortableImpl) ExportWrite(writer *csv.Writer, entity interface{}) error {
	phone := entity.(entities.Phone)
	err := writer.Write([]string{phone.Number})
	return err
}

func (b *BPhoneServe) Export(writer *csv.Writer, identifier string, status int) {
	var phoneSlicePtr []entities.Phone
	coll, _ := b.getMCollByIndex(int64(status), identifier)
	b.LineExport(coll, writer, bson.M{}, &phoneSlicePtr)
}

func (s *BPhoneServe) getMCollByIndex(status int64, identifier string) (*mongoc.MongoColl, error) {
	switch status {
	case models.X_PhoneFree:
		return getColl(identifier, pType_0), nil
	case models.X_PhoneWorking:
		return getColl(identifier, pType_1), nil
	case models.X_PhoneSent:
		return getColl(identifier, pType_100), nil
	}
	return nil, errors.New("Not Collection Matched")
}

func (s *BPhoneServe) SizeOfCollIndex(collIndex int64, identifier string) (int64, error) {
	coll, err := s.getMCollByIndex(collIndex, identifier)
	if err != nil {
		return 0, err
	}
	return coll.EstimatedSize()
}

func (b *BPhoneServe) Truncate(identifier string) error {
	_, err := getColl(identifier, pType_0).DeleteMany(bson.M{})
	_, err = getColl(identifier, pType_1).DeleteMany(bson.M{})
	return err
}

func (b *BPhoneServe) HandlerSuccess(identifier string, fmt_succ_pn []string) (int64, error) {
	var err error
	inc_result := int64(0)
	for _, fmt_succ := range fmt_succ_pn {
		var phone entities.Phone
		err = getColl(identifier, pType_1).PopOne(bson.M{"Number": fmt_succ}, &phone)
		if err != nil {
			continue
		}
		phone.CreateAt = time.Now()
		err = getColl(identifier, pType_100).PushOne(phone)
		if err != nil {
			continue
		}
		inc_result++
	}
	if err != nil {
		return inc_result, err
	}
	return inc_result, nil
}

func (b *BPhoneServe) PopPhone(need int64, identifier string) ([]entities.Phone, error) {
	var phone_list []entities.Phone
	for i := int64(0); i < need; i++ {
		var phone entities.Phone
		_id, err := primitive.ObjectIDFromHex("000000000000000000000000")
		if err != nil {
			return nil, errors.New("Hex Id error")
		}
		err = getColl(identifier, pType_0).PopOne(bson.M{"_id": bson.M{"$gt": _id}}, &phone)
		if err == nil {
			phone.CreateAt = time.Now()
			phone.DispNum = phone.DispNum + 1
			getColl(identifier, pType_1).PushOne(phone)
			phone_list = append(phone_list, phone)
		}
	}
	if phone_list == nil || len(phone_list) == 0 {
		return nil, errors.New("无可用的手机号")
	}
	return phone_list, nil
}

func (b *BPhoneServe) ExtractPhoneNumber(params ...entities.Phone) ([]string, error) {
	var phone_list []string
	for _, param := range params {
		phone_list = append(phone_list, param.Number)
	}
	if phone_list == nil || len(phone_list) == 0 {
		return nil, errors.New("提取空数组")
	}
	return phone_list, nil
}

func (b *BPhoneServe) RepushWhileError(identifier string, params ...entities.Phone) {
	for _, param := range params {
		var phone entities.Phone
		err := getColl(identifier, pType_1).PopOne(bson.M{"Number": param.Number}, &phone)
		if err == nil {
			phone.CreateAt = time.Now()
			phone.DispNum = phone.DispNum - 1
			getColl(identifier, pType_0).PushOne(phone)
		}
	}
}

func (b *BPhoneServe) RecyleForFailed() (int64, error) {
	max_recyclenum := models.METACACHE_MODEL.QueryMETAInteger(models.RECYCLE_NUM_PHONE, 3)
	recycle_interval := models.METACACHE_MODEL.QueryMETAInteger(models.PHONE_RECYCLE_INTERVAL, 6)
	recyle_before := common.TimeForOffset(fmt.Sprintf("-%dm", recycle_interval))

	// process all collections sequentially
	count := int64(0)
	i := int64(0)
	for _, im := range BIMESSAGE_SERVE.imessage_cache {
		i = int64(0)
		for ; i < 10000; i++ {
			var phone entities.Phone
			err := getColl(im.Identifier, pType_1).PopOne(bson.M{"CreateAt": bson.M{"$lte": recyle_before}, "DispNum": bson.M{"$lte": max_recyclenum}}, &phone)
			if err != nil {
				break
			}
			phone.CreateAt = time.Now()
			getColl(im.Identifier, pType_0).PushOne(phone)

			count++
		}
	}

	return count, nil
}
