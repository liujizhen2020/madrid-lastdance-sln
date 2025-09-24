package models

import (
	mycfg "dancer-central-ctrl/extcfg"
	"flag"
	"github.com/larspensjo/config"
	"log"
)

func ParseGroupFile(filepath string, uuid string) map[string]map[string]int {
	//set config file std
	ret := make(map[string]map[string]int)
	configFile := flag.String(uuid, filepath, "General configuration file")
	cfg, err := config.ReadDefault(*configFile)
	if err != nil {
		log.Fatalf("Fail to find", *configFile, err)
	}
	//set config file std End

	//Initialized topic from the configuration
	ios10gn := mycfg.GetIOS10GN()
	ios11gn := mycfg.GetIOS11GN()
	if cfg.HasSection("ios10") {
		section, err := cfg.SectionOptions("ios10")
		if err == nil {
			ios10map := make(map[string]int)
			for _, v := range section {
				_, err := cfg.String("ios10", v)
				if err == nil {
					ios10map[v] = 1
				}
			}
			ret[ios10gn] = ios10map
		}
	}

	if cfg.HasSection("ios11") {
		section, err := cfg.SectionOptions("ios11")
		if err == nil {
			ios11map := make(map[string]int)
			for _, v := range section {
				_, err := cfg.String("ios11", v)
				if err == nil {
					ios11map[v] = 1
				}
			}
			ret[ios11gn] = ios11map
		}
	}
	//Initialized topic from the configuration END
	return ret
}
