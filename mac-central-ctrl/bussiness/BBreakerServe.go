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
	SecType_Safty_Questions = "SecType_Safty_Questions"
	SecType_Two_Factor      = "SecType_Two_Factor"

	BBREAKER_SERVE = &BBreakerServe{
		PortableTemplate: PortableTemplate{Impl: &BBreakerPortableImpl{}},
	}
	br0_mbase   = mongoc.NewMongoColl("breaker_0", 20*time.Second)
	br1_mbase   = mongoc.NewMongoColl("breaker_1", 20*time.Second)
	br100_mbase = mongoc.NewMongoColl("breaker_100", 20*time.Second)
	brng_mbase  = mongoc.NewMongoColl("breaker_ng", 20*time.Second)
)

type BBreakerServe struct {
	CurrentServedSecType string
	PortableTemplate
}

type BBreakerPortableImpl struct {
}

func (b *BBreakerServe) ImportFromCSV(file multipart.File) int64 {
	return b.LineImport(br0_mbase, file)
}

func (b *BBreakerPortableImpl) ImportParse(line string) (interface{}, error) {
	dType := BBREAKER_SERVE.CurrentServedSecType
	if dType == SecType_Two_Factor {
		if len(ep) == 3 {
			return entities.AppleId{Email: ep[0], Password: ep[1], SecAPI: ep[2], SecType: dType, DispNum: 0, CreateAt: time.Now()}, nil
		}
	}
	if dType == SecType_Safty_Questions {
		if len(ep) == 8 {
			return entities.AppleId{Email: ep[0], Password: ep[1], SecQuestion1: ep[2], SecAnswer1: ep[3], SecQuestion2: ep[4], SecAnswer2: ep[5], SecQuestion3: ep[6], SecAnswer3: ep[7], SecType: dType, DispNum: 0, CreateAt: time.Now()}, nil
		}
	}
	return entities.AppleId{}, errors.New("Field len exception")
}

func (p *BBreakerPortableImpl) ExportWrite(writer *csv.Writer, entity interface{}) error {
	appleId := entity.(entities.AppleId)
	if appleId.PID == "" {
		err := writer.Write([]string{appleId.Email, appleId.Password})
		return err
	} else {
		err := writer.Write([]string{appleId.Email, appleId.Password, appleId.PID})
		return err
	}
}

func (s *BBreakerServe) FetchAppleId(sn string) (entities.AppleId, error) {
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

func (s *BBreakerServe) NoBarrier() (bool, error) {
	es, err := a0_mbase.EstimatedSize()
	return es > 0, err
}

func (s *BBreakerServe) Export(writer *csv.Writer, status int64) {
	var slicePtr []entities.AppleId
	coll, err := s.getMCollByIndex(status)
	if err != nil {
		return
	}
	s.LineExport(coll, writer, bson.M{}, &slicePtr)
}

func (s *BBreakerServe) getMCollByIndex(status int64) (*mongoc.MongoColl, error) {
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

func (s *BBreakerServe) Truncate(collIndexs ...int64) error {
	for _, collIdx := range collIndexs {
		mcoll, err := s.getMCollByIndex(collIdx)
		if err != nil {
			continue
		}
		mcoll.DeleteMany(bson.M{})
	}
	return nil
}

func (s *BBreakerServe) SizeOfCollIndex(collIndex int64) (int64, error) {
	mcoll, err := s.getMCollByIndex(collIndex)
	if err != nil {
		return 0, err
	}
	return mcoll.EstimatedSize()
}

func (s *BBreakerServe) DisabledStatus(email string) error {
	appleId := entities.AppleId{}
	err := a1_mbase.PopOne(bson.M{"Email": email}, &appleId)
	if err != nil {
		return err
	}
	an1_mbase.PushOne(appleId)
	return nil
}

func (s *BBreakerServe) SuccBroken(email string) entities.AppleId {
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

func (s *BBreakerServe) FindByEmail(email string) (entities.AppleId, error) {
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

func (s *BBreakerServe) RecyleForFailed() (int64, error) {
	recycle_interval := models.METACACHE_MODEL.QueryMETAInteger(models.APPLEID_RECYCLE_INTERVAL, 6)
	recyle_before := timeForOffset(fmt.Sprintf("-%dm", recycle_interval))
	max_recyclenum := models.METACACHE_MODEL.QueryMETAInteger(models.RECYCLE_NUM_APPLEID, 6)
	var appleid entities.AppleId
	return s.CollectionPorter(a1_mbase, a0_mbase, bson.M{"CreateAt": bson.M{"$lte": recyle_before}, "DispNum": bson.M{"$lt": max_recyclenum}}, &appleid, "Email", "")
}
