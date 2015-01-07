DESCRIPTION = "Freenivi Emulator."
LICENSE = "MIT"

inherit freenivi-image
inherit freenivi-emulator

set_emulator_profile () {
    cat << "EOF" > ${IMAGE_ROOTFS}/etc/profile.d/weston.sh
# create and/or set ${XDG_RUNTIME_DIR}
if test -z "${XDG_RUNTIME_DIR}"; then
    export XDG_RUNTIME_DIR=/run/user/${UID}
    if ! test -d "${XDG_RUNTIME_DIR}"; then
        mkdir "${XDG_RUNTIME_DIR}"
        chmod 0700 "${XDG_RUNTIME_DIR}"
    fi
fi

if test `grep -c "yagl" /proc/cmdline` -eq 0; then
    # set default platform for Qt application to wayland-egl
    export QT_QPA_PLATFORM=wayland-egl
    # set default engine for elf application to wayland-egl
    export ELM_ENGINE=wayland-egl
else
    # set to software if yagl/vigs is not enable
    export QT_QPA_PLATFORM=wayland
    export ELM_ENGINE=wayland-shm
fi

# launch weston on login (tty1 only)
if test "$(tty)" = "/dev/tty1"; then
    if test `grep -c "yagl" /proc/cmdline` -eq 0; then 
        /usr/bin/weston --log=/var/log/weston.log
    else
        /usr/bin/weston -Bfbdev-backend.so --log=/var/log/weston.log
    fi
fi
EOF
}

ROOTFS_POSTPROCESS_COMMAND += "set_emulator_profile; "
