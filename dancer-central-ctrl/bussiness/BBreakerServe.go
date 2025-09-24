package bussiness

import (
	"dancer-central-ctrl/common"
	"dancer-central-ctrl/entities"
	"dancer-central-ctrl/models"
	"dancer-central-ctrl/mongoc"
	"encoding/csv"
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
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
	if appleId.SecType == SecType_Safty_Questions {
		err = writer.Write([]string{appleId.Email, appleId.Password, appleId.SecQuestion1, appleId.SecAnswer1, appleId.SecQuestion2, appleId.SecAnswer2, appleId.SecQuestion3, appleId.SecAnswer3})
	} else if appleId.SecType == SecType_Two_Factor {
		err = writer.Write([]string{appleId.Email, appleId.Password, appleId.SecAPI})
	}
	return err
}

func (s *BBreakerServe) FetchBreaker() (entities.AppleId, error) {
	ac := entities.AppleId{}
	err := br0_mbase.PopOne(bson.M{}, &ac)
	if err != nil {
		return ac, errors.New("ID缓存队列已空...")
	}
	ac.CreateAt = time.Now()
	ac.DispNum = ac.DispNum + 1
	br1_mbase.PushOne(ac)
	return ac, nil
}

func (s *BBreakerServe) NoBarrier() (bool, error) {
	es, err := br0_mbase.EstimatedSize()
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
		return br0_mbase, nil
	case models.X_AccountLogin:
		return br1_mbase, nil
	case models.X_AccountReady:
		return br100_mbase, nil
	case models.X_AccountFatal:
		return brng_mbase, nil
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
	err := br1_mbase.PopOne(bson.M{"Email": email}, &appleId)
	if err != nil {
		return err
	}
	brng_mbase.PushOne(appleId)
	return nil
}

func (s *BBreakerServe) BrokenSucc(email string) error {
	acc := entities.AppleId{}
	err := br1_mbase.PopOne(bson.M{"Email": email}, &acc)
	if err != nil {
		return err
	}
	acc.CreateAt = time.Now()
	br100_mbase.PushOne(acc)
	return nil
}

func (s *BBreakerServe) RecyleForFailed() (int64, error) {
	recycle_interval := models.METACACHE_MODEL.QueryMETAInteger(models.APPLEID_RECYCLE_INTERVAL, 6)
	recyle_before := timeForOffset(fmt.Sprintf("-%dm", recycle_interval))
	max_recyclenum := models.METACACHE_MODEL.QueryMETAInteger(models.RECYCLE_NUM_APPLEID, 6)
	var appleid entities.AppleId
	return s.CollectionPorter(br1_mbase, br0_mbase, bson.M{"CreateAt": bson.M{"$lte": recyle_before}, "DispNum": bson.M{"$lt": max_recyclenum}}, &appleid, "Email", "")
}
