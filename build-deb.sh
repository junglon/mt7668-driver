#!/bin/bash
set -e

PACKAGE=mt7668-dkms
VERSION=1.0.0
BUILD_DIR=/tmp/${PACKAGE}_build
SRC_DIR=${BUILD_DIR}/usr/src/mt7668-${VERSION}

echo Building Debian package for ${PACKAGE}_${VERSION}...

rm -rf ${BUILD_DIR}
mkdir -p ${SRC_DIR}
mkdir -p ${BUILD_DIR}/DEBIAN

rsync -a --exclude='.git' --exclude='*.o' --exclude='*.ko' --exclude='*.mod' --exclude='*.mod.c' --exclude='*.cmd' --exclude='*.deb' ./ ${SRC_DIR}/

cat << 'CTRL' > ${BUILD_DIR}/DEBIAN/control
Package: mt7668-dkms
Version: 1.0.0
Architecture: all
Maintainer: junglon <https://github.com/junglon/mt7668-driver>
Depends: dkms, build-essential
Section: kernel
Priority: optional
Description: MediaTek MT7668 SDIO Wi-Fi driver module (DKMS)
 Patched out-of-tree Linux kernel driver for MediaTek MT7668 SDIO Wi-Fi,
 modified for Linux 6.18+ and Amlogic TV boxes (e.g. ZTE B860H V5).
CTRL

cat << 'POST' > ${BUILD_DIR}/DEBIAN/postinst
#!/bin/sh
set -e
PKG_NAME=mt7668
PKG_VER=1.0.0

echo Registering mt7668 with DKMS...
dkms remove -m ${PKG_NAME} -v ${PKG_VER} --all 2>/dev/null || true
dkms add -m ${PKG_NAME} -v ${PKG_VER} || true
dkms build -m ${PKG_NAME} -v ${PKG_VER} || true
dkms install -m ${PKG_NAME} -v ${PKG_VER} || true

echo Configuring automatic kernel module loading...
echo wlan_mt7668 > /etc/modules-load.d/wlan_mt7668.conf
depmod -a
modprobe wlan_mt7668 2>/dev/null || true
POST
chmod 755 ${BUILD_DIR}/DEBIAN/postinst

cat << 'PRE' > ${BUILD_DIR}/DEBIAN/prerm
#!/bin/sh
set -e
PKG_NAME=mt7668
PKG_VER=1.0.0

echo Removing mt7668 from DKMS...
modprobe -r wlan_mt7668 2>/dev/null || true
dkms remove -m ${PKG_NAME} -v ${PKG_VER} --all 2>/dev/null || true
rm -f /etc/modules-load.d/wlan_mt7668.conf
PRE
chmod 755 ${BUILD_DIR}/DEBIAN/prerm

dpkg-deb --build ${BUILD_DIR} ${PACKAGE}_${VERSION}_all.deb
rm -rf ${BUILD_DIR}

echo Package created successfully: ${PACKAGE}_${VERSION}_all.deb
