package controllers

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"mac-central-ctrl/bussiness"
	"mac-central-ctrl/entities"
)

type IPProxyController struct {
	IMBaseController
}

// @router /ipproxy/sync [get]
func (c *IPProxyController) Sync() {
	n, err := bussiness.BIPROXY_SERVE.Sync()
	if err != nil {
		c.ServeSimpleRet(0, "sync err")
		return
	}
	c.ServeApiDataRet(1, "ok", n)
}

// @router /ipproxy/put [post]
func (c *IPProxyController) Put() {
	var proxyList []entities.IMTaskProxy
	bodyBytes, _ := ioutil.ReadAll(c.Ctx.Request.Body)
	fmt.Println("-----------------------")
	fmt.Println(string(bodyBytes))
	json.Unmarshal(bodyBytes, &proxyList)
	bussiness.BIPROXY_SERVE.Put(proxyList)
	c.ServeSimpleRet(1, "更新成功")
}
