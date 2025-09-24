package job

import (
	"dancer-central-ctrl/bussiness"
	"time"
)

type SystemCtlImpl struct {
}

func init() {
	template := &DispatchTemplate{name: "SystemCtlTemplate",
		interval: 20, unit: time.Second}
	template.impl = &SystemCtlImpl{}
	go template.Start()
}

func (systemCtl *SystemCtlImpl) Execute() error {
	bussiness.BTASK_SERVE.WriteSuccessNum()
	return nil
}
