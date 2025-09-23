package models

import (
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/mongoc"
	"strconv"
	"time"
)

const (
	CK_DISPATCH_INTERVAL   = "CK_DISPATCH_INTERVAL"
	CK_REDISPATCH_INTERVAL = "CK_REDISPATCH_INTERVAL"
	CK_REDISPATCH_NUM      = "CK_REDISPATCH_NUM"

	SEND_MSG_INTERVAL   = "SEND_MSG_INTERVAL"
	SEND_WAIT_AFTERSEND = "SEND_WAIT_AFTERSEND"
	SEND_FAILURE_STOP   = "SEND_FAILURE_STOP"

	PHONE_NUM_FETCHED_DEFAULT = "PHONE_NUM_FETCHED_DEFAULT"

	MACCODE_RECYCLE_INTERVAL = "MACCODE_RECYCLE_INTERVAL"
	PHONE_RECYCLE_INTERVAL   = "PHONE_RECYCLE_INTERVAL"
	APPLEID_RECYCLE_INTERVAL = "APPLEID_RECYCLE_INTERVAL"

	MACCODE_EXPIRE_INTERVAL = "MACCODE_EXPIRE_INTERVAL"

	RECYCLE_NUM_PHONE   = "RECYCLE_NUM_PHONE"
	RECYCLE_NUM_APPLEID = "RECYCLE_NUM_APPLEID"
	TRAILER_NUM_APPLEID = "TRAILER_NUM_APPLEID"

	PROXY_SWITCH       = "PROXY_SWITCH"
	CERTEXTRACT_SWITCH = "CERTEXTRACT_SWITCH"
	CERTWORK_SWITCH    = "CERTWORK_SWITCH"
	TRAILER_SWITCH     = "TRAILER_SWITCH"
)

var (
	m_mbase         = mongoc.NewMongoColl("im_meta", 20*time.Second)
	METACACHE_MODEL = &MetaCacheModel{metaCache: make(map[string]string)}
)

type MetaCacheModel struct {
	metaCache map[string]string
}

func init() {
	METACACHE_MODEL.ReloadMETA()
	ticker := time.NewTicker(time.Second * 30)
	go func() {
		for _ = range ticker.C {
			METACACHE_MODEL.ReloadMETA()
			fmt.Println("ReloadMETA!")
		}
	}()
}

func (s *MetaCacheModel) ReloadMETA() {
	var metaSlice []entities.IMMeta
	fmt.Println("----------loading meta data------------")
	err := m_mbase.Find(bson.M{}, &metaSlice)
	if err != nil {
		panic(fmt.Sprintf("load meta data err:[%s]", err.Error()))
	}
	for _, meta := range metaSlice {
		s.metaCache[meta.Key] = meta.Value
	}
	fmt.Println("----------success loaded meta data-----")
}

func (s *MetaCacheModel) GetMETACache() map[string]string {
	return s.metaCache
}

func (s *MetaCacheModel) QueryMETA(paramKey string) string {
	return s.metaCache[paramKey]
}

func (s *MetaCacheModel) SaveMeta(paramKey string, paramVal string) error {
	err := m_mbase.UpdateOne(bson.M{"Key": paramKey}, bson.M{"$set": bson.M{"Value": paramVal}})
	if err == nil {
		s.ReloadMETA()
	}
	return err
}

func (s *MetaCacheModel) QueryMETAInteger(paramKey string, default_val int64) int64 {
	str_val, ok := s.metaCache[paramKey]
	if ok {
		int_val, err := strconv.Atoi(str_val)
		if err != nil {
			return default_val
		}
		return int64(int_val)
	} else {
		return default_val
	}
}

func (s *MetaCacheModel) IsCertExtractOn() bool {
	v := s.QueryMETAInteger(CERTEXTRACT_SWITCH, 1)
	return v == 1
}

func (s *MetaCacheModel) IsCertWorkOn() bool {
	v := s.QueryMETAInteger(CERTWORK_SWITCH, 1)
	return v == 1
}

func (s *MetaCacheModel) IsProxyOn() bool {
	v := s.QueryMETAInteger(PROXY_SWITCH, 1)
	return v == 1
}

func (s *MetaCacheModel) IsTrailerOn() bool {
	v := s.QueryMETAInteger(TRAILER_SWITCH, 1)
	return v == 1
}
