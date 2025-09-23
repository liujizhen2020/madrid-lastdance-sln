package vm

import (
	"fmt"
	"io/fs"
	"log"
	"path/filepath"
	"strings"
	"time"
	"vmc/s"
)

type HenHost struct {
	allVms map[string]*VMachine

	allVmIDs []string
	vmIndex  int

	// start vm by signal
	upChan   chan string
	upQueue  map[string]string
	upCount  int
	upMax    int
	downChan chan string

	// clone, wait for start
	cloneQueue map[string]*VMachine
	sendOnly   bool
	usePlayer  bool

	// destroy = stop + delete
	destroyChan chan string

	// mac code proxy server
	ps *MacCodeProxyServer
}

var (
	_s_hen *HenHost
)

func CurrHenHost() *HenHost {
	if _s_hen != nil {
		return _s_hen
	}
	_s_hen = &HenHost{
		allVms:     make(map[string]*VMachine),
		allVmIDs:   make([]string, 0),
		cloneQueue: make(map[string]*VMachine),
	}
	return _s_hen
}

func (h *HenHost) RunMCProxyServer() {
	h.ps = &MacCodeProxyServer{DestoryChan: h.destroyChan}
	h.ps.Start()
}

func (h *HenHost) LoadExistVms(clonePath string) {
	// check old vm on the disk
	log.Println("+ LoadExistVms")
	filepath.Walk(clonePath, func(path string, info fs.FileInfo, err error) error {
		if err == nil && strings.HasSuffix(path, ".vmx") {
			fmt.Println("  * vmx path", path)
			lm := &VMachine{vmxPath: path}
			lm.inferIDFromVmxPath()
			h.AddVm(lm)
		}
		return nil
	})
	fmt.Printf("\t ==== got %d local vms ==== \n", h.GetVmCount())
}

func (h *HenHost) SetMaxRun(max int) {
	h.upMax = max
	h.upQueue = make(map[string]string)
	h.upChan = make(chan string)
	h.downChan = make(chan string)
	h.destroyChan = make(chan string)
	go loopBringUpOrShutdownVms(h.usePlayer, h.upMax, h.upChan, h.upQueue, h.downChan, h.destroyChan)
}

func (h *HenHost) SetSendOnly(s bool) {
	h.sendOnly = s
}

func (h *HenHost) SetUsePlayer(p bool) {
	h.usePlayer = p
}

func (h *HenHost) GetAllVmIDs() []string {
	return h.allVmIDs
}

func (h *HenHost) setUpVmCount(up int) {
	h.upCount = up
}

func (h *HenHost) GetUpVmCount() int {
	return h.upCount
}

func (h *HenHost) GetVmCount() int {
	return len(h.allVmIDs)
}

func (h *HenHost) GetVm(id string) *VMachine {
	return h.allVms[id]
}

func (h *HenHost) AddVm(m *VMachine) {
	h.vmIndex++
	m.index = h.vmIndex
	h.allVms[m.ID] = m
	h.allVmIDs = append(h.allVmIDs, m.ID)
}

func (h *HenHost) RemoveVmByID(vmID string) {
	delete(h.allVms, vmID)

	ids := make([]string, 0)
	for _, i := range h.allVmIDs {
		if i != vmID {
			ids = append(ids, i)
		}
	}
	h.allVmIDs = ids
}

