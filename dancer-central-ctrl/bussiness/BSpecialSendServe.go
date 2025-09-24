package bussiness

import (
	"dancer-central-ctrl/entities"
	"dancer-central-ctrl/mongoc"
	"encoding/csv"
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"strings"
	"time"
)

var (
	BSPECIALSEND_SERVE = &SpecialSendServe{
		PortableTemplate: PortableTemplate{Impl: &BSpecialSendPortableImpl{}},
		dispatchNum:      0,
		dispatchCounter:  0,
		memberQueue:      mongoc.NewMongoColl("im_specialsend", 20*time.Second),
	}
)

type SpecialSendServe struct {
	PortableTemplate
	dispatchNum     int64
	dispatchCounter int64
	memberQueue     *mongoc.MongoColl
}

type BSpecialSendPortableImpl struct {
}

func (b *BSpecialSendPortableImpl) ImportParse(line string) (interface{}, error) {
	fmt_line := line
	if strings.Contains(fmt_line, "@") || strings.HasPrefix(fmt_line, "+") {
	} else if strings.HasPrefix(fmt_line, "86") {
		fmt_line = fmt.Sprint("+", fmt_line)
	} else {
		fmt_line = fmt.Sprint("+86", fmt_line)
	}
	return entities.Phone{Number: fmt_line, CreateAt: time.Now()}, nil
}

func (b *BSpecialSendPortableImpl) ExportWrite(writer *csv.Writer, obj interface{}) error {
	return errors.New("Export Write Not Implement")
}

func (b *SpecialSendServe) SpecialSendList() string {
	var specialSendList []entities.Phone
	err := b.memberQueue.Find(bson.M{}, &specialSendList)
	if err != nil {
		return ""
	}
	list_str := ""
	for _, sp := range specialSendList {
		list_str = fmt.Sprint(list_str, sp.Number, "\r")
	}
	return list_str
}

func (b *SpecialSendServe) SpecialItems() ([]string, error) {
	if b.dispatchCounter < b.dispatchNum {
		var specialSendList []entities.Phone
		var pno_list []string
		err := b.memberQueue.Find(bson.M{}, &specialSendList)
		if err != nil {
			return nil, errors.New(fmt.Sprintf("CollFind Err:%s", err.Error()))
		}
		for _, sp := range specialSendList {
			pno_list = append(pno_list, fmt.Sprint(sp.Number))
		}
		if pno_list == nil || len(pno_list) == 0 {
			return nil, errors.New("No Special Item")
		}
		b.dispatchCounter++
		return pno_list, nil
	}
	return nil, errors.New("Finished")
}

func (b *SpecialSendServe) DispatchNum() int64 {
	return b.dispatchNum
}

func (b *SpecialSendServe) Apply(dispatchNum int64, body string) {
	b.memberQueue.DeleteMany(bson.M{})
	b.dispatchCounter = 0
	b.StringImport(b.memberQueue, body)
	b.dispatchNum = dispatchNum
}

func (b *SpecialSendServe) RepushWhileError() {
	fmt.Println("SPRedispatchWhileError")
	b.dispatchCounter--
}
