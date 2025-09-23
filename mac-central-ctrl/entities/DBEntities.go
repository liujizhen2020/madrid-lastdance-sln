package entities

import (
	"time"
)

type IMMeta struct {
	Key   string `json:"-" bson:"Key"`
	Value string `json:"-" bson:"Value"`
}

type AppleId struct {
	Email       string    `json:"Email,omitempty" bson:"Email,omitempty"`
	Password    string    `json:"Password,omitempty" bson:"Password,omitempty"`
	PID         string    `json:"PID,omitempty" bson:"PID,omitempty"`
	CreateAt    time.Time `json:"-" bson:"CreateAt,omitempty"`
	TrailerLine time.Time `json:"-" bson:"TrailerLine,omitempty"`
	DispNum     int64     `json:"-" bson:"DispNum"`
	Tag         string    `json:"-" bson:"Tag,omitempty"`
}

type AppleIdTag struct {
	Tag              string    `json:"Tag" bson:"Tag,omitempty"`
	DispatchInterval int64     `json:"DispatchInterval" bson:"DispatchInterval,omitempty"`
	Num              int64     `json:"Num" bson:"Num,omitempty"`
	BindingNum       int64     `json:"BindingNum" bson:"BindingNum"`
	CertNum          int64     `json:"CertNum" bson:"CertNum"`
	ReadyNum         int64     `json:"ReadyNum" bson:"ReadyNum"`
	CreateAt         time.Time `json:"-" bson:"CreateAt,omitempty"`
	CreateAtStr      string    `json:"CreateAtStr" bson:"CreateAtStr"`
}

type DeviceBasic struct {
	SN       string    `json:"sn,omitempty" bson:"SN,omitempty"`
	MLB      string    `json:"mlb,omitempty" bson:"MLB,omitempty"`
	ROM      string    `json:"rom,omitempty" bson:"ROM,omitempty"`
	BOARD    string    `json:"board,omitempty" bson:"BOARD,omitempty"`
	PT       string    `json:"pt,omitempty" bson:"PT,omitempty"`
	CreateAt time.Time `json:"-" bson:"CreateAt,omitempty"`
}

type MacCode struct {
	DeviceBasic `json:"-" bson:"DeviceBasic,omitempty"`
	Status      int64 `json:"-" bson:"Status"`
	DispNum     int64 `json:"-" bson:"DispNum"`
	LastReset   int64 `json:"-" bson:"LastReset"`
}

type IMCert struct {
	DeviceBasic `json:"-" bson:"DeviceBasic,omitempty"`
	Status      int64     `json:"-" bson:"Status"`
	IMEmail     string    `json:"-" bson:"IMEmail,omitempty"`
	IMPassword  string    `json:"-" bson:"IMPassword,omitempty"`
	IMRegTime   time.Time `json:"-" bson:"IMRegTime,omitempty"`
	AppleIdTag  string    `json:"-" bson:"AppleIdTag,omitempty"`
	CtrlTime    time.Time `json:"-" bson:"CtrlTime,omitempty"`
	SuccTotal   int64     `json:"-" bson:"SuccTotal,omitempty"`
	ContiFail   int64     `json:"-" bson:"ContiFail"`
	DispNum     int64     `json:"-" bson:"DispNum"`
	Cert        string    `json:"-" bson:"Cert,omitempty"`

	ExportId   int64  `json:"-" bson:"ExportId,omitempty"`
	ExportTime string `json:"-" bson:"ExportTime,omitempty"`
}

type Phone struct {
	Number   string    `json:"-" bson:"Number,omitempty"`
	DispNum  int64     `json:"-" bson:"DispNum,omitempty"`
	CreateAt time.Time `json:"-" bson:"CreateAt,omitempty"`
}

type User struct {
	Username string    `json:"-" bson:"Username,omitempty"`
	Password string    `json:"-" bson:"Password,omitempty"`
	FailNum  int64     `json:"-" bson:"FailNum,omitempty"`
	CreateAt time.Time `json:"-" bson:"CreateAt,omitempty"`
}

