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
$(error RELEASE not defined - needed for default paths)
endif

CODENAME = $(shell basename $(RELEASE))

POOL ?= $(FAB_PATH)/pools/$(CODENAME)
export FAB_POOL_PATH = $(POOL)

FAB_ARCH = $(shell dpkg --print-architecture)
DEBOOTSTRAP_SUITE ?= generic

# build output path
O ?= build

default: $O/rootfs.tar.gz

all: default $O/rootfs.tar.xz $O/package.list

help:
	@echo '=== Configurable variables'
	@echo 'Resolution order:'
	@echo '1) command line (highest precedence)'
	@echo '2) environment variable'
	@echo '3) built-in default (lowest precedence)'
	@echo
	@echo '# Mandatory configuration variables'
	@echo '  FAB_PATH                   $(value FAB_PATH)'
	@echo
	@echo '# Build context variables'
	@echo '  RELEASE                    $(value RELEASE)'
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
	@echo '  all'
	@echo '  clean'
	@echo '  $(value O)/required.spec'
	@echo '  $(value O)/required.list'
	@echo '  $(value O)/base.spec'
	@echo '  $(value O)/base.list'
	@echo '  $(value O)/package.list'
	@echo '  $(value O)/repo'
	@echo '  $(value O)/rootfs'
	@echo '  $(value O)/rootfs.tar.xz'
	@echo '  $(value O)/rootfs.tar.gz (default)'

clean:
	-rm -rf $O/*.spec $O/*.list $O/repo $O/rootfs $O/rootfs.tar.*

$O/required.spec: plan/required
	fab-plan-resolve --output=$O/required.spec plan/required

$O/base.spec: $O/required.spec plan/base
	fab-plan-resolve --output=$O/base.spec plan/base

$O/required.list: $O/required.spec
	awk '{print $$1}' $O/required.spec |sort > $O/required.list

$O/base.list: $O/required.list $O/base.spec
	awk '{print $$1}' $O/base.spec |sort > $O/base.list.tmp
	sdiff --suppress-common-lines $O/base.list.tmp $O/required.list | \
		awk '{print $$1}' | grep -v '>' > $O/base.list
	rm $O/base.list.tmp

$O/package.list: $O/required.list $O/base.list
	cat $O/required.list $O/base.list |sort |sed "s/=/ /" > $O/package.list

$O/repo: $O/required.spec $O/base.spec
	mkdir -p $O/repo/pool/main
	cat $O/required.spec $O/base.spec | \
		POOL_DIR=$(POOL) pool-get $O/repo/pool/main -s -t --input -
	repo-index $O/repo $(DEBOOTSTRAP_SUITE) main $(FAB_ARCH)
	repo-release `pwd`/$O/repo $(DEBOOTSTRAP_SUITE)

$O/rootfs: $O/repo $O/required.list $O/base.list
	REQUIRED_PACKAGES="$(shell cat $O/required.list |sed 's/=.*//')" \
	BASE_PACKAGES="$(shell cat $O/base.list |sed 's/=.*//')" \
	debootstrap --arch $(FAB_ARCH) $(DEBOOTSTRAP_SUITE) \
		$(shell realpath $O)/rootfs \
		file://$(shell realpath $O)/repo

	mkdir -p $O/rootfs/dev/pts
	echo $(CODENAME) > $O/rootfs/etc/debian_codename
	$(foreach u,$(wildcard unit.d/*), \
	  [ -d $(u)/overlay ] && fab-apply-overlay $(u)/overlay $O/rootfs; \
	  [ -x $(u)/conf ] && fab-chroot $O/rootfs --script $(u)/conf; \
	  )

	rm -f $O/rootfs/etc/hostname
	rm -f $O/rootfs/etc/resolv.conf
	rm -f $O/rootfs/etc/apt/sources.list
	rm -f $O/rootfs/var/log/bootstrap.log

$O/rootfs.tar.gz: $O/rootfs
	tar -C $O/rootfs --numeric-owner -zcf $O/rootfs.tar.gz .

$O/rootfs.tar.xz: $O/rootfs
	tar -C $O/rootfs --numeric-owner -Jcf $O/rootfs.tar.xz .

.PHONY: all clean default help

