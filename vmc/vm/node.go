package vm

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"time"
	"vmc/s"

	uuid "github.com/satori/go.uuid"
)

var (
	serverNode = s.ServerNode{}
)

func init() {
	fmt.Println("node init")
	// warm up
	fmt.Println("try read node.json")
	nodeData, err := ioutil.ReadFile("./node.json")
	serverNode = s.ServerNode{}
	if err == nil {
		err = json.Unmarshal(nodeData, &serverNode)
		if err == nil {
			fmt.Println("read node ok")
		}
	} else {
		panic("node.json is need")
	}
	if serverNode.UniqueID == "" {
		fmt.Println("UniqueID missing,create one~")
		serverNode.UniqueID = uuid.NewV4().String()
	}
	tk := time.NewTicker(60 * time.Second)
	go syncServer(serverNode, tk.C)
}

func syncServer(node s.ServerNode, c <-chan time.Time) {
	for range c {
		// log.Println("---> ping")
		vmList := CurrHenHost().GetAllVmIDs()
		s.HeartBeat(node.Server, node.UniqueID, vmList)
		// log.Println("pong <---")
	}
}
