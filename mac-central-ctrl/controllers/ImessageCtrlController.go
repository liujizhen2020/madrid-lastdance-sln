package controllers

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"mac-central-ctrl/bussiness"
	"mac-central-ctrl/common"
	"mac-central-ctrl/entities"
	"mac-central-ctrl/models"
)

// ImessageController operations for Imessage
type ImessageController struct {
	IMBaseController
}

// @router /imessage/pullMultiTask [get]
func (c *ImessageController) PullMultiTask() {
	if !models.METACACHE_MODEL.IsCertWorkOn() {
		c.ServeSimpleRet(0, "e你现在处于被关闭状态")
		return
	}
	all_disabled := bussiness.BIMESSAGE_SERVE.IsAllIMessageDisabled()
	if all_disabled {
		c.ServeSimpleRet(0, "无任务或任务已关闭")
		return
	}
	pool, _ := c.GetInt64("pool", 1)
	need_num := models.METACACHE_MODEL.QueryMETAInteger(models.PHONE_NUM_FETCHED_DEFAULT, 20)
	im_task, err := bussiness.BTASK_SERVE.QueryIMessageTask(need_num, pool)
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	im_pack, err := common.EncryptIMPackage(im_task)
	if err != nil {
		c.ServeSimpleRet(0, err.Error())
		return
	}
	c.ServeApiDataRet(1, "获取成功", im_pack)
}

// @router /imessage/pushTaskStatus [post]
func (c *ImessageController) PushTaskStatus() {
	//获取客户端通过GET/POST方式传递的参数
	var imTaskResult entities.IMTaskResult
	bodyBytes, _ := ioutil.ReadAll(c.Ctx.Request.Body)
	fmt.Println("-----------------------")
	fmt.Println(string(bodyBytes))
	json.Unmarshal(bodyBytes, &imTaskResult)
	fmt.Println("--------succ start------")
	fmt.Println(imTaskResult.Success)
	fmt.Println("--------succ end--------")
	bussiness.BTASK_SERVE.SaveTaskStatus(imTaskResult)
	c.ServeSimpleRet(1, "更新成功")
}

// @router /imessage/saveItemMeta [post]
func (c *ImessageController) SaveItemMeta() {
	//获取客户端通过GET/POST方式传递的参数
	identifier := c.GetString("identifier")
	field := c.GetString("field")
	value, err := c.GetInt64("value")
	if err != nil {
		c.ServeSimpleRet(1, "非法的值")
		return
	}
	bussiness.BIMESSAGE_SERVE.ModifyItemMeta(identifier, field, value)
	c.ServeSimpleRet(1, "保存成功")
}

// @router /imessage/switchStatus [post]
func (c *ImessageController) SwitchStatus() {
	//获取客户端通过GET/POST方式传递的参数
	identifier := c.GetString("identifier")
	bussiness.BIMESSAGE_SERVE.SwitchIMessageStatus(identifier)
	c.ServeSimpleRet(1, "保存成功")
}

// @router /imessage/taskInit [post]
func (c *ImessageController) InitializeNewTask() {
	identifier := c.GetString("identifier")
	if !bussiness.BIMESSAGE_SERVE.ValidateIdentifier(identifier) {
		c.ServeSimpleRet(0, fmt.Sprintf("无效的 identifier"))
		return
	}

	err := bussiness.BTASK_SERVE.InitializeNewTask(identifier)
	if err != nil {
		c.ServeSimpleRet(0, fmt.Sprintf("初始化失败:[%s]", err.Error()))
		return
	}

	c.ServeSimpleRet(1, "初始化成功")
}
