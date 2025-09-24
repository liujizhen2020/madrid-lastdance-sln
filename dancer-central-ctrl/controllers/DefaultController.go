package controllers

import ()

// DefaultController operations for Default
type DefaultController struct {
	IMBaseController
}

// @router / [get]
func (c *DefaultController) Get() {
	c.Redirect("/index", 302)
}
