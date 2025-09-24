package bussiness

import (
	"dancer-central-ctrl/entities"
	"dancer-central-ctrl/models"
	"dancer-central-ctrl/mongoc"
	"encoding/csv"
	"errors"
	"fmt"
	"github.com/gogf/gf/container/gset"
	"go.mongodb.org/mongo-driver/bson"
	"mime/multipart"
	"strconv"
	"strings"
	"time"
)

type CmdSync string

const (
	CMD_KEEP  CmdSync = "CMD_KEEP"  //keep保持当前状态
	CMD_RUN   CmdSync = "CMD_RUN"   //run执行任务
	CMD_RESET CmdSync = "CMD_RESET" //重启VM
	CMD_CLEAN CmdSync = "CMD_CLEAN" //clean关闭并清理
)

var (
	maccode_mbase = mongoc.NewMongoColl("maccode_mbase", 20*time.Second)

	BMACCODE_SERVE = &BMacCodeServe{
		PortableTemplate: PortableTemplate{Impl: &BMacCodePortableImpl{}}}
)

type BMacCodeServe struct {
	PortableTemplate
}

type BMacCodePortableImpl struct {
}

func (s *BMacCodeServe) CodeToIMReg(sn string) error {
	err := maccode_mbase.UpdateOne(bson.M{"DeviceBasic.SN": sn}, bson.M{"$set": bson.M{"Status": models.S_MacIMReg, "DeviceBasic.CreateAt": time.Now()}})
	return err
}

func (s *BMacCodeServe) ImportFromCSV(file multipart.File) int64 {
	return s.LineImport(maccode_mbase, file)
}

func (s *BMacCodeServe) ExportByStatus(writer *csv.Writer, status int64) {
	var slicePtr []entities.MacCode
	maccode_mbase.Find(bson.M{"Status": status}, &slicePtr)
	for _, item := range slicePtr {
		s.PortableTemplate.Impl.ExportWrite(writer, item)
	}
	writer.Flush()
}

func (b *BMacCodePortableImpl) ImportParse(line string) (interface{}, error) {
	if strings.HasPrefix(line, ":") {
		line = strings.TrimLeft(line, ":")
	}
	if strings.HasSuffix(line, ":") {
		line = strings.TrimRight(line, ":")
	}
	ep := strings.Split(line, ":")
	if len(ep) != 5 {
		return entities.MacCode{}, errors.New("Field Not Full")
	}
	rom := strings.ToUpper(ep[0])
	fb := rom[0:2]
	d, _ := strconv.ParseUint(fb, 16, 64)
	if d%2 != 0 {
		return entities.MacCode{}, errors.New("Invalid ROM")
	}
	item := entities.MacCode{DeviceBasic: entities.DeviceBasic{ROM: strings.ToUpper(ep[0]), MLB: ep[1], SN: ep[2], BOARD: ep[3], PT: ep[4], CreateAt: time.Now()}, Status: models.S_MacFree, DispNum: 0}
	return item, nil
}

func (p *BMacCodePortableImpl) ExportWrite(writer *csv.Writer, entity interface{}) error {
	macCode := entity.(entities.MacCode)
	line := fmt.Sprintf(":%s:%s:%s:%s:%s:", macCode.ROM, macCode.MLB, macCode.SN, macCode.BOARD, macCode.PT)
	err := writer.Write([]string{line})
	return err
}

func (s *BMacCodeServe) SizeOfStatus(status int64) (int64, error) {
	return maccode_mbase.DocumentSize(bson.M{"Status": status})
}

func (s *BMacCodeServe) Truncate(status int64) error {
	_, err := maccode_mbase.DeleteMany(bson.M{"Status": status})
	return err
}

func (s *BMacCodeServe) IMRegFatal(serial string) error {
	err := maccode_mbase.UpdateOne(bson.M{"DeviceBasic.SN": serial}, bson.M{"$set": bson.M{"Status": models.S_IMRegFatal, "DeviceBasic.CreateAt": time.Now()}})
	return err
}

func (s *BMacCodeServe) FatalMacWithROM(rom string) error {
	fmt_rom := strings.Replace(rom, ":", "", -1)
	fmt_rom = strings.ToUpper(fmt_rom)
	err := maccode_mbase.UpdateOne(bson.M{"DeviceBasic.ROM": fmt_rom}, bson.M{"$set": bson.M{"Status": models.S_MacInitFatal, "DeviceBasic.CreateAt": time.Now()}})
	return err
}

func (s *BMacCodeServe) SuccMacWithROM(rom string) error {
	fmt_rom := strings.Replace(rom, ":", "", -1)
	fmt_rom = strings.ToUpper(fmt_rom)
	err := maccode_mbase.UpdateOne(bson.M{"DeviceBasic.ROM": fmt_rom}, bson.M{"$set": bson.M{"Status": models.S_MacReady}})
	return err
}

