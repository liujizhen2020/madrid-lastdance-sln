package s

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
	"time"
)

var (
	syncNeedC = make(chan int)
	fetchedC  = make(chan string)
)

type SyncRet struct {
	RetCode int
	RetMsg  string
	Data    int
}

type ProxyItem struct {
	Ip   string `json:"Ip,omitempty" bson:"ip"`
	Port int    `json:"Port,omitempty" bson:"port"`
}

func SyncNeed(consumerIP string) {
	sync_rsp, err := http.Get(fmt.Sprintf("http://%s/ipproxy/sync?", consumerIP))
	if err != nil {
		fmt.Println("sync resp:", err)
		return
	}
	sync_data, err := ioutil.ReadAll(sync_rsp.Body)
	if err != nil {
		fmt.Println("sync data:", err)
		return
	}
	sync_ret := SyncRet{}
	err = json.Unmarshal(sync_data, &sync_ret)
	if err != nil {
		fmt.Println("Unmarshal err:", err)
		return
	}
	if sync_ret.Data <= 0 {
		fmt.Println("No need to fetch now")
		return
	}
	syncNeedC <- sync_ret.Data
}

func FetchProxy(providerURL string, need int) {
	fmt.Printf("need:%d\n", need)
	fetchURL := fmt.Sprintf(providerURL, need)
	fetch_rsp, err := http.Get(fetchURL)
	if err != nil {
		fmt.Println("fetch resp:", err)
		return
	}
	fetch_data, err := ioutil.ReadAll(fetch_rsp.Body)
	if err != nil {
		fmt.Println("fetch data:", err)
		return
	}
	fetch_str := string(fetch_data)
	if strings.Contains(fetch_str, "msg") {
		fmt.Println("got:", fetch_str)
	} else {
		fetchedC <- fetch_str
	}
}

func ParseUpload(proxies string, consumerIP string) {
	line_list := strings.Split(proxies, "\r")
	proxyList := []ProxyItem{}
	for _, line := range line_list {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		line = strings.Replace(line, "\n", "", -1)
		line = strings.Replace(line, "\r", "", -1)
		ip_port := strings.Split(line, ":")
		port, _ := strconv.Atoi(ip_port[1])
		proxyList = append(proxyList, ProxyItem{Ip: ip_port[0], Port: port})
	}
	bytesData, _ := json.Marshal(proxyList)
	reader := bytes.NewReader(bytesData)

	request, err := http.NewRequest("POST", fmt.Sprintf("http://%s/ipproxy/put?", consumerIP), reader)
	if err != nil {
		fmt.Println("put request err:", err)
		return
	}
	request.Header.Add("content-type", "application/json; charset=utf-8")
	client := &http.Client{}
	res, _ := client.Do(request)
	if res != nil && res.StatusCode == 200 {
		str, _ := ioutil.ReadAll(res.Body)
		bodyStr := string(str)
		fmt.Println(bodyStr)
	}
}

func KeepBuffer(consumerIP string, providerURL string) {
	tk := time.NewTicker(5 * time.Second)
	for {
		select {
		case <-tk.C:
			{
				go SyncNeed(consumerIP)
			}
		case need := <-syncNeedC:
			{
				go FetchProxy(providerURL, need)
			}
		case proxies := <-fetchedC:
			{
				go ParseUpload(proxies, consumerIP)
			}
		}
	}
}