func (h *HenHost) HandleServerCommands(cmds map[string]s.CmdSync) {
	for k, v := range cmds {
		m := h.allVms[k]
		if m == nil {
			continue
		}
		log.Printf("got state --> %s  (vmx %s ) \n", v, m.vmxPath)
		switch v {
		case s.CMD_CLEAN:
			go func(desxC chan<- string, vmID string) {
				desxC <- vmID
			}(h.destroyChan, k)

		// case s.CMD_RESET:
		// 	resetVM(m, h.usePlayer)

		case s.CMD_SHUTDOWN:
			go func(downC chan<- string, vmID string) {
				downC <- vmID
			}(h.downChan, k)

		case s.CMD_RUN:
			if _, ok := h.upQueue[k]; ok {
				// alreay in queue
				continue
			}

			h.upQueue[k] = k
		}
	}

	log.Println("upCount = ", h.GetUpVmCount())
	log.Println("upQueue size = ", len(h.upQueue))

	// try boot up
	boots := h.upMax - h.GetUpVmCount()
	log.Println("boots = ", boots)
	if boots > 0 && len(h.upQueue) > 0 {
		waitIDs := make([]string, 0, len(h.upQueue))
		for k := range h.upQueue {
			waitIDs = append(waitIDs, k)
		}

		for i := 0; i < boots; i++ {
			if i >= len(waitIDs) {
				break
			}

			nextID := waitIDs[i]
			go func(upc chan<- string, vmID string) {
				fmt.Println(" will upc <<<<<<<<<", vmID)
				upc <- vmID
				fmt.Println("      upc <<<<<<<<<", vmID)
			}(h.upChan, nextID)
		}
	}

	if h.sendOnly {
		// can clone? NO, we are send only
		return
	}
	if h.GetUpVmCount() >= h.upMax {
		// can clone? No, HEN runs in full speed.
		return
	}
	if len(h.upQueue) > 0 {
		// can clone? No, vm.
		return
	}

	log.Println("cloneQueue size = ", len(h.cloneQueue))
	if len(h.cloneQueue) == 0 {
		// no vm to send, clone one
		var goodMC *s.MacCode
		mcTry := 0
		for {
			mcTry++

			if mcTry > 10 {
				break
			}
			mc, err := s.FetchMacCode(serverNode.Server)
			if err != nil {
				fmt.Println("FetchMacCode err", err)
				continue
			}

			if mc.CheckValid() {
				goodMC = mc
				break

			} else {
				fmt.Println("@@@@@ mac code is NOT GOOD", mc)
				continue

			}

		}

		if goodMC == nil {
			fmt.Println("NO MacCode...skip clone")
			return
		}
		h.ps.AddMacCode(goodMC)

		nm := &VMachine{ID: goodMC.SerialNumber, MCode: goodMC}
		h.AddVm(nm)
		h.cloneQueue[nm.ID] = nm

		go func(upc chan<- string, csm *VMachine, clQ map[string]*VMachine) {
			clErr := cloneVM(csm)
			if clErr == nil {
				fmt.Println(" will upc <<<<<<<<<", csm.ID, "(new cloned)")
				upc <- csm.ID
				fmt.Println("      upc <<<<<<<<<", csm.ID, "(new cloned)")
				delete(clQ, csm.ID)
			}
		}(h.upChan, nm, h.cloneQueue)
	}
}

func loopBringUpOrShutdownVms(usePlayer bool, upMax int, upC <-chan string, upQ map[string]string, downC <-chan string, desxC <-chan string) {
	upVms := make(map[string]*VMachine)
	tk := time.NewTicker(1 * time.Second)
	for {
		select {
		case <-tk.C:
			upCount := len(upVms)
			CurrHenHost().setUpVmCount(upCount)
			fmt.Println("-------", upCount, " up vms -------")
			// for _, v := range upVms {
			// 	fmt.Println("   - up ", v.vmxPath)
			// }

		case next := <-upC:
			fmt.Println("      upc >>>>>>>>>", next)
			delete(upQ, next)

			nextVM := CurrHenHost().GetVm(next)
			if nextVM != nil {
				log.Println("##### will boot up", nextVM)
				upVms[next] = nextVM
				upCount := len(upVms)
				CurrHenHost().setUpVmCount(upCount)
				startVM(nextVM, usePlayer)
			}

		case down := <-downC:
			if downVM, ok := upVms[down]; ok {
				log.Println("##### will stop vm", downVM)
				stopVM(downVM, usePlayer)
				delete(upVms, down)
			}

		case dx := <-desxC:
			if dxVm := CurrHenHost().GetVm(dx); dxVm != nil {
				log.Println("##### will DESTROY vm", dxVm)
				stopVM(dxVm, usePlayer)
				deleteVM(dxVm)
			}

			delete(upVms, dx)
			CurrHenHost().RemoveVmByID(dx)
		}
	}
}
