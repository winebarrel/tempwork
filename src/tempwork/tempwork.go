package tempwork

import (
	"bufio"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"syscall"
)

type Tempwork struct {
	Out io.Writer
	Err io.Writer
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

	outWriter := bufio.NewWriter(tw.Out)
	defer outWriter.Flush()

	errWriter := bufio.NewWriter(tw.Err)
	defer errWriter.Flush()

	go io.Copy(outWriter, outReader)
	go io.Copy(errWriter, errReader)

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

	return
}
