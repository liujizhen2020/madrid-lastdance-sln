package s

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type cmdReq struct {
	NodeID      string   `json:"UniqueID"`
	MachineList []string `json:"MachineList"`
}

type CmdSync string

const (
	CMD_KEEP     CmdSync = "CMD_KEEP"     //keep保持当前状态
	CMD_RUN      CmdSync = "CMD_RUN"      //run执行任务
	CMD_RESET    CmdSync = "CMD_RESET"    //重启VM
	CMD_SUSPEND  CmdSync = "CMD_SUSPEND"  //suspend挂起vm
	CMD_SHUTDOWN CmdSync = "CMD_SHUTDOWN" //shutdown关闭vm
	CMD_CLEAN    CmdSync = "CMD_CLEAN"    //clean关闭并清理
)

type mcResponse struct {
	Code int      `json:"RetCode"`
	Msg  string   `json:"RetMsg"`
	Data *MacCode `json:"Data"`
}

type cmdResponse struct {
	Code int                `json:"RetCode"`
	Msg  string             `json:"RetMsg"`
	Data map[string]CmdSync `json:"Data"`
}

func FetchMacCode(server string) (*MacCode, error) {
	url := fmt.Sprintf("%s/macCode/fetch", server)
	rsp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer rsp.Body.Close()
	data, err := ioutil.ReadAll(rsp.Body)
	if err != nil {
		return nil, err
	}
	var r mcResponse
	err = json.Unmarshal(data, &r)
	if err != nil {
		return nil, err
	}

	if r.Code != 1 {
		fmt.Println("request:", rsp.Request.URL.String())
		fmt.Println("response:", string(data))
		return nil, fmt.Errorf("server: %s", r.Msg)
	}

	return r.Data, nil
}

func SyncCMD(server string, uniqueID string, snList []string) (map[string]CmdSync, error) {
	reqData := snList
	bytesData, err := json.Marshal(reqData)
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	reader := bytes.NewReader(bytesData)
	url := fmt.Sprintf("%s/serverNode/syncCMD?", server)
	request, err := http.NewRequest("POST", url, reader)
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	request.Header.Set("Content-Type", "application/json;charset=UTF-8")
	client := http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	respBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	// fmt.Println("-----syncCMD-------")
	// fmt.Println(string(respBytes))
	cmdResp := cmdResponse{}
	json.Unmarshal(respBytes, &cmdResp)
	return cmdResp.Data, nil
}
