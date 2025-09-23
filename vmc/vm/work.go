package vm

import (
	"fmt"
	"log"
	"time"
	"vmc/lo"
	"vmc/s"
)

var (
	cfg *lo.Config
)

func ApplyConfig(c *lo.Config) {
	cfg = c
}

func KeepTrackVmState() {
	CurrHenHost().SetUsePlayer(cfg.UsePlayer)
	CurrHenHost().SetSendOnly(cfg.SendOnly)
	CurrHenHost().SetMaxRun(cfg.MaxRunVM)
	CurrHenHost().LoadExistVms(cfg.CloneToPath)
	go CurrHenHost().RunMCProxyServer()

	if cfg.SyncInterval == 0 {
		cfg.SyncInterval = 30
	}

	tk := time.NewTicker(time.Duration(cfg.SyncInterval) * time.Second)
	for {

		log.Println("..............................")
		go getCMDFromSever()

		<-tk.C
	}
}

func getCMDFromSever() {
	cmdMap, err := s.SyncCMD(serverNode.Server, serverNode.UniqueID, CurrHenHost().GetAllVmIDs())
	if err != nil {
		fmt.Println("### getStateFromSever err", err)
		return
	}
	CurrHenHost().HandleServerCommands(cmdMap)
}
