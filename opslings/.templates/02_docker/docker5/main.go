package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Printf("hello from %s/%s, no OS required\n", runtime.GOOS, runtime.GOARCH)
}
