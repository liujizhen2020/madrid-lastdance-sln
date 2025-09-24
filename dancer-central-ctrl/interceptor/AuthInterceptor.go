package interceptor

import (
	mycfg "dancer-central-ctrl/extcfg"
	"fmt"
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/context"
	"github.com/dgrijalva/jwt-go"
)

var AuthorizeInterceptor = func(ctx *context.Context) {
	tokenCookie, err := ctx.Request.Cookie("im_token")
	if err != nil {
		fmt.Println("无Token")
		ctx.Redirect(302, "/auth/toLogin")
		return
	}
	tokenStr := tokenCookie.Value
	fmt.Println("token:", tokenStr)
	token, err := jwt.ParseWithClaims(tokenStr, jwt.MapClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(mycfg.SecretKey), nil
	})
	if err == nil {
		if token.Valid {
		} else {
			fmt.Println("Token不合法")
			ctx.Redirect(302, "/auth/toLogin")
			return
		}
	} else {
		fmt.Println("Token校验失败")
		ctx.Redirect(302, "/auth/toLogin")
		return
	}
}

func init() {
	beego.InsertFilter("/", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/index", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/*/toImport", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/imexport/exportSuccess", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/imlog/serialLog", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toAddByType", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toAddText", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toAddImageHref", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toAddApp", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toAddImage", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toEditByIdentifier", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toEditText", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toEditImageHref", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toEditApp", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toEditImage", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/msgedit/toChangeType", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/phoneNo/toImport", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/specialSend/toConfig", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/systemMeta/toConfig", beego.BeforeRouter, AuthorizeInterceptor)
	beego.InsertFilter("/wechat/toMain", beego.BeforeRouter, AuthorizeInterceptor)
}
