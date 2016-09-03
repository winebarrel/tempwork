package main

import (
	"fmt"
	"log"
	"os"
	"tempwork"
)

func init() {
	log.SetFlags(0)
}

func printHelp() {
	fmt.Println("Usage: tempwork command...")
}

func main0() (exitCode int) {
	defer func() {
		if err := recover(); err != nil {
			log.Fatal(err)
		}
	}()

	tw := &tempwork.Tempwork{
		Out: os.Stdin,
		Err: os.Stdout,
		Cmd: os.Args[1:],
	}

	exitCode, err := tempwork.Run(tw)

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
