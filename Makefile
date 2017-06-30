
VERSION := $(shell cat ./VERSION)
GIT_REVISION := $(shell git rev-parse HEAD)

OUTDIR ?= ~/Images

copy:
	cp -v .nerves/artifacts/nerves_system_orangepi_zero-0.1.1.arm_unknown_linux_gnueabihf/images/nerves_system_orangepi_zero.fw $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.fw
	cp -v .nerves/artifacts/nerves_system_orangepi_zero-0.1.1.arm_unknown_linux_gnueabihf/nerves_system_orangepi_zero.tar.gz $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.tar.gz
	md5sum $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.fw $(OUTDIR)/nerves_system_orangepi_zero-v${VERSION}.tar.gz

all:
	echo "Compiling version ${VERSION} from git "
	mix deps.get
	mix compile
	cd .nerves/artifacts/nerves_system_orangepi_zero-${VERSION}.arm_unknown_linux_gnueabihf/ && \
	make system
