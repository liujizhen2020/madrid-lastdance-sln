package bussiness

import (
	"dancer-central-ctrl/common"
	"dancer-central-ctrl/entities"
	"dancer-central-ctrl/mongoc"
	"encoding/csv"
	"errors"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"mime/multipart"
	"time"
)

var (
	BMACRO_SERVE = &BMacroServe{CurrentServedIdentifier: "",
		PortableTemplate: PortableTemplate{Impl: &BMacroPortableImpl{}}}
	w0_mbase                  = mongoc.NewMongoColl("im_macro", 20*time.Second)
	identifier_macroval_map   = make(map[string]string)
	identifier_lowerlimit_map = make(map[string]int64)
)

type BMacroServe struct {
	PortableTemplate
	CurrentServedIdentifier string
}

type BMacroPortableImpl struct {
}

func (b *BMacroServe) ImportFromCSV(file multipart.File) int64 {
	return b.LineImport(w0_mbase, file)
}

func (b *BMacroPortableImpl) ImportParse(line string) (interface{}, error) {
	return entities.IMMacro{MacroValue: line, MessageIdentifier: BMACRO_SERVE.CurrentServedIdentifier, UpdateAt: time.Now()}, nil
}

func (b *BMacroPortableImpl) ExportWrite(writer *csv.Writer, entity interface{}) error {
	wechatInfo := entity.(entities.IMMacro)
	err := writer.Write([]string{wechatInfo.MacroValue})
	return err
}

func (b *BMacroServe) DeleteForIdentifier(identifier string, macroVal string) error {
	err := w0_mbase.DeleteOne(bson.M{"MessageIdentifier": identifier, "MacroValue": macroVal})
	if err == nil {
		b.resetMacroIfAbsent(false, identifier, macroVal)
	}
	return err
}

func (b *BMacroServe) ResetForIdentifier(identifier string) (int64, error) {
	rf, err := w0_mbase.UpdateMany(bson.M{"MessageIdentifier": identifier}, bson.M{"$set": bson.M{"Status": 0, "LowerLimit": 0}})
	return rf, err
}

func (b *BMacroServe) ExportForIdentifier(writer *csv.Writer, identifier string) {
	var macroSlice []entities.IMMacro
	b.LineExport(w0_mbase, writer, bson.M{"MessageIdentifier": identifier}, &macroSlice)
}

func (b *BMacroServe) TruncateByIdentifier(identifier string) (int64, error) {
	rf, err := w0_mbase.DeleteMany(bson.M{"MessageIdentifier": identifier})
	if err == nil {
		b.resetMacroIfAbsent(true, identifier, "")
	}
	return rf, err
}

func (b *BMacroServe) InitMacro() {
	im_list, err := BIMESSAGE_SERVE.GetAllIMessage()
	if err != nil {
		return
	}
	for _, im_item := range im_list {
		b.initMacroForIMessage(im_item.Identifier)
	}
}

func (b *BMacroServe) initMacroForIMessage(identifier string) {
	e, err := b.queryUsingMacroByIdentifier(identifier)
	if err == nil {
		identifier_macroval_map[identifier] = e.MacroValue
		identifier_lowerlimit_map[identifier] = e.LowerLimit
		fmt.Printf("set macroval=[%s for identifier:%s] while init\n", e.MacroValue, identifier)
		fmt.Printf("set lower limit[%d for identifier:%s] while init\n", e.LowerLimit, identifier)
	}
}

func (b *BMacroServe) SwitchMacros() {
	im_list, err := BIMESSAGE_SERVE.GetAllIMessage()
	if err != nil {
		fmt.Println("internal_DoMacroWork primary_im is nil")
	}
	for _, im := range im_list {
		b.switchMacroIfNeed(im.SuccNum, im.MacroSwitch, im.Identifier)
	}
}

