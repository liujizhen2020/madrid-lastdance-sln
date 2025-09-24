package bussiness

import (
	"dancer-central-ctrl/common"
	"dancer-central-ctrl/entities"
	"dancer-central-ctrl/models"
	"dancer-central-ctrl/mongoc"
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"sort"
	"time"
)

var (
	cert_mbase    = mongoc.NewMongoColl("cert_mbase", 20*time.Second)
	certexp_mbase = mongoc.NewMongoColl("certexp_mbase", 20*time.Second)
	BCERT_SERVE   = &BCertServe{}
)

type exportHistory struct {
	Id int64  `json:"Id" bson:"_id"`
	N  int64  `json:"N" bson:"N"`
	T  string `json:"T" bson:"T"`
}

type exportHistorySlice []exportHistory

func (s exportHistorySlice) Len() int           { return len(s) }
func (s exportHistorySlice) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s exportHistorySlice) Less(i, j int) bool { return s[i].Id > s[j].Id }

type BCertServe struct {
	PortableTemplate
}

func (s *BCertServe) StartLineCtrl(email string) error {
	sameEmailCerts := []entities.IMCert{}
	err := cert_mbase.Find(bson.M{"IMEmail": email, "Status": models.S_CertReady}, &sameEmailCerts)
	tag, interv := BAPPLEID_SERVE.TagIntervalByEmail(email)
	tNow := time.Now()
	tCtrl := common.TimeForBasedOffset(tNow, fmt.Sprintf("%dh", interv))
	for _, cert := range sameEmailCerts {
		cert_mbase.UpdateMany(bson.M{"DeviceBasic.SN": cert.DeviceBasic.SN}, bson.M{"$set": bson.M{"AppleIdTag": tag, "IMRegTime": tNow, "CtrlTime": tCtrl}})
	}
	return err
}

func (s *BCertServe) PutCert(deviceBasic entities.DeviceBasic, appleId entities.AppleId, cert string) error {
	imCert := entities.IMCert{}
	imCert.DeviceBasic = deviceBasic
	imCert.Status = models.S_CertReady
	imCert.IMEmail = appleId.Email
	imCert.IMPassword = appleId.Password
	imCert.IMRegTime = time.Now()
	imCert.SuccTotal = int64(0)
	imCert.ContiFail = int64(0)
	imCert.DispNum = int64(0)
	imCert.Cert = cert
	imCert.CreateAt = time.Now()
	cert_mbase.PushOne(imCert)
	return s.StartLineCtrl(appleId.Email)
}

func (s *BCertServe) RepushWhileError(ck entities.IMCert) {
	cert_mbase.UpdateOne(bson.M{"DeviceBasic.SN": ck.DeviceBasic.SN}, bson.M{"$set": bson.M{"Status": models.S_CertReady}})
}

func (s *BCertServe) CertToWork(pool int64) ([]entities.IMCert, error) {
	imCert := entities.IMCert{}
	fdOpts := options.FindOneOptions{Sort: bson.D{{Key: "CtrlTime", Value: 1}}}
	tNow := time.Now()
	err := cert_mbase.FindOne(bson.M{"CtrlTime": bson.M{"$lte": tNow}, "Status": models.S_CertReady}, &imCert, &fdOpts)
	if err != nil {
		return nil, errors.New("Not Certficate Found")
	}
	var sameEmailCerts []entities.IMCert
	err = cert_mbase.Find(bson.M{"IMEmail": imCert.IMEmail, "Status": models.S_CertReady}, &sameEmailCerts)
	if err != nil {
		return nil, fmt.Errorf("无可用证书?...")
	}
	if pool >= int64(len(sameEmailCerts)) {
		snList := []string{}
		for _, item := range sameEmailCerts {
			snList = append(snList, item.DeviceBasic.SN)
		}
		cert_mbase.UpdateMany(bson.M{"DeviceBasic.SN": bson.M{"$in": snList}}, bson.M{"$set": bson.M{"DeviceBasic.CreateAt": time.Now(), "Status": models.S_CertWorking}})
		return sameEmailCerts, nil
	} else {
		return nil, fmt.Errorf("客户端线程池太小")
	}
}

func (s *BCertServe) SizeOfStatus(status int64) (int64, error) {
	return cert_mbase.DocumentSize(bson.M{"Status": status})
}