func (s *BMacCodeServe) Fetch() (entities.MacCode, error) {
	var ret entities.MacCode
	b, err := BAPPLEID_SERVE.NoBarrier()
	if err != nil || !b {
		return entities.MacCode{}, fmt.Errorf("无ID")
	}
	err = maccode_mbase.PopOne(bson.M{"Status": models.S_MacFree}, &ret)
	if err == nil {
		ret.Status = models.S_MacInitilize
		ret.CreateAt = time.Now()
		maccode_mbase.PushOne(ret)
		return ret, nil
	} else {
		return entities.MacCode{}, errors.New("设备缓存队列已空...")
	}
}

func (s *BMacCodeServe) FindByROM(rom string) (entities.DeviceBasic, error) {
	fmt_rom := strings.Replace(rom, ":", "", -1)
	fmt_rom = strings.ToUpper(fmt_rom)
	var ret entities.MacCode
	err := maccode_mbase.FindOne(bson.M{"DeviceBasic.ROM": fmt_rom}, &ret)
	if err == nil {
		return ret.DeviceBasic, nil
	} else {
		return entities.DeviceBasic{}, fmt.Errorf("无法查找rom[%s]对应的码...", rom)
	}
}

func (s *BMacCodeServe) IMRegSuccess(certBox entities.IMCertBox) error {
	var macCode entities.MacCode
	err := maccode_mbase.PopOne(bson.M{"DeviceBasic.SN": certBox.SN}, &macCode)
	if err != nil {
		return err
	}
	macCode.Status = models.S_MacIMReady
	maccode_mbase.PushOne(macCode)
	acc := BAPPLEID_SERVE.AppleIdBindSucc(certBox.ACC)
	BCERT_SERVE.PutCert(macCode.DeviceBasic, acc, certBox.Cert)
	return nil
}

func (s *BMacCodeServe) Recycle() (int64, error) {

	expire_interval := models.METACACHE_MODEL.QueryMETAInteger(models.MACCODE_EXPIRE_INTERVAL, 6)
	expire_before := timeForOffset(fmt.Sprintf("-%dm", expire_interval))
	mcPrepare, _ := maccode_mbase.UpdateMany(bson.M{"Status": models.S_MacInitilize, "DeviceBasic.CreateAt": bson.M{"$lte": expire_before}}, bson.M{"$set": bson.M{"Status": models.S_MacInitFatal, "DeviceBasic.CreateAt": time.Now()}})
	fmt.Printf("expire [%d] mac in initialize status\n", mcPrepare)
	imPrepare, _ := maccode_mbase.UpdateMany(bson.M{"Status": models.S_MacIMReg, "DeviceBasic.CreateAt": bson.M{"$lte": expire_before}}, bson.M{"$set": bson.M{"Status": models.S_MacReady}})
	fmt.Printf("expire [%d] mac in registering status\n", imPrepare)

	recycle_interval := models.METACACHE_MODEL.QueryMETAInteger(models.MACCODE_RECYCLE_INTERVAL, 6)
	recyle_before := timeForOffset(fmt.Sprintf("-%dm", recycle_interval))
	mcPrepareFatal, _ := maccode_mbase.UpdateMany(bson.M{"Status": models.S_MacInitFatal, "DeviceBasic.CreateAt": bson.M{"$lte": recyle_before}}, bson.M{"$set": bson.M{"Status": models.S_MacFree}})
	fmt.Printf("recycle [%d] mac in initialize fatal status\n", mcPrepareFatal)
	imPrepareFatal, _ := maccode_mbase.UpdateMany(bson.M{"Status": models.S_IMRegFatal, "DeviceBasic.CreateAt": bson.M{"$lte": recyle_before}}, bson.M{"$set": bson.M{"Status": models.S_MacFree}})
	fmt.Printf("recycle [%d] mac in registering fatal status\n", imPrepareFatal)
	return mcPrepare + imPrepare + mcPrepareFatal + imPrepareFatal, nil
}

func (b *BMacCodeServe) SyncCMD(snList []string) map[string]CmdSync {
	m := make(map[string]CmdSync)
	cList := []entities.MacCode{}
	err := maccode_mbase.Find(bson.M{"DeviceBasic.SN": bson.M{"$in": snList}, "Status": bson.M{"$in": []int64{models.S_MacInitFatal, models.S_IMRegFatal}}}, &cList)
	csnList := []string{}
	if err == nil {
		for _, item := range cList {
			sn := item.SN
			csnList = append(csnList, sn)
			m[sn] = CMD_CLEAN
		}
	}

	snSet := gset.NewStrSetFrom(snList, true)
	csnSet := gset.NewStrSetFrom(csnList, true)
	otherSet := snSet.Diff(csnSet)
	rdList := []entities.MacCode{}
	rdsnList := []string{}
	err = maccode_mbase.Find(bson.M{"DeviceBasic.SN": bson.M{"$in": otherSet.Slice()}, "Status": models.S_MacIMReady}, &rdList)
	if err == nil {
		for _, item := range rdList {
			sn := item.SN
			m[sn] = CMD_CLEAN
			rdsnList = append(rdsnList, sn)
		}
		rdsnSet := gset.NewStrSetFrom(rdsnList, true)
		otherSet = otherSet.Diff(rdsnSet)
	}
	for _, sn := range otherSet.Slice() {
		m[sn] = CMD_KEEP
	}
	return m
}
