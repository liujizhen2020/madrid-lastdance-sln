package controllers

import (
	"encoding/csv"
	"fmt"
	"mac-central-ctrl/bussiness"
	"mac-central-ctrl/common"
	mycfg "mac-central-ctrl/extcfg"
	"mac-central-ctrl/models"
)

// AppleIdController operations for AppleId
type AppleIdController struct {
	IMBaseController
}

// @router /id/fetch [get]
func (c *AppleIdController) Fetch() {
	if !models.METACACHE_MODEL.IsCertExtractOn() {
		c.ServeSimpleRet(0, "系统关闭状态")
		return
	}
	sn := c.GetString("sn")
	_appleId, err := bussiness.BAPPLEID_SERVE.FetchAppleId(sn)
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	c.ServeApiDataRet(1, "获取成功", _appleId)
}

// @router /id/toImport [get]
func (c *AppleIdController) ToImport() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	ctrl_time := models.METACACHE_MODEL.QueryMETAInteger(models.CK_DISPATCH_INTERVAL, 6)
	c.Data["ctrl_time"] = ctrl_time
	c.Data["appleid_tag"] = common.TagSampleFmt()
	c.TplName = "appleid/import.tpl"
}

// @router /id/doImport [post]
func (c *AppleIdController) DoImport() {
	tag := c.GetString("appleid_tag")
	ctrl, err := c.GetInt64("ctrl_time")
	if tag == "" {
		c.ServeSimpleRet(0, "标签不能为空")
		return
	}
	if err != nil {
		c.ServeSimpleRet(0, "静置时间不能为空")
		return
	}
	f, _, err := c.GetFile("file")
	c.Data["contextPath"] = mycfg.GetCtxPath()
	defer f.Close()
	if err != nil {
		c.ServeSimpleRet(0, "请上传文件")
	}
	bussiness.BAPPLEID_SERVE.CurrentServedTag = tag
	err = bussiness.BAPPLEID_SERVE.ImportTag(tag, ctrl)
	if err != nil {
		c.ServeSimpleRet(0, "导入标签失败")
		return
	}
	affected := bussiness.BAPPLEID_SERVE.ImportFromCSV(f)
	bussiness.BAPPLEID_SERVE.SaveTagNum(tag, affected)
	c.ServeSimpleRet(1, fmt.Sprintf("成功导入[%d]个ID", affected))
}

// @router /id/export [get]
func (c *AppleIdController) Export() {
	status, _ := c.GetInt64("status")
	c.Ctx.Output.Header("Content-Type", "text/csv")
	c.Ctx.Output.Header("Content-Disposition", fmt.Sprintf("attachment; filename=appleid_%d.csv", status))
	writer := csv.NewWriter(c.Ctx.ResponseWriter)
	bussiness.BAPPLEID_SERVE.Export(writer, status)
}

// @router /id/truncate [post]
func (c *AppleIdController) Truncate() {
	status, _ := c.GetInt64("status")
	err := bussiness.BAPPLEID_SERVE.Truncate(status)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("重置失败:%s", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "重置AppleId状态成功")
}

// @router /id/disabledStatus [post]
func (c *AppleIdController) DisabledStatus() {
	email := c.GetString("email")
	if email == "" {
		c.ServeSimpleRet(0, "参数[email]为空,更新失败")
		return
	}
	bussiness.BAPPLEID_SERVE.DisabledStatus(email)
	c.ServeSimpleRet(1, "更新成功")
}

// @router /appleId/initTag [get]
func (c *AppleIdController) InitTag() {
	bussiness.BAPPLEID_SERVE.InitTag()
	c.ServeSimpleRet(1, "初始化状态成功")
}

// @router /appleId/tag [get]
func (c *AppleIdController) Tag() {
	c.TplName = "appleid/tag.tpl"
}

// @router /appleId/tagData [get]
func (c *AppleIdController) TagData() {
	tagList, err := bussiness.BAPPLEID_SERVE.ListTag()
	if err != nil {
		c.ServeSimpleRet(0, "Tag列表失败")
		return
	}
	c.ServeApiDataRet(1, "ok", tagList)
}

// @router /appleId/saveTagInterval [post]
func (c *AppleIdController) SaveTagInterval() {
	tag := c.GetString("tag")
	interval, _ := c.GetInt64("interval")
	err := bussiness.BAPPLEID_SERVE.SaveTagInterval(tag, interval)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("设置失败:%s", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "设置成功状态成功")
}

// @router /appleId/tagDel [post]
func (c *AppleIdController) TagDel() {
	tag := c.GetString("tag")
	err := bussiness.BAPPLEID_SERVE.TagDel(tag)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("删除失败:%s", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "删除成功")
}
