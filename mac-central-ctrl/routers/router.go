package routers

import (
	"github.com/astaxie/beego"
	"mac-central-ctrl/controllers"
)

func init() {
	beego.Include(&controllers.AuthorizationController{})
	beego.Include(&controllers.DefaultController{})
	beego.Include(&controllers.IndexController{})
	beego.Include(&controllers.PhoneNoController{})
	beego.Include(&controllers.ImessageController{})
	beego.Include(&controllers.MsgEditController{})
	beego.Include(&controllers.ImExportController{})
	beego.Include(&controllers.ImLogController{})
	beego.Include(&controllers.AppleIdController{})
	beego.Include(&controllers.MacCodeController{})
	beego.Include(&controllers.SystemMetaController{})
	beego.Include(&controllers.SpecialSendController{})
	beego.Include(&controllers.IMMacroController{})
	beego.Include(&controllers.ServerNodeController{})
	beego.Include(&controllers.IMController{})
	beego.Include(&controllers.IPProxyController{})
}