func (b *BMacroServe) switchMacroIfNeed(current_num int64, macro_switch int64, identifier string) {
	e, err := b.queryUsingMacroByIdentifier(identifier)
	if err == nil {
		fmt.Printf("current macro must be %s for %s\n", e.MacroValue, identifier)
		current_val, _ok := identifier_macroval_map[identifier]
		if !_ok || current_val == "" {
			fmt.Printf("set macro %s for %s while empty\n", e.MacroValue, identifier)
			b.markMacroAsUsing(identifier, e.MacroValue, e.LowerLimit)
		}
		if (current_num - e.LowerLimit) >= macro_switch {
			next_macro, err := b.queryNextMacroToUse(identifier)
			if err == nil {
				fmt.Printf("set macro %s for %s while satisfy change condition\n", next_macro.MacroValue, identifier)
				b.markMacroAsUsing(identifier, next_macro.MacroValue, current_num)
			}
		}
	}
}

func (b *BMacroServe) queryUsingMacroByIdentifier(identifier string) (entities.IMMacro, error) {
	var minfo entities.IMMacro
	err := w0_mbase.FindOne(bson.M{"MessageIdentifier": identifier}, &minfo, &options.FindOneOptions{Sort: bson.M{"LowerLimit": -1}})
	if err != nil {
		fmt.Println("no exists macro or query err", err.Error())
		return entities.IMMacro{}, err
	}
	return minfo, nil
}

func (b *BMacroServe) queryNextMacroToUse(identifier string) (entities.IMMacro, error) {
	var minfo entities.IMMacro
	err := w0_mbase.FindOne(bson.M{"MessageIdentifier": identifier}, &minfo, &options.FindOneOptions{Sort: bson.M{"LowerLimit": 1}})
	if err != nil {
		fmt.Println("no exists macro or query err", err.Error())
		return entities.IMMacro{}, err
	}
	return minfo, nil
}

func (b *BMacroServe) markMacroAsUsing(identifier string, macro_val string, lower_limit int64) {
	var minfo entities.IMMacro
	err := w0_mbase.FindOne(bson.M{"MessageIdentifier": identifier, "MacroValue": macro_val}, &minfo)
	if err != nil {
		return
	}
	w0_mbase.UpdateOne(bson.M{"MessageIdentifier": identifier, "MacroValue": macro_val}, bson.M{"$set": bson.M{"Status": minfo.Status + 1, "LowerLimit": lower_limit, "UpdateAt": time.Now()}})
	identifier_macroval_map[identifier] = macro_val
	identifier_lowerlimit_map[identifier] = lower_limit
}

func (b *BMacroServe) resetMacroIfAbsent(is_truncate bool, identifier string, absent_macroval string) {
	if is_truncate {
		identifier_lowerlimit_map[identifier] = -1
		identifier_macroval_map[identifier] = ""
		return
	}
	curr_macro, _ok := identifier_macroval_map[identifier]
	if _ok && curr_macro == absent_macroval {
		identifier_lowerlimit_map[identifier] = -1
		identifier_macroval_map[identifier] = ""
		return
	}
}

func (b *BMacroServe) QueryIdentifiers() ([]string, error) {
	im_list, err := BIMESSAGE_SERVE.GetAllIMessage()
	if err != nil {
		return nil, err
	}
	ret := []string{}
	for _, x := range im_list {
		ret = append(ret, x.Identifier)
	}
	return ret, nil
}

func (b *BMacroServe) QueryMacroByIdentifier(identifier string) ([]entities.IMMacroView, error) {
	var minfoSlice []entities.IMMacro
	err := w0_mbase.Find(bson.M{"MessageIdentifier": identifier}, &minfoSlice, &options.FindOptions{Sort: bson.D{{"LowerLimit", -1}, {"UpdateAt", -1}}})
	if err != nil {
		return nil, errors.New("Macro for Identifier Find Error")
	}
	var macroInfoViewList []entities.IMMacroView
	_idx := 1
	current_macroval, _ok := identifier_macroval_map[identifier]
	for _, winfo := range minfoSlice {
		using_status := false
		if _ok && current_macroval == winfo.MacroValue {
			using_status = true
		}
		macroInfoViewList = append(macroInfoViewList, entities.IMMacroView{IMMacro: winfo, Index: _idx, IsUsing: using_status, UpdateAtStr: common.Fmt2Str(winfo.UpdateAt)})
		_idx++
	}
	return macroInfoViewList, nil
}

func (b *BMacroServe) GetMacroByIdentifier(identifier string) (string, error) {
	current_macroval, _ok := identifier_macroval_map[identifier]
	if !_ok {
		return "", errors.New("Not Found")
	}
	return current_macroval, nil
}
