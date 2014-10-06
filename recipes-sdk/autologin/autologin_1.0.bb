SUMMARY = "Autologin tool"
DESCRIPTION = "A simple tool to login to root with no prompt based on systemd rules"
PACKAGES = "${PN}"
PR = "r0"

LICENSE = "MIT"

DEPENDS = "sed-native"
RDEPENDS_${PN} = "systemd"

SRC_URI = " \
           file://autologin@.service \
           "

LIC_FILES_CHKSUM = "file://${WORKDIR}/autologin@.service;md5=691885ec6c1142d5883a88725ee1f96c"

S = "${WORKDIR}"

SDK_EMULATOR_USER ?= "root"

do_install () {
  install -d 0755 ${D}/lib/systemd/system
  install -m 0644 ${WORKDIR}/autologin@.service ${D}/lib/systemd/system
  sed -i 's/@@USERNAME@@/${SDK_EMULATOR_USER}/' ${D}/lib/systemd/system/autologin@.service
}

pkg_postinst_${PN} () {
  rm -rf /etc/systemd/system/getty.target.wants/getty@tty1.service
  ln -s ${systemd_unitdir}/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
}

pkg_prerm_${PN} () {
  rm -rf /etc/systemd/system/getty.target.wants/getty@tty1.service
  ln -s ${systemd_unitdir}/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
}

PACKAGES = "${PN}"
FILES_${PN} = "/lib/systemd/system/autologin@.service"
