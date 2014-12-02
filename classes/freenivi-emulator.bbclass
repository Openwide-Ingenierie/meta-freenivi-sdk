FREENIVI_SDK_TARGET ?= "${DISTRO}/${REAL_MULTIMACH_TARGET_SYS}"
FREENIVI_INSTALLER_PACKAGE_DEPLOY_DIR ?= "${DEPLOY_DIR}/installer-packages/"

# tools needed for deploy
IMAGE_FEATURES += "ssh-server-dropbear"
IMAGE_INSTALL += "openssh-sftp-server"

# qt
IMAGE_INSTALL += "qtbase \
                  qtbase-fonts \
                  qtbase-plugins \
                  qtbase-tools \
                  qtquickcontrols-qmlplugins \
                  qtdeclarative-qmlplugins \
                  "

# set password to freenivi (obtained by "openssl passwd -1 freenivi) 
inherit extrausers
EXTRA_USERS_PARAMS = " \
    usermod -p '\$1\$s2pp8yHi\$3N6qudJI2p2.qFqQ81qvK0' root; \
    "

# problably only right for qemux86
EMULATOR_ROOTFS ?= "${IMAGE_LINK_NAME}.ext3"
EMULATOR_KERNEL ?= "${KERNEL_IMAGETYPE}"

EMULATOR_KERNEL_CMDLINE ?= " \
    ip=dhcp \
    console=tty1 \
    uvesafb.mode_option=${RESOLUTION}-32 \
    video=LVDS-1:${RESOLUTION}-32@60 \
"

EMULATOR_QEMU_OPTIONS ?= " \
    -kernel ${KERNEL} \
    -hda ${ROOTFS} \
    -m ${MEMORY} \
    -display sdl \
    -soundhw all \
    -serial stdio \
    -append '${EMULATOR_KERNEL_CMDLINE} ${CMDLINE}' \
"

EMULATOR_QEMU_emulator-x86 = "qemu-system-i386"
EMULATOR_QEMU_OPTIONS_append_emulator-x86 = " \
    -vga vmware \
    -device e1000,netdev=freenivi \
    -netdev user,id=freenivi,hostfwd=tcp::${SSHPORT}-:22 \
"
EMULATOR_KERNEL_CMDLINE_append_emulator-x86 = " \
    root=/dev/hda rw \
    console=ttyS0 \
"

EMULATOR_QEMU_emulator-arm = "qemu-system-arm"
EMULATOR_QEMU_OPTIONS_append_emulator-arm = " \
    -machine versatilepb \
    -net nic,model=smc91c111 \
    -net user,hostfwd=tcp::${SSHPORT}-:22 \
"
EMULATOR_KERNEL_CMDLINE_append_emulator-arm = " \
    root=/dev/sda rw \
    console=ttyAMA0 \
"



# check if MACHINE is an emulator (quit otherwise)
addtask not_emulable before do_fetch
python do_not_emulable () {
    if not d.getVar("MACHINE","").startswith('emulator'):
        bb.fatal("ERROR: Selected machine is not an emulator")
}

