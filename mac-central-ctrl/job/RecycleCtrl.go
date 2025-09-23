package job

import (
	"fmt"
	"mac-central-ctrl/bussiness"
	"time"
)

type ARecycleCtlImpl struct {
}

type PRecycleCtlImpl struct {
}

type DRecycleCtlImpl struct {
}

type CRecycleCtlImpl struct {
}

func init() {
	aRecycleTemplate := &DispatchTemplate{name: "aRecycleTemplate",
		interval: 30, unit: time.Second}
	aRecycleTemplate.impl = &ARecycleCtlImpl{}
	go aRecycleTemplate.Start()

	pRecycleTemplate := &DispatchTemplate{name: "pRecycleTemplate",
		interval: 30, unit: time.Second}
	pRecycleTemplate.impl = &PRecycleCtlImpl{}
	go pRecycleTemplate.Start()

	dRecycleTemplate := &DispatchTemplate{name: "dRecycleTemplate",
		interval: 20, unit: time.Second}
	dRecycleTemplate.impl = &DRecycleCtlImpl{}
	go dRecycleTemplate.Start()

	cRecycleTemplate := &DispatchTemplate{name: "cRecycleTemplate",
		interval: 20, unit: time.Second}
	cRecycleTemplate.impl = &CRecycleCtlImpl{}
	go cRecycleTemplate.Start()

}

func (recycleCtl *ARecycleCtlImpl) Execute() error {
	rf, err := bussiness.BAPPLEID_SERVE.RecyleForFailed()
	if err == nil {
		fmt.Printf("Success Recycle[%d] Records For AppleId\n", rf)
	}
	return err
}

func (recycleCtl *PRecycleCtlImpl) Execute() error {
	rf, err := bussiness.BPHONE_SERVE.RecyleForFailed()
	if err == nil {
		fmt.Printf("Success Recycle[%d] Records For Phone\n", rf)
	}
	return err
}

func (recycleCtl *DRecycleCtlImpl) Execute() error {
	rf, err := bussiness.BMACCODE_SERVE.Recycle()
	if err == nil {
		fmt.Printf("Success Recycle[%d] Records For Mac\n", rf)
	}
	return err
}

func (recycleCtl *CRecycleCtlImpl) Execute() error {
	rf, err := bussiness.BCERT_SERVE.Recycle()
	if err == nil {
		fmt.Printf("Success Recycle[%d] Records For Cert\n", rf)
	}
	return err
}