func (s *BCertServe) Recycle() (int64, error) {
	recycle_interval := 6
	recyle_before := timeForOffset(fmt.Sprintf("-%dm", recycle_interval))
	imSending, _ := cert_mbase.UpdateMany(bson.M{"Status": models.S_CertWorking, "DeviceBasic.CreateAt": bson.M{"$lte": recyle_before}}, bson.M{"$set": bson.M{"Status": models.S_CertReady}})
	fmt.Printf("recycle %d mac in sending status\n", imSending)

	ck_redispi := models.METACACHE_MODEL.QueryMETAInteger(models.CK_REDISPATCH_INTERVAL, 6)
	ck_redispn := models.METACACHE_MODEL.QueryMETAInteger(models.CK_REDISPATCH_NUM, 3)
	_dis_dur := fmt.Sprintf("-%dh", ck_redispi)
	dis_before := timeForOffset(_dis_dur)
	imWorked, _ := cert_mbase.UpdateMany(bson.M{"DeviceBasic.CreateAt": bson.M{"$lte": dis_before}, "ContiFail": bson.M{"$lt": ck_redispn}, "Status": models.S_CertWorked}, bson.M{"$set": bson.M{"Status": models.S_CertReady}})
	fmt.Printf("recycle %d mac in worked status\n", imWorked)
	return imSending + imWorked, nil
}

func (s *BCertServe) CertWorked(serial string, succ_inc int64) {
	ck_redispn := models.METACACHE_MODEL.QueryMETAInteger(models.CK_REDISPATCH_NUM, 3)
	var imCert entities.IMCert
	err := cert_mbase.PopOne(bson.M{"DeviceBasic.SN": serial, "Status": models.S_CertWorking}, &imCert)
	if err != nil {
		return
	}
	imCert.DispNum += 1
	imCert.SuccTotal += succ_inc
	if succ_inc == 0 {
		imCert.ContiFail++
		if imCert.ContiFail >= ck_redispn {
			BLOG_SERVE.SendLogging(imCert, succ_inc)
			return
		}
	} else {
		imCert.ContiFail = 0
	}
	imCert.Status = models.S_CertWorked
	imCert.CreateAt = time.Now()
	cert_mbase.PushOne(imCert)
	BLOG_SERVE.SendLogging(imCert, succ_inc)
	BLOG_SERVE.AppleIdLogging(imCert, succ_inc)
}

func (s *BCertServe) SyncTagInterval(tag string, interval int64) (int64, error) {
	certs := []entities.IMCert{}
	err := cert_mbase.Find(bson.M{"AppleIdTag": tag}, &certs)
	if err != nil {
		return int64(0), err
	}
	for _, certItem := range certs {
		btime := certItem.IMRegTime
		dur := fmt.Sprintf("%dh", interval)
		ctrltime := common.TimeForBasedOffset(btime, dur)
		cert_mbase.UpdateMany(bson.M{"DeviceBasic.SN": certItem.DeviceBasic.SN}, bson.M{"$set": bson.M{"CtrlTime": ctrltime}})
	}
	return int64(len(certs)), nil
}

func (s *BCertServe) BatchGetBindingCert(need int64, disp int64, intv int64) []string {
	var ckl []string
	expId := time.Now().Unix()
	expTime := common.NowTimeStr()
	filter := bson.M{"Status": models.S_CertReady}
	if intv > 0 {
		offset := common.TimeForOffset(fmt.Sprintf("-%dh", intv))
		filter["IMRegTime"] = bson.M{"$lte": offset}
	}
	if disp > 0 {
		subf := bson.A{
			bson.M{"DispNum": bson.M{"$exists": false}},
			bson.M{"DispNum": bson.M{"$lte": disp}},
		}
		filter["$or"] = subf
	}
	for i := int64(0); i < need; i++ {
		var cert entities.IMCert
		err := cert_mbase.PopOne(filter, &cert)
		if err != nil {
			break
		}
		bcb := cert.Cert
		if err == nil {
			cert.CreateAt = time.Now()
			cert.ExportId = expId
			cert.ExportTime = expTime
			certexp_mbase.PushOne(cert)
			ckl = append(ckl, bcb)
		}
	}
	return ckl
}

func (s *BCertServe) ReBatchExport(_id int64) []string {
	certList := []entities.IMCert{}
	err := certexp_mbase.Find(bson.M{"ExportId": bson.M{"$eq": _id}}, &certList)
	if err != nil {
		return nil
	}
	var ckl []string
	for _, code := range certList {
		bcb := code.Cert
		if err == nil {
			ckl = append(ckl, bcb)
		}
	}
	return ckl
}

func (s *BCertServe) QueryExportHistory() (interface{}, error) {
	ag := []exportHistory{}
	err := certexp_mbase.Aggregate(bson.A{
		bson.D{
			{Key: "$group",
				Value: bson.D{{Key: "_id", Value: "$ExportId"},
					{Key: "N", Value: bson.D{{Key: "$sum", Value: 1}}},
					{Key: "T", Value: bson.D{{Key: "$min", Value: "$ExportTime"}}}}}}},
		&ag)
	if err == nil {
		sort.Sort(exportHistorySlice(ag))
	}
	return ag, err
}
