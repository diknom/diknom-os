# DikNom OS - pembantu build lokal.
# Build resmi di GitHub Actions; target ini untuk uji cepat di mesin Linux.

BUILDROOT_DIR   := buildroot
BUILDROOT_BRANCH:= 2024.02.x
VERSION         := $(shell tr -d '[:space:]' < VERSION)
FLAVOR          ?= normal
ARCH            ?= x86_64

ifeq ($(FLAVOR),lite)
  DEFCONFIG := board/diknom/lite/$(ARCH)/diknom_lite_$(ARCH)_defconfig
else ifeq ($(FLAVOR),normal)
  DEFCONFIG := board/diknom/normal/$(ARCH)/diknom_$(ARCH)_defconfig
else
  $(error FLAVOR harus lite atau normal)
endif

.PHONY: all buildroot config check build clean

all: check build

check:
	@for f in board/diknom/common/rootfs-overlay/usr/bin/* \
	          board/diknom/common/rootfs-overlay/etc/init.d/* \
	          board/diknom/common/post-build.sh \
	          board/diknom/common/post-image.sh \
	          tools/verify-config.sh; do \
		sh -n $$f || exit 1; echo "sintaks ok $$f"; \
	done

buildroot:
	@test -d $(BUILDROOT_DIR) || \
		git clone --depth 1 -b $(BUILDROOT_BRANCH) https://github.com/buildroot/buildroot.git $(BUILDROOT_DIR)
	@mkdir -p $(BUILDROOT_DIR)/board
	@ln -sfn "$(CURDIR)/board/diknom" $(BUILDROOT_DIR)/board/diknom

config: buildroot
	cd $(BUILDROOT_DIR) && make BR2_DEFCONFIG=$(DEFCONFIG) defconfig
	bash tools/verify-config.sh $(DEFCONFIG) $(BUILDROOT_DIR)/.config

build: config
	cd $(BUILDROOT_DIR) && \
		DIKNOM_ARCH=$(ARCH) DIKNOM_FLAVOR=$(FLAVOR) DIKNOM_VERSION=$(VERSION) make -j$$(nproc)

clean:
	rm -rf $(BUILDROOT_DIR) br-dl
