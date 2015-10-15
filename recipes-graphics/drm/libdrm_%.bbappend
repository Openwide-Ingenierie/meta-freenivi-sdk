FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI_append_emulator = " file://vigs.patch"

PACKAGES_append_emulator = " ${PN}-vigs"

RRECOMMENDS_${PN}-drivers_append_emulator = " ${PN}-vigs"

FILES_${PN}-vigs_append_emulator = " ${libdir}/libdrm_vigs.so.*"