addtask generate_installer_package after do_rootfs before do_build
fakeroot do_generate_installer_package () {
    # generate ${DISTRO} node
    INSTALLER_PACKAGE_DEPLOY_DIRECTORY="${FREENIVI_INSTALLER_PACKAGE_DEPLOY_DIR}"
    INSTALLER_PACKAGE_DISPLAY_NAME="${DISTRO_NAME}"
    INSTALLER_PACKAGE_NAME="${@'${DISTRO}'.replace('-', '_')}"
    INSTALLER_PACKAGE_DESCRIPTION="${DISTRO_NAME} (version ${DISTRO_VERSION}) SDKs, images and emulators"
    INSTALLER_PACKAGE_VERSION="${SDK_VERSION}"
    INSTALLER_PACKAGE_DATE="$(date +%F)"
    INSTALLER_PACKAGE_PRIORITY="70"
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>${INSTALLER_PACKAGE_DISPLAY_NAME}</DisplayName>
    <Description>${INSTALLER_PACKAGE_DESCRIPTION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}</Name>
    <SortingPriority>${INSTALLER_PACKAGE_PRIORITY}</SortingPriority>
</Package>
EOF

    # generate ${DISTRO}/${REAL_MULTIMACH_TARGET_SYS} node
    INSTALLER_PACKAGE_DEPLOY_DIRECTORY="${FREENIVI_INSTALLER_PACKAGE_DEPLOY_DIR}"
    INSTALLER_PACKAGE_DISPLAY_NAME="${REAL_MULTIMACH_TARGET_SYS}"
    INSTALLER_PACKAGE_NAME="${@'${DISTRO}.${REAL_MULTIMACH_TARGET_SYS}'.replace('-', '_')}"
    INSTALLER_PACKAGE_DESCRIPTION="${DISTRO_NAME} SDKs and images, and emulator for ${REAL_MULTIMACH_TARGET_SYS}"
    INSTALLER_PACKAGE_VERSION="${SDK_VERSION}"
    INSTALLER_PACKAGE_DATE="$(date +%F)"
    INSTALLER_PACKAGE_PRIORITY="70"
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>${INSTALLER_PACKAGE_DISPLAY_NAME}</DisplayName>
    <Description>${INSTALLER_PACKAGE_DESCRIPTION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}</Name>
    <SortingPriority>${INSTALLER_PACKAGE_PRIORITY}</SortingPriority>
</Package>
EOF

    # generate ${DISTRO}/${REAL_MULTIMACH_TARGET_SYS} emulator package
    INSTALLER_PACKAGE_DEPLOY_DIRECTORY="${FREENIVI_INSTALLER_PACKAGE_DEPLOY_DIR}"
    INSTALLER_PACKAGE_DISPLAY_NAME="Emulator"
    INSTALLER_PACKAGE_NAME="${@'${DISTRO}.${REAL_MULTIMACH_TARGET_SYS}.emulator'.replace('-', '_')}"
    INSTALLER_PACKAGE_DESCRIPTION="${DISTRO_NAME} emualtor for ${REAL_MULTIMACH_TARGET_SYS}"
    INSTALLER_PACKAGE_VERSION="${SDK_VERSION}"
    INSTALLER_PACKAGE_DATE="$(date +%F)"
    INSTALLER_PACKAGE_PRIORITY="65"
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>${INSTALLER_PACKAGE_DISPLAY_NAME}</DisplayName>
    <Description>${INSTALLER_PACKAGE_DESCRIPTION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}</Name>
    <SortingPriority>${INSTALLER_PACKAGE_PRIORITY}</SortingPriority>
</Package>
EOF
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator
    cp ${DEPLOY_DIR_IMAGE}/${EMULATOR_ROOTFS} ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator
    cp ${DEPLOY_DIR_IMAGE}/${EMULATOR_KERNEL} ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator
    cat << "EOF" > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator/emulator
#! /bin/bash

# get paths
EMULATOR_TARGET_DIRECTORY="$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)"
SDK_SYSROOT_DIRECTORY="${EMULATOR_TARGET_DIRECTORY%/*}/sysroots/${SDK_ARCH}${SDK_VENDOR}-${SDK_OS}"
QEMU_PATH="${SDK_SYSROOT_DIRECTORY}/usr/bin/"
QEMU="${QEMU_PATH}/${EMULATOR_QEMU}"
KERNEL=${EMULATOR_TARGET_DIRECTORY}/${EMULATOR_KERNEL}
ROOTFS=${EMULATOR_TARGET_DIRECTORY}/${EMULATOR_ROOTFS}

usage ()
{
    cat << EOT
Usage: $(basename $0) [options]

Emulator options:
 -graphics-acceleration
                enable 3D graphics acceleration (VIGS + YaGL)
 -ssh-port      set the ssh connection port (must be a free port of the host)
 -resolution    set the emulator display resolution (<width>x<heigth>)

EOT
    ${QEMU} --help | tail -n +6
 }

# get options
MEMORY=256
SSHPORT=10022
RESOLUTION="800x600"
while [ $# -gt 0 ]; do
    case "$1" in
        -graphics-acceleration )
	    OPTIONS="${OPTIONS} -enable-yagl \
                                -enable-vigs \
                                -vigs-backend gl \
                                -yagl-backend vigs \
                                -vga none"
	    CMDLINE="${CMDLINE} modprobe.blacklist=uvesafb"
	    shift;;
        -ssh-port ) SSHPORT="$2"; shift 2;;
        -resolution ) RESOLUTION="$2"; shift 2;;
        -h | --help ) usage; exit;;
        * ) OPTIONS="${OPTIONS} $1"; shift;
    esac
done
OPTIONS="${EMULATOR_QEMU_OPTIONS} ${OPTIONS}"

# execute
cmd="${QEMU} ${OPTIONS}"
echo $cmd
eval "<&0 $cmd &"
QEMU_PID=$!
trap ">&2 echo 'Emulator stopped'; kill -9 ${QEMU_PID}" SIGTERM
wait ${QEMU_PID}
EOF
    chmod +x ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator/emulator
}
