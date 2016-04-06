DESCRIPTION = "Freenivi package image."
LICENSE = "MIT"

inherit freenivi-image freenivi-package-image

# Raspberrypi has specific format so package it
FREENIVI_PACKAGE_IMAGE_FSTYPE_raspberrypi ?= "ext3"
FREENIVI_PACKAGE_IMAGE_SDIMG_raspberrypi ?= "rpi-sdimg"

FREENIVI_PACKAGE_IMAGE_FSTYPE_raspberrypi2 ?= "ext3"
FREENIVI_PACKAGE_IMAGE_SDIMG_raspberrypi2 ?= "rpi-sdimg"

