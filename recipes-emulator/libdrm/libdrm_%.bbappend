# We use the tizen version to get libdrm_vigs

SRC_URI = "git://review.tizen.org/platform/upstream/libdrm;tag=2a8aaf2b9f403cde35b88653394906af578845ab;nobranch=1"

SRCREV = ""

PACKAGES =+ "${PN}-vigs"

RRECOMMENDS_${PN}-drivers += "${PN}-vigs"

FILES_${PN}-vigs = "${libdir}/libdrm_vigs.so.*"

S = "${WORKDIR}/git"
