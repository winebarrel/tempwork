package tempwork

import (
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"os/signal"
	"sync"
	"syscall"
)

type Tempwork struct {
	Cmd []string
}

func getExitCode(cmdErr error) (exitCode int, err error) {
	exitErr, ok := cmdErr.(*exec.ExitError)

	if !ok {
		err = cmdErr
		return
	}

	status, ok := exitErr.Sys().(syscall.WaitStatus)

	if !ok {
		err = cmdErr
		return
	}

	exitCode = status.ExitStatus()
	return

}

func tempDir(callback func()) {
	pwd, err := os.Getwd()

	if err != nil {
		panic(err)
	}

	tmp, err := ioutil.TempDir("", "tempwork")

	if err != nil {
		panic(err)
	}

	defer func() {
		os.Chdir(pwd)
		os.RemoveAll(tmp)
	}()

	err = os.Chdir(tmp)

	if err != nil {
		panic(err)
	}

	os.Setenv("TW_ORIG_DIR", pwd)
	os.Setenv("TW_TEMP_DIR", tmp)

	callback()
}

func Run(tw *Tempwork) (exitCode int, err error) {
	var cmd *exec.Cmd

	switch len(tw.Cmd) {
	case 1:
		cmd = exec.Command(tw.Cmd[0])
	default:
		cmd = exec.Command(tw.Cmd[0], tw.Cmd[1:]...)
	}

	outReader, err := cmd.StdoutPipe()

	if err != nil {
		return
	}

	errReader, err := cmd.StderrPipe()

	if err != nil {
		return
	}

	wg := &sync.WaitGroup{}
	wg.Add(2)

	sig := make(chan os.Signal)
	signal.Notify(sig)

	go func() {
		for {
			s := <-sig

			if cmd.Process == nil {
				continue
			}
			cmd.Process.Signal(s)
		}
	}()

	go func() {
		io.Copy(os.Stdout, outReader)
		wg.Done()
	}()

	go func() {
		io.Copy(os.Stderr, errReader)
		wg.Done()
	}()

	tempDir(func() {
		err = cmd.Start()

		if err != nil {
			return
		}

		err = cmd.Wait()

		if err != nil {
			exitCode, err = getExitCode(err)
		}
	})

	wg.Wait()

	return
}
