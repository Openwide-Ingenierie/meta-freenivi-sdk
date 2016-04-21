DESCRIPTION = "Freenivi package demo image."
LICENSE = "MIT"

inherit freenivi-dev-image freenivi-package-image

IMAGE_BASENAME="freenivi-demo-image"

IMAGE_INSTALL += " \
        ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demos-wayland', '', d)} \
	${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'demos-x11', '', d)} \
"

