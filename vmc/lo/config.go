package lo

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
)

const (
	cfgPath string = "vmc.config"
)

type Config struct {
	// limited by memory
	MaxRunVM int

	// vmrun tool
	VMRunPath string

	// base vmx
	BaseVmxPath string

	// clone to
	CloneToPath string

	// snapshot
	SnapshotName string

	// no clone, send only
	SendOnly bool

	// sync with server
	SyncInterval int

	// vmware player
	UsePlayer bool

	// nat reboot (minute)
	NatReBootInterval int
}

func (cfg *Config) String() string {
	if cfg.SendOnly {
		return fmt.Sprintf("Config: *** SEND ONLY, NO CLONE *** \n\t max run: %d \n\t vmrun: %s \n\n", cfg.MaxRunVM, cfg.VMRunPath)
	}

	return fmt.Sprintf("Config:  \n\t max run: %d \n\t clone from: %s \n\t clone to: %s \n\t clone snapshot: %s \n\t vmrun: %s \n\t NatReBootInterval: %d Min \n\n", cfg.MaxRunVM, cfg.BaseVmxPath, cfg.CloneToPath, cfg.SnapshotName, cfg.VMRunPath, cfg.NatReBootInterval)
}

func SampleConfig() *Config {
	cfg := Config{
		MaxRunVM:     1,
		VMRunPath:    "C:\\Program Files (x86)\\VMware\\VMware Workstation\\vmrun.exe",
		BaseVmxPath:  "D:\\vm\\base\\base.vmx",
		CloneToPath:  "D:\\vm",
		SnapshotName: "CLEAN",
		SendOnly:     false,
		SyncInterval: 30,
		UsePlayer:    false,
		NatReBootInterval: 60,
	}
	return &cfg
}

func ReadConfig() *Config {
	cfgData, err := ioutil.ReadFile(cfgPath)
	if err != nil {
		cfg := SampleConfig()
		// write sample config
		cfgData, _ = json.Marshal(cfg)
		err = ioutil.WriteFile(cfgPath, cfgData, 0644)
		if err != nil {
			panic("Fatal: can not write sample config.json")
		}
		return cfg
	}

	var config Config
	err = json.Unmarshal(cfgData, &config)
	if err != nil {
		panic("Fatal: failed to parse config.json")
	}
	return &config
}
