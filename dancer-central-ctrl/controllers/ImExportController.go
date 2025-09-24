package controllers

import (
	"dancer-central-ctrl/bussiness"
	mycfg "dancer-central-ctrl/extcfg"
	"encoding/csv"
	"encoding/json"
	"fmt"
)

// ImExportController operations for ImExport
type ImExportController struct {
	IMBaseController
}

// @router /imexport/exportTask [get]
func (c *ImExportController) ExportTask() {
	identifier := c.GetString("identifier")
	status, _ := c.GetInt("status")
	c.Ctx.Output.Header("Content-Type", "text/csv")
	c.Ctx.Output.Header("Content-Disposition", fmt.Sprintf("attachment; filename=task_%s_%d.csv", identifier, status))
	writer := csv.NewWriter(c.Ctx.ResponseWriter)
	_, err := bussiness.BIMESSAGE_SERVE.FindByIdentifier(identifier)
	if err != nil {
		writer.Write([]string{})
		writer.Flush()
		return
	}
	bussiness.BPHONE_SERVE.Export(writer, identifier, status)
}

// @router /imexport/batchBindingCert [get]
func (c *ImExportController) BatchBindingCert() {
	if !mycfg.IsDragCertON() {
		c.ServeSimpleRet(0, "Bad Server")
		return
	}
	need, err := c.GetInt64("num")
	if err != nil {
		need = 1000
	}
	disp := int64(0)
	disp, _ = c.GetInt64("disp")
	intv := int64(0)
	intv, _ = c.GetInt64("intv")
	data := bussiness.BCERT_SERVE.BatchGetBindingCert(need, disp, intv)
	c.Data["json"] = data
	c.ServeJSON()
}

// @router /imexport/batchExportHistory [get]
func (c *ImExportController) ExportHistory() {
	data, _ := bussiness.BCERT_SERVE.QueryExportHistory()
	d, _ := json.Marshal(data)
	c.Data["history"] = string(d)
	c.TplName = "imexport/batchExportHistory.tpl"
}

// @router /imexport/reBatchExport [get]
func (c *ImExportController) ReBatchExport() {
	_id, err := c.GetInt64("id")
	if err != nil {
		c.CustomAbort(500, "need error")
	}
	data := bussiness.BCERT_SERVE.ReBatchExport(_id)
	c.Data["json"] = data
	c.ServeJSON()
}
