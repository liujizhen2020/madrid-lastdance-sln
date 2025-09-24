package controllers

import (
	mycfg "dancer-central-ctrl/extcfg"
	"github.com/astaxie/beego"
)

type IndexController struct {
	beego.Controller
}

// @router /index [get]
func (c *IndexController) Index() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "index.tpl"
}
