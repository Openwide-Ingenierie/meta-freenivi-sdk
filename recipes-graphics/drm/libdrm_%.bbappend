FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PACKAGES_append_emulator = " ${PN}-vigs"

RRECOMMENDS_${PN}-drivers_append_emulator = " ${PN}-vigs"

FILES_${PN}-vigs_append_emulator = " ${libdir}/libdrm_vigs.so.*"
