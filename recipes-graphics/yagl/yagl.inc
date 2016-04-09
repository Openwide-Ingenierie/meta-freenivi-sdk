SUMMARY = "YaGL - OpenGL acceleration module for emulator"
LICENSE = "GPL-2.0+"
LIC_FILES_CHKSUM ??= "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI += " \
    file://0001-avoid-dependency-on-mesa.patch \
    file://0001-make-egltext.h-more-compatible-with-Mesa.patch \
    file://0001-fix-wayland-scanner-path.patch \
    file://0001-fix-libdir.patch \
    file://install-headers.patch \
    file://mesa-egl-no-headers.patch \
    file://0006-add-wl-egl-platfrom-in-eglplatform-header.patch \
    file://0010-add-missing-include.patch \
    file://95-yagl.rules \
"

BBCLASSEXTEND = "native"

DEPENDS = "udev libdrm flex bison"

PROVIDES = "virtual/libgl virtual/libgles1 virtual/libgles2 virtual/egl virtual/wayland-egl virtual/mesa"

inherit autotools-brokensep cmake pkgconfig

PACKAGECONFIG ??= " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
"

X11_DEPS = "xf86driproto virtual/libx11 libxcb libxext libxfixes"
PACKAGECONFIG[x11] = "-DPLATFORM_X11=1,-DPLATFORM_X11=0,${X11_DEPS},libx11 dri2proto"
PACKAGECONFIG[wayland] = "-DPLATFORM_WAYLAND=1 -DPLATFORM_GBM=1, -DPLATFORM_WAYLAND=0 -DPLATFORM_GBM=0,wayland"

OECMAKE_CXX_FLAGS += "-fpermissive"

do_install_append () {
    ln -s libEGL.so.1.0 ${D}${libdir}/libEGL.so.1.0.0
    ln -s libGLESv2.so.2.0 ${D}${libdir}/libGLESv2.so.2.0.0
    ln -s libGLESv2.so.2.0.0 ${D}${libdir}/libGL.so.1.2.0

    install -d ${D}${libdir}/udev/rules.d
    install -m 644 ${WORKDIR}/95-yagl.rules ${D}${libdir}/udev/rules.d
}


# same as mesa
#because we cannot rely on the fact that all apps will use pkgconfig,
#make eglplatform.h independent of MESA_EGL_NO_X11_HEADER
do_install_append() {
    sed -i -e 's/^#ifdef MESA_EGL_NO_X11_HEADERS$/#if defined(MESA_EGL_NO_X11_HEADERS) || ${@bb.utils.contains('PACKAGECONFIG', 'x11', '0', '1', d)}/' ${D}${includedir}/EGL/eglplatform.h
}

FILES_${PN} = "${libdir}/udev/ ${libdir}/*.so.*"
FILES_${PN}-dev = "${includedir}/* ${libdir}/pkgconfig/* ${libdir}/*.so"

RPROVIDES_${PN} += "libgles2 libegl"

RDEPENDS_${PN}-dev += "${PN}"

COMPATIBLE_MACHINE = "(emulator-arm|emulator-x86)"
