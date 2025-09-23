package main

import (
	"github.com/astaxie/beego"
	_ "mac-central-ctrl/interceptor"
	_ "mac-central-ctrl/job"
	_ "mac-central-ctrl/routers"
)

func main() {
	beego.Run()
}
