package s

import (
	"fmt"
	"strconv"
	"strings"
)

type MacCode struct {
	ROM          string `json:"rom"`
	MLB          string `json:"mlb"`
	SerialNumber string `json:"sn"`
	BoardID      string `json:"board"`
	ProductType  string `json:"pt"`
	Ip 			 string `json:"Ip"`	
	Port  		 int 	`json:"Port"`
}

func (mc *MacCode) String() string {
	return fmt.Sprintf("<MacCode sn %s rom %s>", mc.SerialNumber, mc.ROM)
}

func (mc *MacCode) CheckValid() bool {
	if len(mc.ROM) != 12 {
		return false
	}

	// MAC地址的构成，是由6组，48位
	// 规定的是第八位的二进制数字表示传输方式： 0 -- 单播的，1 --- 广播
	fmt.Println("@@@@ rom", mc.ROM)
	x := string(mc.ROM[1])
	fmt.Println("@@@@ rom ...", x)
	v, err := strconv.ParseInt(x, 16, 32)
	if err != nil {
		fmt.Println("@@@@ parse int err", err)
		return false
	}
	if v%2 != 0 {
		fmt.Println("@@@@ rom ... v = ", v, "NG")
		return false
	}
	fmt.Println("@@@@ rom ... v = ", v)

	return strings.HasPrefix(mc.BoardID, "Mac-")
}
