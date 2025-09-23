package controllers

import (
	"github.com/astaxie/beego"
	mycfg "mac-central-ctrl/extcfg"
)

type IndexController struct {
	beego.Controller
}

// @router /index [get]
func (c *IndexController) Index() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "index.tpl"
}
