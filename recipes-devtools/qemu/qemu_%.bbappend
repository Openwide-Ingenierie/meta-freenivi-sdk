FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_class-nativesdk = " \
    file://0001-vigs-yagl.patch \
    file://0002-comment-out-versatilepb-lcd-screen.patch \
"

export LIBS = "-ldl"