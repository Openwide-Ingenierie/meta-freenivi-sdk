DESCRIPTION = "FreeNivi Emulator."
LICENSE = "MIT"

# inherit from freenivi-emualtor instead of core-image.
inherit freenivi
inherit freenivi_emulator

# enable llvmpipe
IMAGE_INSTALL += "mesa-driver-swrast libegl-gallium libgbm-gallium"

IMAGE_INSTALL += "qtquickcontrols-qmlplugins qtdeclarative-qmlplugins"

IMAGE_INSTALL_append_x86 = " mesa-driver-swrast"

python do_not_emulable () {
    if not d.getVar("MACHINE","").startswith('qemu'):
        bb.fatal("ERROR: Selected machine is not an emulator")
}
addtask not_emulable before do_fetch
