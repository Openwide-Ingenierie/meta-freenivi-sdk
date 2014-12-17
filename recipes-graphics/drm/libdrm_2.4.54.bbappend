FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI += "file://vigs.patch "

PACKAGES =+ "${PN}-vigs"

RRECOMMENDS_${PN}-drivers = "${PN}-vigs"

FILES_${PN}-vigs = "${libdir}/libdrm_vigs.so.*"
