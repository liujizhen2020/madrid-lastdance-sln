package bussiness

import (
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/mongoc"
	"time"
)

var (
	BIPROXY_SERVE = BIpProxyServe{}
	proxy_mbase   = mongoc.NewMongoColl("ipproxy", 20*time.Second)
)

type BIpProxyServe struct {
	PortableTemplate
}

func (s *BIpProxyServe) Count() (int64, error) {
	return proxy_mbase.DocumentSize(bson.M{})
}

func (s *BIpProxyServe) Next() (entities.IMTaskProxy, error) {
	proxy := entities.IMTaskProxy{}
	err := proxy_mbase.PopOne(bson.M{}, &proxy)
	if err != nil {
		return entities.IMTaskProxy{}, err
	}
	return proxy, nil
}

func (s *BIpProxyServe) Sync() (int, error) {
	c, err := s.Count()
	if err != nil {
		return 0, err
	}
	return 10 - int(c), nil
}

func (s *BIpProxyServe) Put(d []entities.IMTaskProxy) error {
	if d == nil || len(d) == 0 {
		return fmt.Errorf("no data")
	}
	for _, item := range d {
		item.CreateAt = time.Now()
		proxy_mbase.PushOne(item)
	}
	return nil
}
