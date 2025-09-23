package bussiness

import (
	"encoding/csv"
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"mac-central-ctrl/common"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/models"
	"mac-central-ctrl/mongoc"
	"mime/multipart"
	"strings"
	"time"
)

var (
	BAPPLEID_SERVE = &BAppleIdServe{
		PortableTemplate: PortableTemplate{Impl: &BAppleIdPortableImpl{}},
	}
	a0_mbase   = mongoc.NewMongoColl("appleid_0", 20*time.Second)
	a1_mbase   = mongoc.NewMongoColl("appleid_1", 20*time.Second)
	a100_mbase = mongoc.NewMongoColl("appleid_100", 20*time.Second)
	an1_mbase  = mongoc.NewMongoColl("appleid_n1", 20*time.Second)

	atrailer_mbase = mongoc.NewMongoColl("appleid_trailer", 20*time.Second)

	at_mbase = mongoc.NewMongoFIFOColl("appleid_tag", 20*time.Second, 100)
)

type BAppleIdServe struct {
	CurrentServedTag string
	PortableTemplate
}

type BAppleIdPortableImpl struct {
}

func (b *BAppleIdServe) ImportTag(tag string, interval int64) error {
	poped := entities.AppleIdTag{}
	tagItem := entities.AppleIdTag{Tag: tag, DispatchInterval: interval, CreateAt: time.Now(), CreateAtStr: common.NowTimeStr()}
	return at_mbase.FIFOPushOne(tagItem, &poped)
}

func (b *BAppleIdServe) SaveTagNum(tag string, num int64) error {
	return at_mbase.UpdateOne(bson.M{"Tag": tag}, bson.M{"$set": bson.M{"Num": num}})
}

func (b *BAppleIdServe) IncBindingNum(tag string) error {
	return at_mbase.UpdateOne(bson.M{"Tag": tag}, bson.M{"$inc": bson.M{"BindingNum": 1}})
}

func (b *BAppleIdServe) ImportFromCSV(file multipart.File) int64 {
	return b.LineImport(a0_mbase, file)
}

func (b *BAppleIdPortableImpl) ImportParse(line string) (interface{}, error) {
	ep := strings.Split(line, ",")
	if len(ep) != 3 && len(ep) != 2 {
		return entities.AppleId{}, errors.New("Field Not Full")
	}
	if len(ep) == 2 {
		return entities.AppleId{Email: ep[0], Password: ep[1], Tag: BAPPLEID_SERVE.CurrentServedTag}, nil
	}
	return entities.AppleId{Email: ep[0], Password: ep[1], Tag: BAPPLEID_SERVE.CurrentServedTag, PID: ep[2], DispNum: 0, CreateAt: time.Now()}, nil
}

func (p *BAppleIdPortableImpl) ExportWrite(writer *csv.Writer, entity interface{}) error {
	appleId := entity.(entities.AppleId)
	if appleId.PID == "" {
		err := writer.Write([]string{appleId.Email, appleId.Password})
		return err
	} else {
		err := writer.Write([]string{appleId.Email, appleId.Password, appleId.PID})
		return err
	}
}

func (s *BAppleIdServe) FetchAppleId(sn string) (entities.AppleId, error) {
	BMACCODE_SERVE.CodeToIMReg(sn)
	ac := entities.AppleId{}
	if models.METACACHE_MODEL.IsTrailerOn() {
		err := atrailer_mbase.PopOne(bson.M{"TrailerLine": bson.M{"$lt": time.Now()}}, &ac)
		if err == nil {
			return ac, nil
		}
	}
	err := a0_mbase.PopOne(bson.M{}, &ac)
	if err != nil {
		return ac, errors.New("ID缓存队列已空...")
	}
	ac.CreateAt = time.Now()
	ac.DispNum = ac.DispNum + 1
	a1_mbase.PushOne(ac)
	return ac, nil
}

func (s *BAppleIdServe) NoBarrier() (bool, error) {
	es, err := a0_mbase.EstimatedSize()
	return es > 0, err
}

func (s *BAppleIdServe) Export(writer *csv.Writer, status int64) {
	var slicePtr []entities.AppleId
	coll, err := s.getMCollByIndex(status)
	if err != nil {
		return
	}
	s.LineExport(coll, writer, bson.M{}, &slicePtr)
}

