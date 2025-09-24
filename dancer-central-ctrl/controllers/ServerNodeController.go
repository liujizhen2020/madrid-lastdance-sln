package controllers

import (
	"dancer-central-ctrl/bussiness"
	"encoding/json"
	"fmt"
	"io/ioutil"
)

type ServerNodeController struct {
	IMBaseController
}

// @router /serverNode/heartBeat [post]
func (c *ServerNodeController) HeartBeat() {
	bodyBytes, _ := ioutil.ReadAll(c.Ctx.Request.Body)
	hbData, err := bussiness.BSERVERNODE_SERVE.HeartBeat(bodyBytes, c.Ctx.Request)
	if err != nil {
		c.ServeSimpleRet(0, "心跳失败")
		return
	}
	c.ServeApiDataRet(1, "获取成功", hbData)
}

// @router /serverNode/list [get]
func (c *ServerNodeController) List() {
	c.TplName = "servernode/list.tpl"
}

// @router /serverNode/listData [get]
func (c *ServerNodeController) ListData() {
	listData := bussiness.BSERVERNODE_SERVE.List()
	c.ServeApiDataRet(1, "ok", listData)
}

// @router /serverNode/discard [post]
func (c *ServerNodeController) Discard() {
	UniqueID := c.GetString("UniqueID")
	err := bussiness.BSERVERNODE_SERVE.Discard(UniqueID)
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	c.ServeSimpleRet(1, "OK")
}

// @router /serverNode/syncCMD [post]
func (c *ServerNodeController) SyncCMD() {
	bodyBytes, _ := ioutil.ReadAll(c.Ctx.Request.Body)
	fmt.Println("---------syncCMD--------------")
	fmt.Println(string(bodyBytes))
	snList := []string{}
	err := json.Unmarshal(bodyBytes, &snList)
	if err != nil {
		c.ServeSimpleRet(0, "Json解析失败")
		return
	}
	cmdMap := bussiness.BMACCODE_SERVE.SyncCMD(snList)
	c.ServeApiDataRet(1, "同步成功", cmdMap)
}
