package main

import (
	"fmt"
	"os"
	"os/exec"
	"sync"
	"time"
	"vmc/lo"
	"vmc/vm"
)

var (
	wg sync.WaitGroup
)

func main() {
	showBanner()
	cfg := lo.ReadConfig()
	initVMNatRestartTimer(cfg.NatReBootInterval)
	fmt.Println(cfg)
	vm.ApplyConfig(cfg)

	go vm.KeepTrackVmState()

	wg.Add(1)
	wg.Wait()

}

func showBanner() {
	fmt.Println("")

	fmt.Println("	##     ## ##     ##  ######  ")
	fmt.Println("	##     ## ###   ### ##    ## ")
	fmt.Println("	##     ## #### #### ##       ")
	fmt.Println("	##     ## ## ### ## ##       ")
	fmt.Println("	 ##   ##  ##     ## ##       ")
	fmt.Println("	  ## ##   ##     ## ##    ## ")
	fmt.Println("	   ###    ##     ##  ######  ")

	fmt.Println("")
}

func initVMNatRestartTimer(interval int) {
	// 每 30分钟时执行一次
	ticker := time.NewTicker(time.Duration(interval) * time.Minute)
	go func() {
		defer func() {
			if r := recover(); r != nil {
				fmt.Println("定时器发生错误")
			}
			ticker.Stop()
		}()
		runNatRestartCMD()
		for {
			select {
			case <-ticker.C:
				runNatRestartCMD()
			}
		}
	}()
}

func runNatRestartCMD() {
	cmd := exec.Command("CMD", "/C", `.\reboot.bat`)
	//fmt.Println("CMD:", cmd.Args)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Run()
}
