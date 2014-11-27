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
EMULATOR_ROOTFS = "${IMAGE_LINK_NAME}.ext3"
EMULATOR_KERNEL = "${KERNEL_IMAGETYPE}"

EMULATOR_QEMU_ARCH_emulator-arm = "arm"
EMULATOR_QEMU_emulator-arm = "qemu-system-arm \
    -kernel ${KERNEL} \
    -hda ${ROOTFS} \
    -no-reboot \
    -serial stdio \
    -append 'vga=0 ip=dhcp console=ttyS0 console=tty1 root=/dev/sda rw' \
    -machine versatilepb \
    -m ${MEMORY} \
    -net nic,model=smc91c111 \
    -net user,hostfwd=tcp::${SSHPORT}-:22 \
    ${OPTIONS} \
    $@"
EMULATOR_QEMU_emulator-x86 = "x86_64"
EMULATOR_QEMU_emulator-x86 = "qemu-system-x86_64 \
    -kernel ${KERNEL} \
    -hda ${ROOTFS} \
    -netdev user,id=freenivi,hostfwd=tcp::${SSHPORT}-:22 \
    -device e1000,netdev=freenivi \
    -no-reboot \
    -m ${MEMORY} \
    -vga vmware \
    -serial stdio \
    -append 'vga=0 ip=dhcp console=ttyS0 console=tty1 uvesafb.mode_option=${RESOLUTION}-32 root=/dev/hda rw' \
    ${OPTIONS} \
    $@"

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

# get qemu path
EMULATOR_TARGET_DIRECTORY="$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)"
SDK_SYSROOT_DIRECTORY="${EMULATOR_TARGET_DIRECTORY%/*}/sysroots/${SDK_ARCH}${SDK_VENDOR}-${SDK_OS}"
QEMU_PATH="${SDK_SYSROOT_DIRECTORY}/usr/bin/"

program=`basename "${BASH_SOURCE[0]}"`
cmdline=`getopt -o G:K:M:S:R:h --long 3d:,kvm:,mem:,ssh:res:,help -- "$@"`

usage ()
{
    cat << EOT
Usage: $program [OPTIONS]
OPTIONS:
 -G|--3d              enable 3D graphics acceleration
 -K|--kvm             enable KVM (only available when host and ghest share the
                      same architecture)
 -M|--mem <value>     set the VM memory capacity to <value>
 -S|--sshport <value> set the port to use for the ssh connection (must be a
                      free port of the host)
 -R|--res <value>     set the emulator resolution (<width>x<heigth>)
 -h|--help            display this help
EOT
 }

graphics_acceleration=0
kvm_acceleration=0

MEMORY=256
SSHPORT=10022
RESOLUTION="800x600"

eval set -- "$cmdline"

while true ; do
    case "$1" in
        -G|--3d) graphics_acceleration="$2"; shift 2;;
        -K|--kvm) kvm_acceleration="$2"; shift 2;;
        -M|--mem) MEMORY="$2"; shift 2;;
        -S|--sshport) SSHPORT="$2"; shift 2;;
        -R|--res) RESOLUTION="$2"; shift 2;;
        -h|--help) usage; exit;;
        --) shift; break;;
        *) echo "$program: unknown parameter '$1'"; usage; exit 1;;
    esac
done

@@KVM@@

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

cmd="${QEMU_PATH}/${EMULATOR_QEMU}"

echo $cmd

eval "$cmd &"
QEMU_PID=$!
trap ">&2 echo 'Emulator stopped'; kill -9 ${QEMU_PID}" SIGTERM
wait ${QEMU_PID}

EOF
    chmod +x ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator/emulator
    if [ ${EMULATOR_QEMU_ARCH} != "x86_64" ]; then
        sed -i 's/@@KVM@@/[ "$kvm_acceleration" -eq 1 ] \&\& >\&2 echo "$program: cannot use kvm acceleration" \&\& kvm_acceleration=0/' ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator/emulator
    else
        sed -i 's/@@KVM@@//' ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/emulator/emulator
    fi
}
