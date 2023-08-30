#!/bin/sh

set -eux

git clone --depth 1 --single-branch https://github.com/tiann/KernelSU
rm -fr drivers/kernelsu
mv KernelSU/kernel drivers/kernelsu
rm -fr KernelSU

sed -i -e 's/default y/default n/g' drivers/kernelsu/Kconfig

patch -p1 --ignore-whitespace --force << 'EOF'
:100644 100644 5ba201cf259f 000000000000 M	drivers/kernelsu/Makefile

diff --git a/drivers/kernelsu/Makefile b/drivers/kernelsu/Makefile
index 5ba201cf259f..247a2d0c4d57 100644
--- a/drivers/kernelsu/Makefile
+++ b/drivers/kernelsu/Makefile
@@ -14,13 +14,3 @@ obj-y += kernel_compat.o
 obj-y += selinux/
-# .git is a text file while the module is imported by 'git submodule add'.
-ifeq ($(shell test -e $(srctree)/$(src)/../.git; echo $$?),0)
-KSU_GIT_VERSION := $(shell cd $(srctree)/$(src); /usr/bin/env PATH="$$PATH":/usr/bin:/usr/local/bin git rev-list --count HEAD)
-# ksu_version: major * 10000 + git version + 200 for historical reasons
-$(eval KSU_VERSION=$(shell expr 10000 + $(KSU_GIT_VERSION) + 200))
-$(info -- KernelSU version: $(KSU_VERSION))
-ccflags-y += -DKSU_VERSION=$(KSU_VERSION)
-else # If there is no .git file, the default version will be passed.
-$(warning "KSU_GIT_VERSION not defined! It is better to make KernelSU a git submodule!")
 ccflags-y += -DKSU_VERSION=16
-endif
 
EOF

DRIVER_MAKEFILE=drivers/Makefile
DRIVER_KCONFIG=drivers/Kconfig
grep -q "kernelsu" "$DRIVER_MAKEFILE" || printf "obj-\$(CONFIG_KSU) += kernelsu/\n" >> "$DRIVER_MAKEFILE"
grep -q "kernelsu" "$DRIVER_KCONFIG" || sed -i "/endmenu/i\\source \"drivers/kernelsu/Kconfig\"" "$DRIVER_KCONFIG"
