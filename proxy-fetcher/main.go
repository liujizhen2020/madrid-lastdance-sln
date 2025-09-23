package main

import (
	"fmt"
	"proxy-fetcher/s"
	"sync"
)

var (
	wg           sync.WaitGroup
	CONSUMER_IP  = "103.86.46.189:7061"
	PROVIDER_URL = "http://api.tianqiip.com/getip?secret=z21slwsobqquit63&num=%d&type=txt&port=2&time=5&mr=1&sign=3431d37d9be0e07e2f196e1e96e34eda"
)

func main() {
	fmt.Println("=========start========")
	go s.KeepBuffer(CONSUMER_IP, PROVIDER_URL)

	wg.Add(1)
	wg.Wait()
}
