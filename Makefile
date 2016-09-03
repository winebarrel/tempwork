VERSION=$(shell git tag | tail -n 1)
GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)
RUNTIME_GOPATH=$(GOPATH):$(shell pwd)
SRC=$(wildcard src/tempwork/*.go)
BIN=tempwork

tempwork: main.go $(SRC)
	GOPATH=$(RUNTIME_GOPATH) go build -o $(BIN)

clean:
	rm -f tempwork *.gz

package: clean tempwork
	gzip -c tempwork > tempwork-$(VERSION)-$(GOOS)-$(GOARCH).gz

deb:
	dpkg-buildpackage -us -uc
