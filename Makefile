# Diknom OS - pembantu build lokal.
# Build resmi dilakukan di GitHub Actions; target di sini untuk uji cepat.

BUILDROOT_DIR := buildroot
BUILDROOT_BRANCH := 2024.02.x
VERSION := $(shell cat VERSION | tr -d '[:space:]')
ARCH ?= x86_64

ifeq ($(ARCH),x86_64)
DEFCONFIG := board/diknom/x86_64/diknom_x86_64_defconfig
else ifeq ($(ARCH),i686)
DEFCONFIG := board/diknom/i686/diknom_i686_defconfig
else
$(error ARCH harus x86_64 atau i686)
endif

.PHONY: all buildroot config build clean check

all: config build

buildroot:
	@test -d $(BUILDROOT_DIR) || \
		git clone --depth 1 -b $(BUILDROOT_BRANCH) https://github.com/buildroot/buildroot.git $(BUILDROOT_DIR)
	@mkdir -p $(BUILDROOT_DIR)/board
	@ln -sfn "$(CURDIR)/board/diknom" $(BUILDROOT_DIR)/board/diknom

config: buildroot
	cd $(BUILDROOT_DIR) && make BR2_DEFCONFIG=$(DEFCONFIG) defconfig

build: config
	cd $(BUILDROOT_DIR) && DIKNOM_ARCH=$(ARCH) DIKNOM_VERSION=$(VERSION) make -j$(shell nproc)

check:
	@echo "Shellcheck-free repo: cek sintaks sh secara manual."
	@for f in board/diknom/common/rootfs-overlay/usr/bin/* board/diknom/common/rootfs-overlay/etc/init.d/*; do \
		sh -n $$f && echo "ok $$f"; \
	done

clean:
	rm -rf $(BUILDROOT_DIR) br-dl
