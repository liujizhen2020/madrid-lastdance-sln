package controllers

import (
	"fmt"
	"mac-central-ctrl/bussiness"
	mycfg "mac-central-ctrl/extcfg"
)

// PhoneNoController operations for Phoneno
type PhoneNoController struct {
	IMBaseController
}

// @router /phoneNo/toImport [get]
func (c *PhoneNoController) ToImport() {
	c.Data["identifier"] = c.GetString("identifier")
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "phoneno/import.tpl"
}

// @router /phoneNo/doImport [post]
func (c *PhoneNoController) DoImport() {
	identifier := c.GetString("identifier")
	c.Data["contextPath"] = mycfg.GetCtxPath()
	r, _, err := c.GetFile("file")
	if err == nil {
		defer r.Close()
		_rf := bussiness.BPHONE_SERVE.ImportFromCSV(r, identifier)
		msg := fmt.Sprintf("成功上传[%d]记录", _rf)
		c.ServeSimpleRet(1, msg)
	} else {
		c.ServeSimpleRet(0, "请上传文件")
	}
}

// @router /phoneNo/truncate [post]
func (c *PhoneNoController) Truncate() {
	//获取客户端通过GET/POST方式传递的参数
	identifier := c.GetString("identifier")
	err := bussiness.BPHONE_SERVE.Truncate(identifier)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("清除失败:[%s]", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "清除成功")
}
