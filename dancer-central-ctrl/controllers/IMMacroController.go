package controllers

import (
	"dancer-central-ctrl/bussiness"
	mycfg "dancer-central-ctrl/extcfg"
	"encoding/csv"
	"encoding/json"
	"fmt"
)

// IMMacroController operations for IMMacro
type IMMacroController struct {
	IMBaseController
}

// @router /macro/toMain [get]
func (c *IMMacroController) ToMain() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	identifier := c.GetString("identifier")
	idfs, _ := bussiness.BMACRO_SERVE.QueryIdentifiers()
	idfs_b, _ := json.Marshal(idfs)
	c.Data["identifier"] = identifier
	c.Data["idfs"] = string(idfs_b)
	c.TplName = "macro/main.tpl"
}

// @router /macro/status [get]
func (c *IMMacroController) Status() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	identifier := c.GetString("identifier")
	m, err := bussiness.BMACRO_SERVE.QueryMacroByIdentifier(identifier)
	if err != nil {
		c.ServeSimpleRet(0, "查询失败")
		return
	}
	c.ServeApiDataRet(1, "ok", m)
}

// @router /macro/doImport [post]
func (c *IMMacroController) DoImport() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	identifier := c.GetString("identifier")
	f, _, err := c.GetFile("file")
	if err == nil {
		bussiness.BMACRO_SERVE.CurrentServedIdentifier = identifier
		bussiness.BMACRO_SERVE.ImportFromCSV(f)
		c.ServeSimpleRet(1, "导入成功")
		return
	}
	c.ServeSimpleRet(0, "文件未上传")
}

// @router /macro/truncate [post]
func (c *IMMacroController) Truncate() {
	//获取客户端通过GET/POST方式传递的参数
	identifier := c.GetString("identifier")
	if identifier == "" {
		c.ServeSimpleRet(0, "identifier参数错误")
		return
	}
	_, err := bussiness.BMACRO_SERVE.TruncateByIdentifier(identifier)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("清除出错:[%s]", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "清除成功")
}

// @router /macro/export [get]
func (c *IMMacroController) Export() {
	//获取客户端通过GET/POST方式传递的参数
	identifier := c.GetString("identifier")
	if identifier == "" {
		c.ServeSimpleRet(0, "identifier参数错误")
		return
	}
	c.Ctx.Output.Header("Content-Type", "text/csv")
	c.Ctx.Output.Header("Content-Disposition", fmt.Sprintf("attachment; filename=macro_%s.csv", identifier))
	writer := csv.NewWriter(c.Ctx.ResponseWriter)
	bussiness.BMACRO_SERVE.ExportForIdentifier(writer, identifier)
}

// @router /macro/resetStatus [post]
func (c *IMMacroController) ResetStatus() {
	//获取客户端通过GET/POST方式传递的参数
	identifier := c.GetString("identifier")
	if identifier == "" {
		c.ServeSimpleRet(0, "identifier参数错误")
		return
	}
	_, err := bussiness.BMACRO_SERVE.ResetForIdentifier(identifier)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("重置失败:[%s]", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "重置微信号成功")
}

// @router /macro/delete [post]
func (c *IMMacroController) Delete() {
	//获取客户端通过GET/POST方式传递的参数
	macro_value := c.GetString("macro_value")
	identifier := c.GetString("identifier")
	if identifier == "" {
		c.ServeSimpleRet(0, "identifier参数错误")
		return
	}
	err := bussiness.BMACRO_SERVE.DeleteForIdentifier(identifier, macro_value)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("删除出错:[%s]", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "删除成功")
}
