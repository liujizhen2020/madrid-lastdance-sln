package controllers

import (
	"dancer-central-ctrl/bussiness"
	mycfg "dancer-central-ctrl/extcfg"
)

// IMController operations for IM
type IMController struct {
	IMBaseController
}

// @router /im/task [get]
func (c *IMController) Task() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "im/task.tpl"
}

// @router /im/taskData [get]
func (c *IMController) TaskData() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	message_slice := bussiness.BIMESSAGE_SERVE.BuildIMessageIndexView()
	c.ServeApiDataRet(1, "ok", message_slice)
}
