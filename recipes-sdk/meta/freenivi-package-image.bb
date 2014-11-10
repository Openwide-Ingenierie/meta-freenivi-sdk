DESCRIPTION = "FreeNivi Package Image."
LICENSE = "MIT"

inherit freenivi
inherit freenivi_package_image

IMAGE_INSTALL += "openssh-sftp"

IMAGE_INSTALL_append_x86 = " mesa-driver-i915 "
IMAGE_INSTALL_append_x86-64 = " mesa-driver-i915 "
