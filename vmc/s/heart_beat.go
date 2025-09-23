package s

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type ServerNode struct {
	UniqueID string `json:"UniqueID"`
	LastHB   string `json:"LastHB"`
	Server   string `json:"Server"`
}

type HBRequest struct {
	UniqueID    string   `json:"UniqueID"`
	MachineList []string `json:"MachineList"`
}

type HBData struct {
	UniqueID string `json:"UniqueID"`
	Time     string `json:"Time"`
}

type HBResponse struct {
	RetCode int    `json:"RetCode"`
	RetMsg  string `json:"RetMsg"`
	Data    HBData `json:"Data"`
}

func HeartBeat(server string, uniqueID string, vmList []string) (HBData, error) {
	reqData := HBRequest{UniqueID: uniqueID, MachineList: vmList}
	u := fmt.Sprintf("%s/serverNode/heartBeat?", server)
	bytesData, err := json.Marshal(reqData)
	if err != nil {
		fmt.Println(err.Error())
		return HBData{}, err
	}
	reader := bytes.NewReader(bytesData)
	request, err := http.NewRequest("POST", u, reader)
	if err != nil {
		fmt.Println(err.Error())
		return HBData{}, err
	}
	request.Header.Set("Content-Type", "application/json;charset=UTF-8")
	client := http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		fmt.Println(err.Error())
		return HBData{}, err
	}
	respBytes, err := ioutil.ReadAll(resp.Body)
	// fmt.Println("--------hb-------")
	// fmt.Println(string(respBytes))
	if err != nil {
		fmt.Println(err.Error())
		return HBData{}, err
	}
	var r HBResponse
	err = json.Unmarshal(respBytes, &r)
	if err != nil {
		fmt.Println("heartBeat marshall err:", err.Error())
		return HBData{}, err
	}
	if r.RetCode != 1 {
		fmt.Println("syncServer server says:", r.RetMsg)
		return HBData{}, err
	}
	return r.Data, nil
}
