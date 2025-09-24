package controllers

import (
	"github.com/astaxie/beego"
)

type SimpleRet struct {
	RetCode int64
	RetMsg  string
}

type ApiDataRet struct {
	SimpleRet
	Data interface{}
}

// IMBaseController operations for IMBase
type IMBaseController struct {
	beego.Controller
}

func (c *IMBaseController) ServeSimpleRet(code int64, msg string) {
	ret := SimpleRet{RetCode: code, RetMsg: msg}
	c.Data["json"] = ret
	c.ServeJSON()
}

func (c *IMBaseController) ServeApiDataRet(code int64, msg string, data interface{}) {
	c.Data["json"] = ApiDataRet{SimpleRet: SimpleRet{RetCode: code, RetMsg: msg}, Data: data}
	c.ServeJSON()
}
