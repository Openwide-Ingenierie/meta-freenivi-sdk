PREFERRED_PROVIDER_virtual/libgl = "yagl_%"
PREFERRED_PROVIDER_virtual/libgles1 = "yagl_%"
PREFERRED_PROVIDER_virtual/libgles2 = "yagl_%"
PREFERRED_PROVIDER_virtual/egl = "yagl_%"
PREFERRED_PROVIDER_virtual/mesa = "yagl_%" 
PREFERRED_PROVIDER_virtual/wayland-egl = "yagl_%"

PREFERRED_PROVIDER_virtual/kernel = "linux-yocto"
PREFERRED_VERSION_linux-yocto ?= "3.14%"

XSERVER = " \
    xserver-xorg \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'mesa-driver-swrast', '', d)} \
    xf86-input-vmmouse \
    xf86-input-keyboard \
    xf86-input-evdev \
    xf86-video-cirrus \
    xf86-video-fbdev \
    xf86-video-vmware \
"

MACHINEOVERRIDES =. "emulator:"
