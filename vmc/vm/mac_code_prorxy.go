package vm

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"vmc/s"
)

type MacCodeProxyServer struct {
	DestoryChan chan<- string

	romCache map[string]*s.MacCode
}

type psResponse struct {
	RetCode int
	Data    *s.MacCode
}

func (ps *MacCodeProxyServer) Start() {
	ps.romCache = make(map[string]*s.MacCode, 0)

	mux := http.NewServeMux()
	mux.HandleFunc("/", ps.handleHello)
	mux.HandleFunc("/macCode/findByROM", ps.handleFindByROM)
	mux.HandleFunc("/macCode/macFatalByROM", ps.handleMacFatalByROM)
	mux.HandleFunc("/macCode/macSuccByROM", ps.handleMacSuccByROM)

	err := http.ListenAndServe(":51888", mux)
	if err != nil {
		fmt.Println("******* MacCodeProxyServer start err", err)
	}
}

func (ps *MacCodeProxyServer) handleHello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hello from MacCodeProxyServer"))
}

func (ps *MacCodeProxyServer) handleFindByROM(w http.ResponseWriter, r *http.Request) {
	rom := r.URL.Query().Get("rom")
	log.Println("[ps] find mac code with ROM --- ", rom)
	mc, ok := ps.romCache[rom]
	var rsp psResponse
	if ok {
		rsp.RetCode = 1
		rsp.Data = mc
		log.Println("** response with ", mc)

	} else {
		rsp.RetCode = 0
	}

	data, _ := json.Marshal(rsp)
	fmt.Println(string(data))
	w.Write(data)
}

func (ps *MacCodeProxyServer) handleMacFatalByROM(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	rom := r.PostForm.Get("rom")
	log.Println("[ps] FATAL vm with ROM --- ", rom)
	var rsp psResponse

	if mc, ok := ps.romCache[rom]; ok {
		delete(ps.romCache, rom)
		rsp.RetCode = 1

		log.Println("destoryC ~~~ ", mc.SerialNumber)
		ps.DestoryChan <- mc.SerialNumber
		log.Println("destoryC <<<<<< ", mc.SerialNumber)
	}

	data, _ := json.Marshal(rsp)
	w.Write(data)
}
func (ps *MacCodeProxyServer) handleMacSuccByROM(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	rom := r.PostForm.Get("rom")
	log.Println("[ps] good vm with ROM --- ", rom)
	data, _ := json.Marshal(psResponse{RetCode: 1})
	w.Write(data)

	delete(ps.romCache, rom)
}

func (ps *MacCodeProxyServer) AddMacCode(mc *s.MacCode) {
	if mc != nil {
		k := strings.ToLower(mc.ROM)
		k = strings.ReplaceAll(k, ":", "")
		ps.romCache[k] = mc
	}
}
