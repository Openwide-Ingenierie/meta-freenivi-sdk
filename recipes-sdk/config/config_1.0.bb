SUMMARY = "SDK Configuration files"
DESCRIPTION = "All configuration files that needed to be in the rootfs for the SDK"
LICENSE = "MIT" 
LIC_FILES_CHKSUM = "file://.profile;md5=001c16a81b674877f74bf8783ef7dfca"

SRC_URI = "file://.profile"

S = "${WORKDIR}"

do_install_append () {
        install -d 0755 ${D}/sdk/
	install -m 0644 ${S}/.profile ${D}/sdk/
}

SDK_EMULATOR_USER ?= "root"

pkg_postinst_${PN} () {
        mv /sdk/.profile ~${SDK_EMULATOR_USER}
}

PACKAGES = "${PN}"
FILES_${PN} = "/sdk"

