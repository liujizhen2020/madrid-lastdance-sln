package bussiness

import (
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"mac-central-ctrl/common"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/mongoc"
	"time"
)

var (
	BLOG_SERVE       = &BLogServe{}
	sendlog_mbase    = mongoc.NewMongoFIFOColl("im_sendlog", 20*time.Second, 500)
	settlelog_mbase  = mongoc.NewMongoColl("im_settlelog", 20*time.Second)
	appleidlog_mbase = mongoc.NewMongoFIFOColl("im_appleidlog", 20*time.Second, 500)
)

type BLogServe struct {
}

func (b *BLogServe) QuerySerialLog() ([]entities.IMSerialLog, error) {
	var logSlice []entities.IMSerialLog
	err := sendlog_mbase.Find(bson.M{}, &logSlice, &options.FindOptions{Sort: bson.M{"CreateAt": -1}})
	if err != nil {
		return nil, err
	}
	return logSlice, nil
}

func (b *BLogServe) QueryAppleIdLog() ([]entities.IMAppleIdLog, error) {
	var logSlice []entities.IMAppleIdLog
	err := appleidlog_mbase.Find(bson.M{}, &logSlice, &options.FindOptions{Sort: bson.M{"CreateAt": -1}})
	if err != nil {
		return nil, err
	}
	return logSlice, nil
}

func (b *BLogServe) SendLogging(cert entities.IMCert, succNum int64) {
	var poped entities.IMSerialLog
	t_now := common.NowTimeStr()
	log := entities.IMSerialLog{
		Serial:          cert.DeviceBasic.SN,
		ProductType:     cert.DeviceBasic.PT,
		CreateAt:        time.Now(),
		CreateAtStr:     t_now,
		BindingTimeStr:  common.Fmt2Str(cert.IMRegTime),
		BindingEmail:    cert.IMEmail,
		EmailPWD:        cert.IMPassword,
		LastSucc:        succNum,
		DispNum:         cert.DispNum,
		SuccTotal:       cert.SuccTotal,
		BindingInterval: common.GetHourInterval(cert.IMRegTime, time.Now())}
	sendlog_mbase.FIFOPushOne(log, &poped)
}

func (b *BLogServe) AppleIdLogging(cert entities.IMCert, succNum int64) {
	var newItem, poped entities.IMAppleIdLog
	email := cert.IMEmail
	pwd := ""
	var appleId entities.AppleId
	err := a100_mbase.FindOne(bson.M{"Email": email}, &appleId)
	if err == nil {
		pwd = appleId.Password
	}
	err = appleidlog_mbase.PopOne(bson.M{"Email": email}, &newItem)
	if err != nil {
		newItem = entities.IMAppleIdLog{
			Email:     email,
			Pwd:       pwd,
			CreateAt:  time.Now(),
			MDNum:     0,
			Create:    common.NowTimeStr(),
			SuccTotal: 0,
		}
	}
	newItem.MDNum++
	newItem.Update = common.NowTimeStr()
	newItem.SuccTotal = newItem.SuccTotal + succNum
	newItem.LastSucc = succNum
	appleidlog_mbase.FIFOPushOne(newItem, &poped)
}

func (b *BLogServe) SettleLog(num int64) error {
	var settleLog entities.IMSettleLog
	x := time.Now()
	month := x.Format("2006-01")
	err := settlelog_mbase.FindOne(bson.M{"Month": month}, &settleLog)
	if err == nil {
		settleLog.Num += num
	} else {
		settleLog = entities.IMSettleLog{Month: month, Num: num}
	}
	updsert := true
	err = settlelog_mbase.UpdateOne(bson.M{"Month": month}, bson.M{"$set": bson.M{"Month": month, "Num": settleLog.Num, "CreateAt": time.Now()}}, &options.UpdateOptions{Upsert: &updsert})
	return err
}
