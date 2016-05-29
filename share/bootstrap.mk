#!/usr/bin/make -f
# Copyright (c) TurnKey GNU/Linux - http://www.turnkeylinux.org
#
# This file is part of Fab
#
# Fab is free software; you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.

_self = $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
FAB_SHARE_PATH ?= $(shell dirname $(_self))
BOOTSTRAP_SHARE_PATH ?= $(FAB_SHARE_PATH)/bootstrap
BSP = $(BOOTSTRAP_SHARE_PATH)

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

STAMPS_DIR = $O/stamps

all: $O/bootstrap.tar.gz

#clean
define clean/body 
	-rm -rf $O/*.spec $O/bootstrap $O/bootstrap.tar.gz $O/repo $(STAMPS_DIR)
endef

clean:
	$(clean/pre)
	$(clean/body)
	$(clean/post)

define help/body
	@echo '=== Configurable variables'
	@echo 'Resolution order:'
	@echo '1) command line (highest precedence)'
	@echo '2) product Makefile'
	@echo '3) environment variable'
	@echo '4) built-in default (lowest precedence)'
	@echo
	@echo '# Mandatory configuration variables:'
	@echo '  FAB_PATH                   $(value FAB_PATH)'
	@echo '  RELEASE                    $(value RELEASE)'
	@echo
	@echo '# Build context variables    [VALUE]'
	@echo '  FAB_ARCH                   $(value FAB_ARCH)'
	@echo '  POOL                       $(value POOL)/'
	@echo '  DEBOOTSTRAP_SUITE          $(value DEBOOTSTRAP_SUITE)'
	@echo
	@echo '# Product output variables   [VALUE]'
	@echo '  O                          $(value O)/'
	@echo
	@echo '=== Usage'
	@echo '# remake target and the targets that depend on it'
	@echo '$$ rm $(value STAMPS_DIR)/<target>; make <target>'
	@echo
	@echo '# build a target (default: bootstrap.tar.gz)'
	@echo '$$ make [target] [O=path/to/build/dir]'
	@echo
	@echo '  clean            # clean all build targets'
	@echo '  required.spec    # the spec of debootstrap REQUIRED_PACKAGES'
	@echo '  base.spec        # the spec of debootstrap BASE_PACKAGES'

	@echo '  repo             # build temporary local repository for debootstrap'
	@echo '  bootstrap        # build bootstrap with debootstrap from repo'
	@echo '  bootstrap.tar.gz # build tarball from bootstrap'
endef

help:
	$(help/pre)
	$(help/body)
	$(help/post)

debug:
	$(foreach v, $V, $(warning $v = $($v)))
	@true

#required.spec
required.spec/deps ?= plan/required
define required.spec/body
	fab-plan-resolve --output=$O/required.spec plan/required
endef

#base.spec
base.spec/deps ?= plan/base $(STAMPS_DIR)/required.spec
define base.spec/body
	fab-plan-resolve --output=$O/base.spec plan/base
endef

#repo
repo/deps ?= $(STAMPS_DIR)/required.spec $(STAMPS_DIR)/base.spec 
define repo/body
	mkdir -p $O/repo/pool/main
	cat $O/required.spec $O/base.spec | \
		POOL_DIR=$(POOL) pool-get $O/repo/pool/main --strict --tree --input - 

	repo-index $O/repo $(DEBOOTSTRAP_SUITE) main $(FAB_ARCH)
	repo-release `pwd`/$O/repo $(DEBOOTSTRAP_SUITE)
endef

#bootstrap
bootstrap/deps ?= $(STAMPS_DIR)/repo
define bootstrap/body
	$(BSP)/exclude_spec.py $O/base.spec $O/required.spec > $O/base-excl-req.spec
	$(BSP)/debootstrap.py $(FAB_ARCH) $(DEBOOTSTRAP_SUITE) $O/bootstrap `pwd`/$O/repo $O/required.spec $O/base-excl-req.spec

	fab-chroot $O/bootstrap --script $(BSP)/cleanup.sh
	fab-chroot $O/bootstrap 'echo "do_initrd = Yes" > /etc/kernel-img.conf'
endef

$O/bootstrap: $(bootstrap/deps) $(bootstrap/deps/extra)
	$(bootstrap/pre)
	$(bootstrap/body)
	$(bootstrap/post)

bootstrap: $O/bootstrap

#bootstrap.tar.gz
bootstrap.tar.gz/deps ?= $(STAMPS_DIR)/bootstrap
define bootstrap.tar.gz/body
	tar -C $O/bootstrap -zcf $O/bootstrap.tar.gz .
endef

$O/bootstrap.tar.gz: $(bootstrap.tar.gz/deps) $(bootstrap.tar.gz/deps/extra)
	$(bootstrap.tar.gz/pre)
	$(bootstrap.tar.gz/body)
	$(bootstrap.tar.gz/post)

bootstrap.tar.gz: $O/bootstrap.tar.gz

# construct target rules
define _stamped_target
$1: $(STAMPS_DIR)/$1

$(STAMPS_DIR)/$1: $$($1/deps) $$($1/deps/extra)
	@mkdir -p $(STAMPS_DIR)
	$$($1/pre)
	$$($1/body)
	$$($1/post)
	touch $$@
endef

STAMPED_TARGETS := required.spec base.spec repo bootstrap
$(foreach target,$(STAMPED_TARGETS),$(eval $(call _stamped_target,$(target))))

.PHONY: clean $(STAMP_TARGETS)

