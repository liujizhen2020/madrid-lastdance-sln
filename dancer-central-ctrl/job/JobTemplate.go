package job

import (
	"dancer-central-ctrl/common"
	"fmt"
	"time"
)

type Dispatchable interface {
	Start()
}

type Runnable interface {
	Execute() error
}

type DispatchTemplate struct {
	impl     Runnable
	name     string
	interval int64
	unit     time.Duration
}

func (template *DispatchTemplate) Start() {
	ticker := time.NewTicker(time.Duration(template.interval) * template.unit)
	for {
		<-ticker.C
		if template.impl != nil {
			now_time := common.NowTimeStr()
			fmt.Printf("[%s] start to execute in:[%s]\n", template.name, now_time)
			template.impl.Execute()
		} else {
			fmt.Println(template.name, " has not impl")
		}
	}
}
