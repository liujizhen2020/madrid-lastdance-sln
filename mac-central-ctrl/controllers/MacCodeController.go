package controllers

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"mac-central-ctrl/bussiness"
	"mac-central-ctrl/entities"
	mycfg "mac-central-ctrl/extcfg"
	"mac-central-ctrl/models"
)

// MacCodeController operations for macCode
type MacCodeController struct {
	IMBaseController
}

// @router /macCode/fetch [get]
func (c *MacCodeController) Fetch() {
	if !models.METACACHE_MODEL.IsCertExtractOn() {
		c.ServeSimpleRet(0, "登陆关闭状态")
		return
	}
	_code, err := bussiness.BMACCODE_SERVE.Fetch()
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	_basic, _ := _code.Basic()
	if !models.METACACHE_MODEL.IsProxyOn() {
		c.ServeApiDataRet(1, "ok", entities.DeviceWithProxy{DeviceBasic: _basic})
		return
	} else {
		proxy, err := bussiness.BIPROXY_SERVE.Next()
		if err != nil {
			c.ServeSimpleRet(0, "无代理")
			return
		}
		c.ServeApiDataRet(1, "获取成功", entities.DeviceWithProxy{DeviceBasic: _basic, IMTaskProxy: proxy})
	}
}

// @router /macCode/findByROM [get]
func (c *MacCodeController) FindByROM() {
	rom := c.GetString("rom")
	code, err := bussiness.BMACCODE_SERVE.FindByROM(rom)
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	c.ServeApiDataRet(1, "ok", code)
}

// @router /macCode/registerSuccess [post]
func (c *MacCodeController) RegisterSuccess() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	var cert_key entities.IMCertBox
	bodyBytes, _ := ioutil.ReadAll(c.Ctx.Request.Body)
	err := json.Unmarshal(bodyBytes, &cert_key)
	if err != nil {
		c.ServeSimpleRet(0, "Json解析失败")
		return
	}
	if cert_key.SN == "" || cert_key.ACC == "" || cert_key.Cert == "" {
		c.ServeSimpleRet(0, "信息不全")
		return
	}
	err = bussiness.BMACCODE_SERVE.IMRegSuccess(cert_key)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("失败[%s]", err.Error()))
		return
	}
	c.ServeSimpleRet(1, "Register成功")
}

// @router /macCode/truncate [post]
func (c *MacCodeController) Truncate() {
	collIndex, err := c.GetInt64("status")
	if err != nil {
		c.ServeSimpleRet(1, "未知的状态码")
		return
	}
	err = bussiness.BMACCODE_SERVE.Truncate(collIndex)
	if err == nil {
		c.ServeSimpleRet(1, "清除成功")
		return
	}
	c.ServeSimpleRet(0, fmt.Sprintf("清除失败[%s]", err.Error()))
}

// @router /macCode/toImport [get]
func (c *MacCodeController) ToImport() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "maccode/import.tpl"
}

// @router /macCode/doImport [post]
func (c *MacCodeController) DoImport() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	f, _, err := c.GetFile("file")
	if err != nil {
		c.ServeSimpleRet(0, "请上传文件")
	}
	defer f.Close()
	rf := bussiness.BMACCODE_SERVE.ImportFromCSV(f)
	c.ServeSimpleRet(1, fmt.Sprintf("成功导入[%d]个码", rf))
}

// @router /macCode/export [get]
func (c *MacCodeController) Export() {
	c.Ctx.Output.Header("Content-Type", "text/csv")
	status, _ := c.GetInt64("status")
	c.Ctx.Output.Header("Content-Disposition", fmt.Sprintf("attachment; filename=maccode_%d.csv", status))
	writer := csv.NewWriter(c.Ctx.ResponseWriter)
	bussiness.BMACCODE_SERVE.ExportByStatus(writer, status)
}

// @router /macCode/imRegFatal [post]
func (c *MacCodeController) IMRegFatal() {
	//获取客户端通过GET/POST方式传递的参数
	sn := c.GetString("sn")
	bussiness.BMACCODE_SERVE.IMRegFatal(sn)
	c.ServeSimpleRet(1, "更新成功")
}

// @router /macCode/macFatalByROM [post]
func (c *MacCodeController) MacFatalByROM() {
	//获取客户端通过GET/POST方式传递的参数
	rom := c.GetString("rom")
	bussiness.BMACCODE_SERVE.FatalMacWithROM(rom)
	c.ServeSimpleRet(1, "更新成功")
}

// @router /macCode/macSuccByROM [post]
func (c *MacCodeController) MacSuccByROM() {
	//获取客户端通过GET/POST方式传递的参数
	rom := c.GetString("rom")
	bussiness.BMACCODE_SERVE.SuccMacWithROM(rom)
	c.ServeSimpleRet(1, "更新成功")
}

// @router /macCode/cert [get]
func (c *MacCodeController) Cert() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "maccode/cert.tpl"
}

type CertWrap struct {
	IdFree  int64 `json:"IdFree"`
	IdLogin int64 `json:"IdLogin"`
	IdReady int64 `json:"IdReady"`
	IdFatal int64 `json:"IdFatal"`

	MacFree      int64 `json:"MacFree"`
	MacInitilize int64 `json:"MacInitilize"`
	MacReady     int64 `json:"MacReady"`
	MacInitFatal int64 `json:"MacInitFatal"`

	IMReg      int64 `json:"IMReg"`
	IMReady    int64 `json:"IMReady"`
	IMRegFatal int64 `json:"IMRegFatal"`

	CertReady   int64 `json:"CertReady"`
	CertWorking int64 `json:"CertWorking"`
	CertWorked  int64 `json:"CertWorked"`
	CertFatal   int64 `json:"CertFatal"`
}

// @router /macCode/certData [get]
func (c *MacCodeController) CertData() {

	a_free, _ := bussiness.BAPPLEID_SERVE.SizeOfCollIndex(models.X_AccountFree)
	a_login, _ := bussiness.BAPPLEID_SERVE.SizeOfCollIndex(models.X_AccountLogin)
	a_ready, _ := bussiness.BAPPLEID_SERVE.SizeOfCollIndex(models.X_IMReady)
	a_fatal, _ := bussiness.BAPPLEID_SERVE.SizeOfCollIndex(models.X_AccountFatal)

	c_free, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_MacFree)
	c_macinit, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_MacInitilize)
	c_macready, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_MacReady)
	c_macimreg, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_MacIMReg)
	c_macimready, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_MacIMReady)

	c_certready, _ := bussiness.BCERT_SERVE.SizeOfStatus(models.S_CertReady)
	c_certworking, _ := bussiness.BCERT_SERVE.SizeOfStatus(models.S_CertWorking)
	c_certworked, _ := bussiness.BCERT_SERVE.SizeOfStatus(models.S_CertWorked)

	c_macinitfatal, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_MacInitFatal)
	c_imregfatal, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_IMRegFatal)
	c_certfatal, _ := bussiness.BMACCODE_SERVE.SizeOfStatus(models.S_CertFatal)

	cw := CertWrap{
		IdFree:  a_free,
		IdLogin: a_login,
		IdReady: a_ready,
		IdFatal: a_fatal,

		MacFree:      c_free,
		MacInitilize: c_macinit,
		MacReady:     c_macready,
		MacInitFatal: c_macinitfatal,

		IMReg:      c_macimreg,
		IMReady:    c_macimready,
		IMRegFatal: c_imregfatal,

		CertReady:   c_certready,
		CertWorking: c_certworking,
		CertWorked:  c_certworked,
		CertFatal:   c_certfatal,
	}
	c.ServeApiDataRet(1, "ok", cw)
}
