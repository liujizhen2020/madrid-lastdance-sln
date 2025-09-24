package main

import (
	_ "dancer-central-ctrl/interceptor"
	_ "dancer-central-ctrl/job"
	_ "dancer-central-ctrl/routers"
	"github.com/astaxie/beego"
)

func main() {
	beego.Run()
}
