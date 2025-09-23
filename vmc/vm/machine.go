package vm

import (
	"bufio"
	"bytes"
	"encoding/hex"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"vmc/s"

	"github.com/google/uuid"
)

type VMachine struct {
	ID      string
	vmxPath string

	// new clone
	MCode *s.MacCode

	index int
}

func (m *VMachine) inferIDFromVmxPath() {
	_, name := filepath.Split(m.vmxPath)
	m.ID = strings.ReplaceAll(name, ".vmx", "")
}

func (m *VMachine) String() string {
	return fmt.Sprintf(" <VM-%d %s > ", m.index, m.vmxPath)
}

func (m *VMachine) writeMacCodeToVmxFile() error {
	if m.MCode == nil {
		return fmt.Errorf("mac code is nil or invalid")
	}

	// kind of `a9 71 4d db 5a 39``
	// format to `61:31:c7:d2:44:d9`
	roms := make([]string, 0)
	var part string
	for i, x := range m.MCode.ROM {
		if i%2 == 0 {
			part = string(x)
		} else {
			part = fmt.Sprintf("%s%c", part, x)
			roms = append(roms, part)
		}
	}
	xROM := strings.Join(roms, ":")
	// fmt.Println("MAC", xROM)

	// generated system-id
	u := uuid.New()
	// fmt.Println("uuid ", u)
	var sysIDBuf bytes.Buffer
	xBytes, _ := u.MarshalBinary()
	idx := 0
	for _, b := range xBytes {
		sysIDBuf.WriteString(hex.EncodeToString([]byte{b}))
		idx++
		if idx == 8 {
			sysIDBuf.WriteString("-")
		} else if idx < 16 {
			sysIDBuf.WriteString(" ")
		}
	}
	// fmt.Println("UUID ", sysIDBuf.String())

	// backup old file
	bakPath := fmt.Sprintf("%s.txt", m.vmxPath)
	os.Rename(m.vmxPath, bakPath)

	oldFile, err := os.Open(bakPath)
	if err != nil {
		return fmt.Errorf("open old file err %s", err)
	}
	defer oldFile.Close()

	var vmxBuf bytes.Buffer
	obuf := bufio.NewScanner(oldFile)
	for {
		if !obuf.Scan() {
			break
		}
		line := obuf.Text()
		// fmt.Println("line: ", line)
		if strings.HasPrefix(line, "uuid.location ") {
			continue
		}

		if strings.HasPrefix(line, "uuid.bios ") {
			// replace uuid.bios
			line = fmt.Sprintf("uuid.bios = \"%s\"\n", sysIDBuf.String())
			// fmt.Print("--->", line)
		}

		if strings.HasPrefix(line, "ethernet0.address ") {
			// replace ethernet address
			line = fmt.Sprintf("ethernet0.address = \"%s\"\n", xROM)
			// fmt.Print("--->", line)
		}

		vmxBuf.WriteString(line)
		vmxBuf.WriteString("\n")
	}

	// ret
	outputFile, err := os.OpenFile(m.vmxPath, os.O_WRONLY|os.O_CREATE, 0660)
	if err != nil {
		fmt.Println("OpenFile vmx output err", err)
		return err
	}
	defer outputFile.Close()
	outputFile.Write(vmxBuf.Bytes())

	//clean
	oldFile.Close()
	err = os.Remove(bakPath)
	if err != nil {
		fmt.Println("Remove Err", bakPath, err)
	}

	return nil
}
