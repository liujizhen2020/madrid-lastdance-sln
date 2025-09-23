package entities

import (
	"time"
)

type CtlInfo struct {
	SendInterval  int64 `json:"SendInterval,omitempty" bson:"-"`
	WaitAfterSend int64 `json:"WaitAfterSend,omitempty" bson:"-"`
	FailureStop   int64 `json:"FailureStop,omitempty" bson:"-"`
}

type CertTarget struct {
	CertBox     string   `json:"CertBox,omitempty" bson:"-"`
	PhoneNoList []string `json:"PhoneNoList,omitempty" bson:"-"`
}

type BindingTask struct {
	CtlInfo        CtlInfo         `json:"CtlInfo,omitempty" bson:"-"`
	MsgInfo        IMessageContent `json:"MsgInfo,omitempty" bson:"-"`
	CertTargetInfo []CertTarget    `json:"CertTargetInfo,omitempty" bson:"-"`
	Tag            string          `json:"Tag,omitempty" bson:"-"`
}

type IMTaskResult struct {
	Identifier string   `json:"Identifier,omitempty" bson:"-"`
	Serial     string   `json:"Serial,omitempty" bson:"-"`
	Success    []string `json:"Success,omitempty" bson:"-"`
	Failure    []string `json:"Failure,omitempty" bson:"-"`
	Nogood     []string `json:"Nogood,omitempty" bson:"-"`
}

type IMTaskProxy struct {
	Ip       string    `json:"Ip,omitempty" bson:"ip"`
	Port     int       `json:"Port,omitempty" bson:"port"`
	CreateAt time.Time `json:"-" bson:"CreateAt"`
}

type DeviceWithProxy struct {
	DeviceBasic
	IMTaskProxy
}
