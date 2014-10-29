DESCRIPTION = "FreeNivi Emulator."

IMAGE_FEATURES += "splash package-management ssh-server-dropbear"

LICENSE = "MIT"

# inherit from freenivi-emualtor instead of core-image.
inherit freenivi_emulator

IMAGE_INSTALL += "autologin config"

IMAGE_INSTALL += "qtquickcontrols-qmlplugins qtdeclarative-qmlplugins"

# enable llvmpipe
IMAGE_INSTALL += "mesa-driver-swrast libegl-gallium libgbm-gallium"

IMAGE_INSTALL += "tzdata tzdata-europe"
IMAGE_INSTALL += "avahi-utils"
IMAGE_INSTALL += "procps"
IMAGE_INSTALL += "linuxconsoletools"
IMAGE_INSTALL += "openssl ca-certificates"

#IMAGE_INSTALL += "edje-utils elementary-tests"
IMAGE_INSTALL += "cinematicexperience"
IMAGE_INSTALL += "qtwebkit"
IMAGE_INSTALL += "qtwebkit-examples-examples"

#IMAGE_INSTALL += "bluez5 bluez5-obex"
IMAGE_INSTALL += "ofono"
#IMAGE_INSTALL += "connman"
IMAGE_INSTALL += "weston weston-examples"

#Install tools
IMAGE_INSTALL += "connman-client"

#Add i915 mesa driver for x86 architecture
#IMAGE_INSTALL_append_x86 = " mesa-driver-i915 "
#IMAGE_INSTALL_append_x86-64 = " mesa-driver-i915 "
IMAGE_INSTALL_append_x86 = " mesa-driver-swrast"

#QT Wayland
IMAGE_INSTALL += "qtwayland qtwayland-plugins "

#Fonts
IMAGE_INSTALL += "ttf-bitstream-vera qtbase-fonts-ttf-dejavu"

#Efl
IMAGE_INSTALL += "elementary elementary-tests edje-utils evas"

#Bench efl
PREFERRED_VERSION_expedite = "1.11"
IMAGE_INSTALL += "expedite perf"

#Carrousel demo app
IMAGE_INSTALL += "carrousel"

python do_not_emulable () {
    if not d.getVar("MACHINE","").startswith('qemu'):
        bb.fatal("ERROR: Selected machine is not an emulator")
}
addtask not_emulable before do_fetch
