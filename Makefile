#!/usr/bin/make -f
# Copyright (c) TurnKey GNU/Linux - http://www.turnkeylinux.org
#
# This file is part of Fab
#
# Fab is free software; you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.

ifndef FAB_PATH
$(error FAB_PATH not defined - needed for default paths)
endif

ifndef RELEASE
$(error RELEASE not defined)
endif

DISTRO = $(shell dirname $(RELEASE))
CODENAME = $(shell basename $(RELEASE))

POOL ?= $(FAB_PATH)/pools/$(CODENAME)
export FAB_POOL_PATH = $(POOL)

FAB_ARCH = $(shell dpkg --print-architecture)
DEBOOTSTRAP_SUITE ?= generic

# build output path
O ?= build

all: $O/rootfs.tar.gz

help:
	@echo '=== Configurable variables'
	@echo 'Resolution order:'
	@echo '1) command line (highest precedence)'
	@echo '2) environment variable'
	@echo '3) built-in default (lowest precedence)'
	@echo
	@echo '# Mandatory configuration variables'
	@echo '  RELEASE                    $(value RELEASE)'
	@echo '  FAB_PATH                   $(value FAB_PATH)'
	@echo
	@echo '# Build context variables'
	@echo '  POOL                       $(value POOL)'
	@echo '  FAB_ARCH                   $(value FAB_ARCH)'
	@echo '  DEBOOTSTRAP_SUITE          $(value DEBOOTSTRAP_SUITE)'
	@echo
	@echo '# Product output variables'
	@echo '  O                          $(value O)'
	@echo
	@echo '=== Usage'
	@echo 'Build a target'
	@echo '$$ make [target] [O=path/to/build/dir]'
	@echo
	@echo '  clean'
	@echo '  $(value O)/required.spec'
	@echo '  $(value O)/base.spec'
	@echo '  $(value O)/repo'
	@echo '  $(value O)/rootfs'
	@echo '  $(value O)/rootfs.tar.gz (default)'

clean:
	-rm -rf $O/*.spec $O/repo $O/rootfs $O/rootfs.tar.gz

$O/required.spec: plan/required
	fab-plan-resolve --output=$O/required.spec plan/required

$O/base.spec: $O/required.spec plan/base
	fab-plan-resolve --output=$O/base-full.spec plan/base
	awk '{print $$1}' $O/base-full.spec |sort > $O/base.tmp
	awk '{print $$1}' $O/required.spec |sort > $O/required.tmp
	sdiff --suppress-common-lines $O/base.tmp $O/required.tmp | \
		awk '{print $$1}' | grep -v '>' > $O/base.spec
	rm $O/base.tmp $O/required.tmp

$O/repo: $O/required.spec $O/base.spec
	mkdir -p $O/repo/pool/main
	cat $O/required.spec $O/base.spec | \
		POOL_DIR=$(POOL) pool-get $O/repo/pool/main -s -t --input -
	repo-index $O/repo $(DEBOOTSTRAP_SUITE) main $(FAB_ARCH)
	repo-release `pwd`/$O/repo $(DEBOOTSTRAP_SUITE)

$O/rootfs: $O/repo
	bin/debootstrap.py $(FAB_ARCH) $(DEBOOTSTRAP_SUITE) \
		$O/rootfs `pwd`/$O/repo $O/required.spec $O/base.spec
	fab-chroot $O/rootfs --script bin/cleanup.sh
	fab-chroot $O/rootfs 'echo "do_initrd = Yes" > /etc/kernel-img.conf'

$O/rootfs.tar.gz: $O/rootfs
	tar -C $O/rootfs -zcf $O/rootfs.tar.gz .


.PHONY: all clean help

