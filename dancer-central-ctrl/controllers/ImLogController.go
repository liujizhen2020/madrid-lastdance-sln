package controllers

import (
	"dancer-central-ctrl/bussiness"
	mycfg "dancer-central-ctrl/extcfg"
	"encoding/json"
)

// ImLogController operations for ImLog
type ImLogController struct {
	IMBaseController
}

// @router /imlog/serialLog [get]
func (c *ImLogController) SerialLog() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	logRecord, _ := bussiness.BLOG_SERVE.QuerySerialLog()
	logBytes, _ := json.Marshal(logRecord)
	c.Data["logRecord"] = string(logBytes)
	c.TplName = "imlog/seriallog.tpl"
}

// @router /imlog/appleIdLog [get]
func (c *ImLogController) AppleIdLog() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	logData, _ := bussiness.BLOG_SERVE.QueryAppleIdLog()
	logBytes, _ := json.Marshal(logData)
	c.Data["logRecord"] = string(logBytes)
	c.TplName = "imlog/appleidlog.tpl"
}
