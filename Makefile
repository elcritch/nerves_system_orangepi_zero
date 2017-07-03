
VERSION := $(shell cat ./VERSION)
GIT_REVISION := $(shell git rev-parse HEAD)

OUTDIR ?= ~/Images

all:
	echo "Compiling version ${VERSION} from git revisioon ${GIT_REVISION}"
	mix deps.get
	mix compile
	cd .nerves/artifacts/nerves_system_orangepi_zero-${VERSION}.arm_unknown_linux_gnueabihf/ && \
	make system

copy:
	cp -v .nerves/artifacts/nerves_system_orangepi_zero-${VERSION}.arm_unknown_linux_gnueabihf/images/nerves_system_orangepi_zero.fw $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.fw
	cp -v .nerves/artifacts/nerves_system_orangepi_zero-${VERSION}.arm_unknown_linux_gnueabihf/nerves_system_orangepi_zero.tar.gz $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.tar.gz
	md5sum $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.fw $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.tar.gz

setup:
	mix local.hex
	mix local.rebar
	mix archive.install https://github.com/nerves-project/archives/raw/master/nerves_bootstrap.ez
	mix local.nerves

clean:
	rm -Rf .nerves/artifacts/
	rm -Rf _build

dist-clean: clean
	rm -Rf .nerves/
	rm -Rf _build
