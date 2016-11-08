VERSION=v0.1.6
GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)
RUNTIME_GOPATH=$(GOPATH):$(shell pwd)
SRC=$(wildcard src/tempwork/*.go)
BIN=tempwork

tempwork: main.go $(SRC)
	GOPATH=$(RUNTIME_GOPATH) go build -o $(BIN)

clean:
	rm -f tempwork *.gz
	rm -f pkg/*
	rm -f debian/tempwork.debhelper.log
	rm -f debian/tempwork.substvars
	rm -f debian/files
	rm -rf debian/tempwork/

package: clean tempwork
	gzip -c tempwork > tempwork-$(VERSION)-$(GOOS)-$(GOARCH).gz

deb:
	docker run --name docker-go-pkg-build-ubuntu-trusty -v $(shell pwd):/tmp/src docker-go-pkg-build-ubuntu-trusty make -C /tmp/src deb:docker
	docker rm docker-go-pkg-build-ubuntu-trusty

deb\:docker: clean
	export PATH=$$GOROOT/bin:$$PATH ; dpkg-buildpackage -us -uc
	mv ../tempwork_* pkg/

rpm:
	docker run --name docker-go-pkg-build-centos6 -v $(shell pwd):/tmp/src docker-go-pkg-build-centos6 make -C /tmp/src rpm:docker
	docker rm docker-go-pkg-build-centos6

rpm\:docker: clean
	cd ../ && tar zcf tempwork.tar.gz src
	mv ../tempwork.tar.gz /root/rpmbuild/SOURCES/
	cp tempwork.spec /root/rpmbuild/SPECS/
	export PATH=$$GOROOT/bin:$$PATH ; rpmbuild -ba /root/rpmbuild/SPECS/tempwork.spec
	mv /root/rpmbuild/RPMS/x86_64/tempwork-*.rpm pkg/
	mv /root/rpmbuild/SRPMS/tempwork-*.src.rpm pkg/

docker\:build\:ubuntu-trusty:
	docker build -f docker/Dockerfile.ubuntu-trusty -t docker-go-pkg-build-ubuntu-trusty .

docker\:build\:centos6:
	docker build -f docker/Dockerfile.centos6 -t docker-go-pkg-build-centos6 .

tag:
ifdef FORCE
	git tag $(VERSION) -f
else
	git tag $(VERSION)
endif
