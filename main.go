package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"tempwork"
)

func init() {
	log.SetFlags(0)
}

func printHelp() {
	fmt.Println("Usage: tempwork command...")
}

func expandPath(cmd []string) (expandCmd []string, err error) {
	expandCmd = cmd
	firstArg := expandCmd[0]

	if strings.HasPrefix(firstArg, "./") || strings.HasPrefix(firstArg, "../") {
		expandCmd[0], err = filepath.Abs(firstArg)
	}

	return
}

func main0() (exitCode int) {
	defer func() {
		if err := recover(); err != nil {
			log.Fatal(err)
		}
	}()

	cmd, err := expandPath(os.Args[1:])

	tw := &tempwork.Tempwork{
		Out: os.Stdin,
		Err: os.Stdout,
		Cmd: cmd,
	}

	exitCode, err = tempwork.Run(tw)

	if err != nil {
		panic(err)
	}

	return
}

func main() {
	if len(os.Args) == 1 {
		printHelp()
		os.Exit(2)
	}

	exitCode := main0()
	os.Exit(exitCode)
}
