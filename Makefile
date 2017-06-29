
VERSION := $(shell cat ./VERSION)
GIT_REVISION := $(shell git rev-parse HEAD)

all:

	echo "Compiling version ${VERSION} from git revisioon ${GIT_REVISION}"
	mix deps.get
	mix compile

	cd .nerves/artifacts/nerves_system_orangepi_zero-${VERSION}.arm_unknown_linux_gnueabihf/

	make system
