package bussiness

import (
	"encoding/json"
	"errors"
	"go.mongodb.org/mongo-driver/bson"
	"mac-central-ctrl/mongoc"
	"net"
	"net/http"
	"strings"
	"time"
)

var (
	BSERVERNODE_SERVE = &BServerNodeServe{}
	servernode_mbase  = mongoc.NewMongoColl("im_node", 20*time.Second)
)

type HBRequest struct {
	UniqueID    string   `json:"UniqueID"`
	MachineList []string `json:"MachineList"`
}

type HBData struct {
	IpAddr   string `json:"IpAddr"`
	UniqueID string `json:"UniqueID"`
	Time     string `json:"Time"`
}

type IMNode struct {
	UniqueID string    `json:"UniqueID" bson:"UniqueID"`
	IpAddr   string    `json:"IpAddr" bson:"IpAddr"`
	VmCount  int       `json:"VmCount" bson:"VmCount"`
	HBTime   time.Time `json:"HBTime" bson:"HBTime"`
	Active   bool      `json:"Active" bson:"Active"`
}

type IMNodeWrapper struct {
	Index int
	IMNode
	LastSeen string
}

type BServerNodeServe struct {
}

func getIP(r *http.Request) (string, error) {
	ip := r.Header.Get("X-Real-IP")
	if net.ParseIP(ip) != nil {
		return ip, nil
	}
	ip = r.Header.Get("X-Forward-For")
	for _, i := range strings.Split(ip, ",") {
		if net.ParseIP(i) != nil {
			return i, nil
		}
	}
	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return "", err
	}
	if net.ParseIP(ip) != nil {
		return ip, nil
	}

	return "", errors.New("no valid ip found")
}

func init() {
	go BSERVERNODE_SERVE.OfflineMark()
}

func (s *BServerNodeServe) HeartBeat(bodyBytes []byte, r *http.Request) (HBData, error) {
	hbReq := HBRequest{}
	err := json.Unmarshal(bodyBytes, &hbReq)
	if err != nil {
		return HBData{}, err
	}
	im_node := IMNode{}
	err = servernode_mbase.PopOne(bson.M{"UniqueID": hbReq.UniqueID}, &im_node)
	if err != nil {
		im_node.UniqueID = hbReq.UniqueID
	}
	im_node.VmCount = len(hbReq.MachineList)
	im_node.Active = true
	im_node.IpAddr, _ = getIP(r)
	im_node.HBTime = time.Now()
	servernode_mbase.PushOne(im_node)
	return HBData{UniqueID: im_node.UniqueID, Time: fmt2Str(im_node.HBTime)}, nil
}

func (s *BServerNodeServe) OfflineMark() {
	tk := time.Tick(30 * time.Second)
	for range tk {
		t := timeForOffset("-5m")
		servernode_mbase.UpdateMany(bson.M{"HBTime": bson.M{"$lt": t}}, bson.M{"$set": bson.M{"Active": false}})
	}

}

func (s *BServerNodeServe) List() []IMNodeWrapper {
	nodeList := []IMNode{}
	nodeWrapList := []IMNodeWrapper{}
	servernode_mbase.Find(bson.M{}, &nodeList)
	for idx, item := range nodeList {
		nodeWrapList = append(nodeWrapList, IMNodeWrapper{Index: idx + 1, IMNode: item, LastSeen: fmt2Str(item.HBTime)})
	}
	return nodeWrapList
}

func (s *BServerNodeServe) Discard(UniqueID string) error {
	return servernode_mbase.DeleteOne(bson.M{"UniqueID": UniqueID})
}
