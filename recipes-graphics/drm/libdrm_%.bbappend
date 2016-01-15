FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# files/00*.patches: vigs patches from Tizen:
# https://build.tizen.org/package/show?package=libdrm&project=Tizen%3A3.0%3AIVI
# only apply on 2.4.58
# need to rebuild the patch for current version ie
# apply patches on libdrm-2.4.58 (git am files/00*.patches)
# merge to libdrm-2.4.62 in 'vigs-2.4.62' branch then:
# git diff libdrm-2.4.62..vigs-2.4.62 > files/vigs-2.4.62.patch
SRC_URI_append_emulator = " file://vigs-${PV}.patch"

PACKAGES_prepend_emulator = "${PN}-vigs "

RRECOMMENDS_${PN}-drivers_append_emulator = " ${PN}-vigs"

FILES_${PN}-vigs_emulator = "${libdir}/libdrm_vigs.so.*"
