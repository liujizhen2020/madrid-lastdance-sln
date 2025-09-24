package controllers

import (
	"dancer-central-ctrl/bussiness"
	mycfg "dancer-central-ctrl/extcfg"
)

// SpecialSendController operations for SpecialSend
type SpecialSendController struct {
	IMBaseController
}

// @router /specialSend/toConfig [get]
func (c *SpecialSendController) ToConfig() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.Data["dispatch_num"] = bussiness.BSPECIALSEND_SERVE.DispatchNum()
	c.Data["special_phone"] = bussiness.BSPECIALSEND_SERVE.SpecialSendList()
	c.TplName = "specialsend/config.tpl"
}

// @router /specialSend/apply [post]
func (c *SpecialSendController) Apply() {
	dispatch_num, _ := c.GetInt64("dispatch_num")
	special_phone := c.GetString("special_phone")
	if dispatch_num == 0 || special_phone == "" {
		c.ServeSimpleRet(0, "输入有误")
		return
	}
	bussiness.BSPECIALSEND_SERVE.Apply(dispatch_num, special_phone)
	c.ServeSimpleRet(1, "录入成功")
}
