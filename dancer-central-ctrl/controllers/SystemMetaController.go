package controllers

import (
	mycfg "dancer-central-ctrl/extcfg"
	"dancer-central-ctrl/models"
	"encoding/json"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
)

// SystemMetaController operations for SystemMeta
type SystemMetaController struct {
	IMBaseController
}

// @router /systemMeta/getMap [get]
func (c *SystemMetaController) GetAll() {
	metaData := models.METACACHE_MODEL.GetMETACache()
	c.ServeApiDataRet(1, "查询成功", metaData)
}

// @router /systemMeta/toConfig [get]
func (c *SystemMetaController) ToConfig() {
	c.Data["contextPath"] = mycfg.GetCtxPath()
	for key, val := range models.METACACHE_MODEL.GetMETACache() {
		c.Data[key] = val
	}
	cache := models.METACACHE_MODEL.GetMETACache()
	m, _ := json.Marshal(cache)
	fmt.Println(string(m))
	c.Data["m"] = string(m)
	c.TplName = "systemmeta/config.tpl"
}

// @router /systemMeta/saveConfig [post]
func (c *SystemMetaController) SaveConfig() {
	//获取客户端通过GET/POST方式传递的参数
	param_key := c.GetString("param_key")
	param_value := c.GetString("param_value")
	models.METACACHE_MODEL.SaveMeta(param_key, param_value)
	c.ServeSimpleRet(1, "保存成功")
}
