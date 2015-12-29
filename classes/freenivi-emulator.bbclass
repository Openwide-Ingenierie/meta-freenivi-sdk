# set password to freenivi (obtained by "openssl passwd -1 freenivi)
inherit extrausers
EXTRA_USERS_PARAMS = " \
    usermod -p '\$1\$s2pp8yHi\$3N6qudJI2p2.qFqQ81qvK0' root; \
    "

FREENIVI_EMULATOR_KERNEL_CMDLINE ?= " \
    ip=dhcp \
    console=tty1 \
    video=LVDS-1:${RESOLUTION}-32@60 \
"

FREENIVI_EMULATOR_QEMU_OPTIONS ?= " \
    -kernel ${KERNEL} \
    -hda ${ROOTFS} \
    -m ${MEMORY} \
    -display sdl \
    -soundhw all \
    -serial stdio \
    -enable-vigs -vigs-backend gl \
    -vga none \
    -append '${FREENIVI_EMULATOR_KERNEL_CMDLINE} ${CMDLINE}' \
"

FREENIVI_EMULATOR_QEMU_emulator-x86 = "qemu-system-i386"
FREENIVI_EMULATOR_QEMU_OPTIONS_append_emulator-x86 = " \
    -device e1000,netdev=freenivi \
    -netdev user,id=freenivi,hostfwd=tcp::${SSHPORT}-:22,hostfwd=tcp::10023-:10023,hostfwd=tcp::10024-:10024,hostfwd=tcp::10025-:10025 \
"
FREENIVI_EMULATOR_KERNEL_CMDLINE_append_emulator-x86 = " \
    root=/dev/hda rw \
    console=ttyS0 \
"

FREENIVI_EMULATOR_QEMU_emulator-arm = "qemu-system-arm"
FREENIVI_EMULATOR_QEMU_OPTIONS_append_emulator-arm = " \
    -machine versatilepb \
    -net nic,model=smc91c111 \
    -net user,hostfwd=tcp::${SSHPORT}-:22,hostfwd=tcp::10023-:10023,hostfwd=tcp::10024-:10024,hostfwd=tcp::10025-:10025 \
"
FREENIVI_EMULATOR_KERNEL_CMDLINE_append_emulator-arm = " \
    root=/dev/sda rw \
    console=ttyAMA0 \
"

# check if MACHINE is an emulator (quit otherwise)
addtask not_emulable before do_fetch
python do_not_emulable () {
    if not d.getVar("MACHINE","").startswith('emulator'):
        bb.fatal("ERROR: Selected machine is not an emulator")
}

inherit freenivi_package

FREENIVI_PACKAGE_EMULATOR_FILL_DATA = "freenivi_emulator_fill_data"

addtask freenivi_package_emu after do_rootfs before do_build

fakeroot freenivi_emulator_fill_data() {
        # copy the image into the package
    	mkdir -p ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_EMULATOR_NAME}/data/${FREENIVI_PACKAGE_EMULATOR_DIRECTORY}
    	cp ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.ext4 ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_EMULATOR_NAME}/data/${FREENIVI_PACKAGE_EMULATOR_DIRECTORY}
    	cp ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_EMULATOR_NAME}/data/${FREENIVI_PACKAGE_EMULATOR_DIRECTORY}
        cat << "EOF" > ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_EMULATOR_NAME}/data/${FREENIVI_PACKAGE_EMULATOR_DIRECTORY}/emulator
#! /bin/bash

# get paths
EMULATOR_TARGET_DIRECTORY="$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)"
SDK_SYSROOT_DIRECTORY="${EMULATOR_TARGET_DIRECTORY%/*}/sysroots/${SDK_ARCH}${SDK_VENDOR}-${SDK_OS}"
QEMU_PATH="${SDK_SYSROOT_DIRECTORY}/usr/bin/"
QEMU="${QEMU_PATH}/${FREENIVI_EMULATOR_QEMU}"
KERNEL=${EMULATOR_TARGET_DIRECTORY}/${KERNEL_IMAGETYPE}
ROOTFS=${EMULATOR_TARGET_DIRECTORY}/${IMAGE_LINK_NAME}.ext4

usage ()
{
    cat << EOT
Usage: $(basename $0) [options]

Emulator options:
 -graphics-acceleration
                enable 3D graphics acceleration (VIGS + YaGL)
 -ssh-port      set the ssh connection port (must be a free port of the host)
 -resolution    set the emulator display resolution (<width>x<heigth>)
 -rootfs	set the rootfs to use (path to image)

EOT
    ${QEMU} --help | tail -n +6
 }

# get options
MEMORY=256
SSHPORT=10022
RESOLUTION="800x600"
graphics_acceleration=0
while [ $# -gt 0 ]; do
    case "$1" in
        -graphics-acceleration ) graphics_acceleration=1; shift;;
        -ssh-port ) SSHPORT="$2"; shift 2;;
        -resolution ) RESOLUTION="$2"; shift 2;;
	-rootfs ) ROOTFS="$2"; shift 2;;
        -h | --help ) usage; exit;;
        * ) OPTIONS="${OPTIONS} $1"; shift;
    esac
done

if [ $graphics_acceleration -eq 1 ]; then
    OPTIONS="${OPTIONS} -enable-yagl -yagl-backend vigs"
else
    CMDLINE="modprobe.blacklist=yagl"
fi
OPTIONS="${FREENIVI_EMULATOR_QEMU_OPTIONS} ${OPTIONS}"

# execute
cmd="${QEMU} ${OPTIONS}"
echo $cmd
eval "<&0 $cmd &"
QEMU_PID=$!
trap ">&2 echo 'Emulator stopped'; kill -9 ${QEMU_PID}" SIGTERM
wait ${QEMU_PID}
EOF
        chmod +x ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_EMULATOR_NAME}/data/${FREENIVI_PACKAGE_EMULATOR_DIRECTORY}/emulator
}
