package common

import (
	"github.com/satori/go.uuid"
	"net"
	"net/http"
	"strings"
)

func RemoteIp(req *http.Request) string {
	ips := Proxy(req)
	if len(ips) > 0 && ips[0] != "" {
		rip, _, err := net.SplitHostPort(ips[0])
		if err != nil {
			rip = ips[0]
		}
		return rip
	}
	if ip, _, err := net.SplitHostPort(req.RemoteAddr); err == nil {
		return ip
	}
	return req.RemoteAddr
}

func Proxy(req *http.Request) []string {
	if ips := req.Header.Get("X-Forwarded-For"); ips != "" {
		return strings.Split(ips, ",")
	}
	return []string{}
}

func RandIdentifier() string {
	u1 := uuid.NewV4()
	u1_str := u1.String()
	u1_str = strings.Replace(u1_str, "-", "", -1)
	return u1_str
}
