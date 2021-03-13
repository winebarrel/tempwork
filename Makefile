VERSION=v0.1.7
GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)

.PHONY: all
all:
	go build ./cmd/tempwork

.PHONY: clean
clean:
	rm -f tempwork *.gz
	rm -f pkg/*
	rm -f debian/tempwork.debhelper.log
	rm -f debian/tempwork.substvars
	rm -f debian/files
	rm -rf debian/tempwork/

.PHONY: package
package: clean all
	gzip -c tempwork > tempwork-$(VERSION)-$(GOOS)-$(GOARCH).gz

.PHONY: deb
deb:
	docker run --rm -v $(shell pwd):/tmp/src ubuntu:bionic \
	bash -c 'apt-get update && apt-get install -y make && make -C /tmp/src deb-docker'

.PHONY: deb-docker
deb-docker: clean
	apt-get install -y debhelper software-properties-common
	add-apt-repository ppa:longsleep/golang-backports
	apt update
	apt-get install -y golang-go
	dpkg-buildpackage -us -uc
	mv ../tempwork_* pkg/

.PHONY: rpm
rpm:
	docker run --rm -v $(shell pwd):/tmp/src centos:centos8 \
		bash -c 'yum install -y make && make -C /tmp/src rpm-docker'

.PHONY: rpm-docker
rpm-docker: clean
	yum install -y rpmdevtools golang
	rpmdev-setuptree
	cd ../ && tar zcf tempwork.tar.gz src
	mv ../tempwork.tar.gz /root/rpmbuild/SOURCES/
	cp tempwork.spec /root/rpmbuild/SPECS/
	export PATH=$$GOROOT/bin:$$PATH ; rpmbuild -ba /root/rpmbuild/SPECS/tempwork.spec
	mv /root/rpmbuild/RPMS/x86_64/tempwork-*.rpm pkg/
	mv /root/rpmbuild/SRPMS/tempwork-*.src.rpm pkg/

.PHONY: docker-build-ubuntu
docker-build-ubuntu:
	docker build -f docker/Dockerfile.ubuntu-trusty -t docker-go-pkg-build-ubuntu-trusty .