func (s *BAppleIdServe) getMCollByIndex(status int64) (*mongoc.MongoColl, error) {
	switch status {
	case models.X_AccountFree:
		return a0_mbase, nil
	case models.X_AccountLogin:
		return a1_mbase, nil
	case models.X_IMReady:
		return a100_mbase, nil
	case models.X_AccountFatal:
		return an1_mbase, nil
	}
	return nil, errors.New("Not Collection Matched")

}

func (s *BAppleIdServe) Truncate(collIndexs ...int64) error {
	for _, collIdx := range collIndexs {
		mcoll, err := s.getMCollByIndex(collIdx)
		if err != nil {
			continue
		}
		mcoll.DeleteMany(bson.M{})
	}
	return nil
}

func (s *BAppleIdServe) SizeOfCollIndex(collIndex int64) (int64, error) {
	mcoll, err := s.getMCollByIndex(collIndex)
	if err != nil {
		return 0, err
	}
	return mcoll.EstimatedSize()
}

func (s *BAppleIdServe) DisabledStatus(email string) error {
	appleId := entities.AppleId{}
	err := a1_mbase.PopOne(bson.M{"Email": email}, &appleId)
	if err != nil {
		return err
	}
	an1_mbase.PushOne(appleId)
	return nil
}

func (s *BAppleIdServe) AppleIdBindSucc(email string) entities.AppleId {
	acc := entities.AppleId{}
	err := a1_mbase.PopOne(bson.M{"Email": email}, &acc)
	if err != nil {
		err := a100_mbase.FindOne(bson.M{"Email": email}, &acc)
		if err != nil {
			return entities.AppleId{Email: email}
		}
		return acc
	}
	s.IncBindingNum(acc.Tag)
	acc.CreateAt = time.Now()
	a100_mbase.PushOne(acc)
	if !models.METACACHE_MODEL.IsTrailerOn() {
		return acc
	}
	trailer_num := models.METACACHE_MODEL.QueryMETAInteger(models.TRAILER_NUM_APPLEID, 3)
	for i := int64(0); i < trailer_num-1; i++ {
		d := i * 3
		dur := common.TimeForOffset(fmt.Sprintf("%dm", d))
		acc.TrailerLine = dur
		atrailer_mbase.PushOne(acc)
	}
	return acc
}

func (s *BAppleIdServe) FindByEmail(email string) (entities.AppleId, error) {
	id := entities.AppleId{}
	err := a100_mbase.FindOne(bson.M{"Email": email}, &id)
	if err == nil {
		return id, nil
	}
	err = a1_mbase.FindOne(bson.M{"Email": email}, &id)
	if err == nil {
		return id, nil
	}
	err = a0_mbase.FindOne(bson.M{"Email": email}, &id)
	if err == nil {
		return id, nil
	}
	return id, fmt.Errorf("not found")
}

func (s *BAppleIdServe) RecyleForFailed() (int64, error) {
	recycle_interval := models.METACACHE_MODEL.QueryMETAInteger(models.APPLEID_RECYCLE_INTERVAL, 6)
	recyle_before := timeForOffset(fmt.Sprintf("-%dm", recycle_interval))
	max_recyclenum := models.METACACHE_MODEL.QueryMETAInteger(models.RECYCLE_NUM_APPLEID, 6)
	var appleid entities.AppleId
	return s.CollectionPorter(a1_mbase, a0_mbase, bson.M{"CreateAt": bson.M{"$lte": recyle_before}, "DispNum": bson.M{"$lt": max_recyclenum}}, &appleid, "Email", "")
}

type aggreGroup struct {
	AppleIdTag string `json:"AppleIdTag" bson:"AppleIdTag"`
	Status     int64  `json:"Status" bson:"Status"`
}

type tagAggre struct {
	Id aggreGroup `json:"Id" bson:"_id"`
	N  int64      `json:"N" bson:"N"`
}

func (s *BAppleIdServe) AggregateForColl(coll *mongoc.MongoColl) ([]tagAggre, error) {
	tagAggreList := []tagAggre{}
	err := coll.Aggregate(bson.A{
		bson.D{
			{Key: "$group",
				Value: bson.D{
					{Key: "_id", Value: bson.D{
						{Key: "AppleIdTag", Value: "$AppleIdTag"},
						{Key: "Status", Value: "$Status"},
					},
					},
					{Key: "N", Value: bson.D{
						{Key: "$sum", Value: 1},
					},
					},
				},
			},
		},
	}, &tagAggreList)
	return tagAggreList, err
}

