package extcfg

import (
	"fmt"
	config "github.com/astaxie/beego/config"
	"strings"
)

const (
	SecretKey = "welcome to imessage controll center"
)

var (
	configer, _ = config.NewConfig("ini", "conf/app.conf")
)

func GetCtxPath() string {
	ip := configer.String("bindip")
	port := configer.String("httpport")
	return fmt.Sprintf("http://%s:%s", ip, port)
}

func GetIpCtx() string {
	ip := configer.String("bindip")
	return fmt.Sprintf("http://%s", ip)
}

func GetCloudDomain() string {
	return configer.String("clouddomain")
}

func GetMongoURL() string {
	return configer.String("mongourl")
}

func GetMongoBD() string {
	return configer.String("mongodb")
}

func GetIOS10GN() string {
	return configer.String("ios10gn")
}

func GetIOS11GN() string {
	return configer.String("ios11gn")
}

func IsOplogON() bool {
	oplog := configer.String("oplog")
	oplog = strings.ToLower(oplog)
	return oplog == "on"
}

func IsDragCertON() bool {
	dragcert := configer.String("dragcert")
	dragcert = strings.ToLower(dragcert)
	return dragcert == "on"
}
