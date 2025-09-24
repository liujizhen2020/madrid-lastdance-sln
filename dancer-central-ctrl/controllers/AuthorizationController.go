package controllers

import (
	"dancer-central-ctrl/bussiness"
	mycfg "dancer-central-ctrl/extcfg"
	_ "github.com/codegangsta/negroni"
	"github.com/dgrijalva/jwt-go"
	_ "github.com/dgrijalva/jwt-go/request"
)

// AuthorizationController operations for Login
type AuthorizationController struct {
	IMBaseController
}

// @router /auth/toLogin [get]
func (c *AuthorizationController) ToLogin() {
	c.Data["errorTip"] = c.GetString("errorTip")
	c.Data["contextPath"] = mycfg.GetCtxPath()
	c.TplName = "authorize/login.tpl"
}

// @router /auth/doLogin [post]
func (c *AuthorizationController) DoLogin() {
	username := c.GetString("username")
	password := c.GetString("password")
	err_code, _ := bussiness.BUSER_SERVE.UserLogin(username, password)
	switch err_code {
	case bussiness.ACCOUNT_LOCKED:
		{
			c.ServeSimpleRet(0, "账号被锁定")
			return
		}
	case bussiness.ACCOUNT_PWDERR:
		{
			bussiness.BUSER_SERVE.IncFailNum(username)
			c.ServeSimpleRet(0, "用户名密码不正确")
			return
		}
	case bussiness.ACCOUNT_NOEXIST:
		{
			c.ServeSimpleRet(0, "用户不存在")
			return
		}
	}
	token := jwt.New(jwt.SigningMethodHS256)
	tokenString, _ := token.SignedString([]byte(mycfg.SecretKey))
	c.ServeApiDataRet(1, "登陆成功", tokenString)
}
