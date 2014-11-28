FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_class-nativesdk = " file://vigs-yagl.patch "

export LIBS = "-ldl"
