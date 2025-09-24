package controllers

import (
	"dancer-central-ctrl/bussiness"
	"dancer-central-ctrl/common"
	"dancer-central-ctrl/entities"
	mycfg "dancer-central-ctrl/extcfg"
)

// MsgEditController operations for MsgEdit
type MsgEditController struct {
	IMBaseController
}

// @router /msgedit/toAddText [get]
func (c *MsgEditController) ToAddText() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "msgedit/add.tpl"
}

// @router /msgedit/doAddText [post]
func (c *MsgEditController) DoAddText() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	plain_text := c.GetString("text")
	if plain_text == "" {
		c.ServeSimpleRet(0, "消息内容不能为空")
		return
	}
	identifier := common.RandIdentifier()
	sc := entities.IMessageContent{
		Identifier: identifier,
		Text:       plain_text,
	}
	bussiness.BIMESSAGE_SERVE.AddIMessage(sc)
	c.ServeSimpleRet(1, "添加成功")

}

// @router /msgedit/toEditText [get]
func (c *MsgEditController) ToEditText() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	p_identifier := c.GetString("identifier")
	imessage, err := bussiness.BIMESSAGE_SERVE.FindByIdentifier(p_identifier)
	if err == nil {
		c.Data["text"] = imessage.Content.Text
		c.Data["identifier"] = p_identifier
	}
	c.TplName = "msgedit/edit.tpl"
}

// @router /msgedit/doEditText [post]
func (c *MsgEditController) DoEditText() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	plain_text := c.GetString("text")
	identifier := c.GetString("identifier")
	if plain_text == "" {
		c.ServeSimpleRet(0, "文本内容不能为空")
		return
	}
	sc := entities.IMessageContent{
		Text:       plain_text,
		Identifier: identifier,
	}
	bussiness.BIMESSAGE_SERVE.ModifyIMessage(sc)
	c.ServeSimpleRet(1, "修改成功")
}

// @router /msgedit/doDelete [post]
func (c *MsgEditController) DoDelete() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	identifier := c.GetString("identifier")
	bussiness.BIMESSAGE_SERVE.DeleteIMessage(identifier)
	c.ServeSimpleRet(1, "删除成功")
}
