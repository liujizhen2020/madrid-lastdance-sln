package job

import (
	"dancer-central-ctrl/bussiness"
	"time"
)

type MacroCtlImpl struct {
}

func init() {
	template := &DispatchTemplate{name: "MacroCtlTemplate",
		interval: 35, unit: time.Second}
	template.impl = &MacroCtlImpl{}
	go template.Start()
}

func (macroCtl *MacroCtlImpl) Execute() error {
	bussiness.BMACRO_SERVE.SwitchMacros()
	return nil
}
