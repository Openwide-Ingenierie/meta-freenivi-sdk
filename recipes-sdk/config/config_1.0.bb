SUMMARY = "SDK Configuration files"
DESCRIPTION = "All configuration files that needed to be in the rootfs for the SDK"
LICENSE = "MIT" 
LIC_FILES_CHKSUM = "file://.profile;md5=6d6af62eac57c4e3faeda538d16db44e"

SRC_URI = "file://.profile"

S = "${WORKDIR}"

do_install_append () {
        install -d 0755 ${D}/sdk/
	install -m 0644 ${S}/.profile ${D}/sdk/
}

SDK_EMULATOR_USER ?= "root"

pkg_postinst_${PN} () {
        cp /sdk/.profile ~${SDK_EMULATOR_USER}
}

PACKAGES = "${PN}"
FILES_${PN} = "/sdk"