func (s *BAppleIdServe) ListTag() ([]entities.AppleIdTag, error) {
	tagList := []entities.AppleIdTag{}
	err := at_mbase.Find(bson.M{}, &tagList, &options.FindOptions{Sort: bson.M{"CreateAt": -1}})
	if err != nil {
		return nil, err
	}
	tagAgg, err := s.AggregateForColl(cert_mbase)
	if err != nil {
		return tagList, err
	}
	tList := []entities.AppleIdTag{}
	for _, item := range tagList {
		readyCert, workingCert, workedCert := int64(0), int64(0), int64(0)
		for _, ag := range tagAgg {
			if item.Tag != ag.Id.AppleIdTag {
				continue
			}
			switch ag.Id.Status {
			case models.S_CertReady:
				readyCert = ag.N
			case models.S_CertWorking:
				workingCert = ag.N
			case models.S_CertWorked:
				workedCert = ag.N
			}
		}
		item.ReadyNum = readyCert
		item.CertNum = readyCert + workingCert + workedCert
		tList = append(tList, item)
	}
	return tList, nil
}

func (s *BAppleIdServe) FindIntervalByTag(tag string) int64 {
	appleIdTag := entities.AppleIdTag{}
	err := at_mbase.FindOne(bson.M{"Tag": tag}, &appleIdTag)
	if err != nil {
		return models.METACACHE_MODEL.QueryMETAInteger(models.CK_DISPATCH_INTERVAL, 6)
	}
	return appleIdTag.DispatchInterval
}

func (s *BAppleIdServe) TagIntervalByEmail(email string) (string, int64) {
	appleId := entities.AppleId{}
	err := a1_mbase.FindOne(bson.M{"Email": email}, &appleId)
	if err == nil {
		return appleId.Tag, s.FindIntervalByTag(appleId.Tag)
	}
	err = a100_mbase.FindOne(bson.M{"Email": email}, &appleId)
	if err == nil {
		return appleId.Tag, s.FindIntervalByTag(appleId.Tag)
	}
	return "", models.METACACHE_MODEL.QueryMETAInteger(models.CK_DISPATCH_INTERVAL, 6)
}

func (s *BAppleIdServe) SaveTagInterval(tag string, interval int64) error {
	err := at_mbase.UpdateOne(bson.M{"Tag": tag}, bson.M{"$set": bson.M{"DispatchInterval": interval}})
	if err != nil {
		return err
	}
	_, err = BCERT_SERVE.SyncTagInterval(tag, interval)
	return err
}

func (s *BAppleIdServe) InitTag() {
	at_mbase.DeleteMany(bson.M{})
	tf := common.TagSampleFmt()
	tag := fmt.Sprintf("init-%s", tf)

	inter := models.METACACHE_MODEL.QueryMETAInteger(models.CK_DISPATCH_INTERVAL, 6)
	at := entities.AppleIdTag{Tag: tag, DispatchInterval: inter, CreateAt: time.Now(), CreateAtStr: common.NowTimeStr()}
	at_mbase.PushOne(at)

	n1, _ := a0_mbase.UpdateMany(bson.M{}, bson.M{"$set": bson.M{"Tag": tag}})
	n2, _ := a1_mbase.UpdateMany(bson.M{}, bson.M{"$set": bson.M{"Tag": tag}})
	n3, _ := a100_mbase.UpdateMany(bson.M{}, bson.M{"$set": bson.M{"Tag": tag}})

	s.SaveTagNum(tag, n1+n2+n3)
	certList := []entities.IMCert{}
	cert_mbase.Find(bson.M{}, &certList)
	for _, cert := range certList {
		bindTime := cert.IMRegTime
		dur := fmt.Sprintf("%dh", inter)
		ctrlTime := common.TimeForBasedOffset(bindTime, dur)
		cert_mbase.UpdateMany(bson.M{"DeviceBasic.SN": cert.DeviceBasic.SN}, bson.M{"$set": bson.M{"CtrlTime": ctrlTime, "AppleIdTag": tag}})
	}
}

func (s *BAppleIdServe) TagDel(tag string) error {
	err := at_mbase.DeleteOne(bson.M{"Tag": tag})
	return err
}