type IMMacro struct {
	MacroValue        string    `json:"MacroValue" bson:"MacroValue,omitempty"`
	MessageIdentifier string    `json:"MessageIdentifier" bson:"MessageIdentifier,omitempty"`
	Status            int64     `json:"Status" bson:"Status,omitempty"`
	LowerLimit        int64     `json:"LowerLimit" bson:"LowerLimit,omitempty"`
	UpdateAt          time.Time `json:"-" bson:"UpdateAt,omitempty"`
}

type IMessage struct {
	Identifier      string          `json:"Identifier,omitempty" bson:"Identifier,omitempty"`
	Status          int64           `json:"Status,omitempty" bson:"Status,omitempty"`
	TargetNum       int64           `json:"TargetNum,omitempty" bson:"TargetNum,omitempty"`
	SuccNum         int64           `json:"SuccNum,omitempty" bson:"SuccNum,omitempty"`
	MacroSwitch     int64           `json:"MacroSwitch,omitempty" bson:"MacroSwitch,omitempty"`
	Content         IMessageContent `json:"Content,omitempty" bson:"Content,omitempty"`
	MessageInterval int64           `json:"MessageInterval,omitempty" bson:"MessageInterval,omitempty"`
	CreateAt        time.Time       `json:"CreateAt,omitempty" bson:"CreateAt,omitempty"`
}

type IMessageContent struct {
	Identifier string `json:"Identifier,omitempty" bson:"Identifier,omitempty"`
	Text       string `json:"Text,omitempty" bson:"Text,omitempty"`
}

type IMSettleLog struct {
	Month    string    `json:"-" bson:"Month"`
	Num      int64     `json:"-" bson:"Num"`
	CreateAt time.Time `json:"-" bson:"CreateAt"`
}

type IMCertBox struct {
	Time string `json:"time" bson:"-"`
	SN   string `json:"sn" bson:"-"`
	ACC  string `json:"acc" bson:"-"`
	Cert string `json:"cert" bson:"-"`
}

type IMSerialLog struct {
	Serial          string    `json:"Serial" bson:"Serial"`
	ProductType     string    `json:"ProductType" bson:"ProductType"`
	CreateAt        time.Time `json:"-" bson:"CreateAt"`
	BindingTimeStr  string    `json:"BindingTimeStr" bson:"BindingTimeStr"`
	CreateAtStr     string    `json:"CreateAtStr" bson:"CreateAtStr"`
	BindingEmail    string    `json:"BindingEmail" bson:"BindingEmail"`
	EmailPWD        string    `json:"EmailPWD" bson:"EmailPWD"`
	SuccTotal       int64     `json:"SuccTotal" bson:"SuccTotal"`
	DispNum         int64     `json:"DispNum" bson:"DispNum"`
	LastSucc        int64     `json:"LastSucc" bson:"LastSucc"`
	BindingInterval int64     `json:"BindingInterval" bson:"BindingInterval"`
}

type IMAppleIdLog struct {
	Email     string    `json:"Email" bson:"Email"`
	Pwd       string    `json:"Pwd" bson:"Pwd"`
	CreateAt  time.Time `json:"-" bson:"CreateAt"`
	MDNum     int64     `json:"MDNum" bson:"MDNum"`
	Create    string    `json:"Create" bson:"CreateAtStr"`
	Update    string    `json:"Update" bson:"UpdateAtStr"`
	LastSucc  int64     `json:"LastSucc" bson:"LastSucc"`
	SuccTotal int64     `json:"SuccTotal" bson:"SuccTotal"`
}

func (c *IMessage) IsActive() bool {
	return c.Status == 1
}

func (c *MacCode) Basic() (DeviceBasic, error) {
	return DeviceBasic{
		SN:    c.SN,
		MLB:   c.MLB,
		ROM:   c.ROM,
		BOARD: c.BOARD,
		PT:    c.PT,
	}, nil
}
