package vm

import (
	"fmt"
	"log"
	"os"
	"os/exec"
)

func cloneVM(m *VMachine) error {
	m.vmxPath = fmt.Sprintf("%s\\%04d_%s\\%s.vmx", cfg.CloneToPath, m.index, m.ID, m.ID)
	log.Println("****** cloneVM", m)

	// check file exists
	good := false
	if _, err := os.Lstat(m.vmxPath); err != nil {
		if os.IsNotExist(err) {
			// not exists
			good = true
		}
	}
	if !good {
		fmt.Println("Can not clone...", m.vmxPath)
		return fmt.Errorf("vmx file exists %s", m.vmxPath)
	}

	nameArgs := fmt.Sprintf("-cloneName=%s", m.ID)
	snapshotArgs := fmt.Sprintf("-snapshot=%s", cfg.SnapshotName)
	execVmrun("clone", cfg.BaseVmxPath, m.vmxPath, "linked", nameArgs, snapshotArgs)
	m.writeMacCodeToVmxFile()
	return nil
}

func deleteVM(m *VMachine) {
	log.Println("****** deleteVM", m)
	// delete vmx.lck dir too...
	if err := os.RemoveAll(fmt.Sprintf("%s.lck", m.vmxPath)); err != nil {
		fmt.Println("Remove .lck dir err", err)
	}
	execVmrun("deleteVM", m.vmxPath)
}

func startVM(m *VMachine, player bool) {
	log.Println("****** startVM", m)
	if player {
		execVmrun("-T", "player", "start", m.vmxPath)
	} else {
		execVmrun("start", m.vmxPath)
	}
}

func stopVM(m *VMachine, player bool) {
	log.Println("****** stopVM", m)
	if player {
		execVmrun("-T", "player", "stop", m.vmxPath)
	} else {
		execVmrun("stop", m.vmxPath)
	}

}

func execVmrun(moreArgs ...string) {
	cmd := exec.Command(cfg.VMRunPath, moreArgs...)
	// fmt.Println("CMD:", cmd.Args)
	cmd.Run()
}
