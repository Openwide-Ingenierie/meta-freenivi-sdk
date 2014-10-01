inherit core-image

# tools needed for deploy
IMAGE_FEATURES_remove = "ssh-server-dropbear"
IMAGE_FEATURES += "ssh-server-openssh"
IMAGE_INSTALL += "openssh-sftp-server qtbase qtbase-fonts qtbase-plugins qtbase-tools"

# problably only right for qemux86
EMULATOR_ROOTFS = "${IMAGE_LINK_NAME}.ext3"
EMULATOR_KERNEL = "bzImage"

SDK_TARGET = "${REAL_MULTIMACH_TARGET_SYS}"

INHERIT += "extrausers"
EXTRA_USERS_PARAMS = " \
    usermod -p '\$1\$s2pp8yHi\$3N6qudJI2p2.qFqQ81qvK0' root; \
    "

do_rootfs_append () {
    bb.buidl.exec_func("configure_sshd", d)
    bb.build.exec_func("generate_installer_package", d)
}

fakeroot generate_installer_package () {
    INSTALLER_PACKAGE_DEPLOY_DIRECTORY="${DEPLOY_DIR}/installer-packages/"
    INSTALLER_PACKAGE_DISPLAY_NAME="${TUNE_PKGARCH}-${DISTRO}"
    INSTALLER_PACKAGE_NAME="${@'${TUNE_PKGARCH}'.replace('-', '_')}_${DISTRO}"
    INSTALLER_PACKAGE_VERSION="${SDK_VERSION}"
    INSTALLER_PACKAGE_DATE="$(date +%F)"

    # create emulator package meta information
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/meta/
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>Emulator</DisplayName>
    <Description>${DISTRO_NAME} emulator for target ${TUNE_PKGARCH}-${DISTRO} version ${DISTRO_VERSION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}.emulator</Name>
</Package>
EOF

    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/data/SDK/${SDK_TARGET}/emulator

    cp ${DEPLOY_DIR_IMAGE}/${EMULATOR_ROOTFS} ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/data/SDK/${REAL_MULTIMACH_TARGET_SYS}/emulator
    cp ${DEPLOY_DIR_IMAGE}/${EMULATOR_KERNEL} ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/data/SDK/${REAL_MULTIMACH_TARGET_SYS}/emulator

    cat << "EOF" > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/data/SDK/${SDK_TARGET}/emulator/emulator
#! /bin/bash

# set qemu architecture
case ${MACHINE} in
    qemuarm-freenivi | qemuarm )
        QEMU_ARCH="arm";;
    qemux86-freenivi | qemux86 | qemux86-64-freenivi | qemux86-64 )
        QEMU_ARCH="x86_64";;
esac

# get qemu path
EMULATOR_TARGET_DIRECTORY="$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)"
SDK_SYSROOT_DIRECTORY="${EMULATOR_TARGET_DIRECTORY%/*}/sysroots/${SDK_ARCH}${SDK_VENDOR}-${SDK_OS}"
QEMU="${SDK_SYSROOT_DIRECTORY}/usr/bin/qemu-system-${QEMU_ARCH}"

program=`basename "${BASH_SOURCE[0]}"`
cmdline=`getopt -o G:K:M:S:h --long 3d:,kvm:,mem:,ssh:,help -- "$@"`

graphics_acceleration=0
kvm_acceleration=0

MEMORY=256
SSHPORT=10022

eval set -- "$cmdline"

while true ; do
    case "$1" in
        -G|--3d) graphics_acceleration="$2"; shift 2;;
        -K|--kvm) kvm_acceleration="$2"; shift 2;;
        -M|--mem) MEMORY="$2"; shift 2;;
        -S|--sshport) SSHPORT="$2"; shift 2;;
        -h|--help) usage; exit;;
        --) shift; break;;
        *) echo "$program: unknown parameter '$1'"; usage; exit 1;;
    esac
done

# check architecture for kvm
if [ "${QEMU_ARCH}" != "x86_64" ]; then
    if [ "$kvm_acceleration" -eq 1 ]; then
        >&2 echo "$program: cannot use kvm acceleration"
        kvm_acceleration=0
    fi
fi

# check ssh port
if [ $SSHPORT -lt 1024 -o $SSHPORT -gt 66535 ]; then
    >&2 echo "$program: invalid ssh port (must be between 1024 and 66535)"
    exit 1
fi

# set options
if [ $graphics_acceleration -eq 1 ]; then
    OPTIONS="$OPTIONS -device vigs -device yagl"
fi
if [ $kvm_acceleration -eq 1 ]; then
    OPTIONS="$OPTIONS -enable-kvm"
fi

# set rootfs and kernel
KERNEL=${EMULATOR_TARGET_DIRECTORY}/${EMULATOR_KERNEL}
ROOTFS=${EMULATOR_TARGET_DIRECTORY}/${EMULATOR_ROOTFS}

cmd="${QEMU} \
    -kernel ${KERNEL} \
    -hda ${ROOTFS} \
    -netdev user,id=freenivi,hostfwd=tcp::${SSHPORT}-:22 \
    -device e1000,netdev=freenivi \
    -no-reboot \
    -m ${MEMORY} \
    -vga vmware \
    -serial stdio \
    -append 'vga=0 console=ttyS0 console=tty1 uvesafb.mode_option=640x480-32 root=/dev/hda rw' \
    ${OPTIONS} \
    $@ \
"

echo $cmd

eval $cmd
EOF
    chmod +x ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.emulator/data/SDK/${SDK_TARGET}/emulator/emulator
}