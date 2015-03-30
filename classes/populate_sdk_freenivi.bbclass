inherit populate_sdk populate_sdk_qt5

FREENIVI_SDK_TARGET ?= "${DISTRO}/${REAL_MULTIMACH_TARGET_SYS}"
FREENIVI_INSTALLER_PACKAGE_DEPLOY_DIR ?= "${DEPLOY_DIR}/installer-packages/"

FREENIVI_DEVICE_TYPE = "GenericLinuxOsType"
FREENIVI_DEVICE_TYPE_emulator = "FreeniviEmulatorOsType"

# Create an installer-package for Qt installer-framework.
# Note: the space before the '}' in the heredoc are here to avoid error with
#       the bitbake parser.
addtask generate_installer_package after do_populate_sdk before do_build
fakeroot do_generate_installer_package () {
    # do_populate_sdk done previously a useless tarball.
    rm -f ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.tar.bz2

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

    # generate ${DISTRO}/${REAL_MULTIMACH_TARGET_SYS} SDK package
    INSTALLER_PACKAGE_DEPLOY_DIRECTORY="${FREENIVI_INSTALLER_PACKAGE_DEPLOY_DIR}"
    INSTALLER_PACKAGE_DISPLAY_NAME="SDK"
    INSTALLER_PACKAGE_NAME="${@'${DISTRO}.${REAL_MULTIMACH_TARGET_SYS}.sdk'.replace('-', '_')}"
    INSTALLER_PACKAGE_DESCRIPTION="${DISTRO_NAME} SDK for ${REAL_MULTIMACH_TARGET_SYS}"
    INSTALLER_PACKAGE_VERSION="${SDK_VERSION}"
    INSTALLER_PACKAGE_DATE="$(date +%F)"
    INSTALLER_PACKAGE_PRIORITY="100"
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>${INSTALLER_PACKAGE_DISPLAY_NAME}</DisplayName>
    <Description>${INSTALLER_PACKAGE_DESCRIPTION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}</Name>
    <Script>installscript.js</Script>
    <SortingPriority>${INSTALLER_PACKAGE_PRIORITY}</SortingPriority>
</Package>
EOF
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/meta/installscript.js
function Component()
{
    gui.pageWidgetByObjectName("ReadyForInstallationPage").left.connect(Component.prototype.readyToInstall);
 }

Component.prototype.readyToInstall = function()
{
    // Add QtCreator as dependency, because you need QtCreator to be installed
    // first.
    if (installer.componentByName("qt_creator").installationRequested() ||
        installer.componentByName("qt_creator").isInstalled())
    {
        component.addDependency("qt_creator");
        installer.componentsToInstallNeedsRecalculation();
    }
 }

Component.prototype.createOperations = function()
{
    component.createOperations();

    component.addOperation("Execute", "@TargetDir@/SDK/${FREENIVI_SDK_TARGET}/setup-sdk.sh");

    if (installer.componentByName("qt_creator").installationRequested() ||
        installer.componentByName("qt_creator").isInstalled())
        component.addOperation(
            "Execute", "@TargetDir@/SDK/${FREENIVI_SDK_TARGET}/add-kit.sh", "@TargetDir@/QtCreator/bin/sdktool",
            "UNDOEXECUTE", "@TargetDir@/SDK/${FREENIVI_SDK_TARGET}/del-kit.sh", "@TargetDir@/QtCreator/bin/sdktool"
        );
 }
EOF
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}
    ## copy sdk files
    cp -r ${SDK_OUTPUT}/${SDKPATH}/* ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}
    ## create the file that store the last install direcotory with the default install directory
    echo "${SDKPATH}" > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/last-install-directory
    ## create setup script for sdk (normally done by the auto-extractible archive)
    cat << "EOF" > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/setup-sdk.sh
#! /bin/bash

SDK_TARGET_DIRECTORY="$(cd $(dirname $(readlink -f $0)) && pwd)"
SDK_DEFAULT_TARGET_DIRECTORY="$(cat ${SDK_TARGET_DIRECTORY}/last-install-directory)"
SDK_ENV_SETUP_SCRIPT="${SDK_TARGET_DIRECTORY}/environment-setup-${REAL_MULTIMACH_TARGET_SYS}"
REPLACES="s:${SDK_DEFAULT_TARGET_DIRECTORY}:${SDK_TARGET_DIRECTORY}:g"

# fix environment paths
sed -e ${REPLACES} -i ${SDK_ENV_SETUP_SCRIPT}

# fix dynamic loader paths in all ELF SDK binaries
NATIVE_SYSROOT=$(cat ${SDK_ENV_SETUP_SCRIPT} \
                 | grep 'OECORE_NATIVE_SYSROOT=' \
                 | cut -d'=' -f2 \
                 | tr -d '"')
DL_PATH=$(find ${NATIVE_SYSROOT}/lib -name "ld-linux*")
if [ "$DL_PATH" = "" ] ; then
    echo "error: relocate script unable to find ld-linux.so"
    exit 1
fi
EXECUTABLE_FILES=$(find ${NATIVE_SYSROOT} -type f -perm /111 -exec file '{}' \; \
                   | grep "\(executable\|dynamically linked\)" \
                   | cut -f 1 -d ':')
${SDK_TARGET_DIRECTORY}/relocate_sdk.py \
    ${SDK_TARGET_DIRECTORY} ${DL_PATH} ${EXECUTABLE_FILES}
if [ $? -ne 0 ]; then
    echo "error: relocate script failed"
    exit 1
fi

# fix all text files: configs/scripts/etc
find ${NATIVE_SYSROOT} -type f -exec file '{}' \; \
| grep ":.*\(ASCII\|script\|source\).*text" \
| cut -d':' -f1 \
| xargs sed -i -e ${REPLACES}

# fix all symlinks
for l in $(find ${NATIVE_SYSROOT} -type l); do
    ln -sfn $(readlink $l | sed -e ${REPLACES}) $l
done

# find out all perl scripts in ${NATIVE_SYSROOT} and modify them replacing the
# host perl with SDK perl
for perl_script in $(grep "^#!.*perl" -rl ${NATIVE_SYSROOT}); do
    sed -i -e "s:^#! */usr/bin/perl.*:#! /usr/bin/env perl:g" \
           -e "s: /usr/bin/perl: /usr/bin/env perl:g" $perl_script
done

source ${SDK_ENV_SETUP_SCRIPT}

# We need to create a new MKSPEC for the installed SDK without environment
# variables

# Set OE_QMAKE_COMPILER as environment-setup-${REAL_MULTIMACH_TARGET_SYS} does
# not set it
OE_QMAKE_COMPILER=gcc

MKSPEC="linux-${DISTRO}-g++"
MKSPEC_PATH="$QMAKESPEC/../$MKSPEC"
cp -r "$QMAKESPEC" "$MKSPEC_PATH"
error_code=$?
if [ $error_code -ne 0 ]; then
    echo "error: copy of OE MKSPEC failed"
    exit $error_code
fi

VARLIST=$(sed -n 's/.*$(\(.*\)).*/\1/p' "$MKSPEC_PATH/qmake.conf" | sort -u)
REPLACES=

for VAR in $VARLIST; do
    EVAL=${!VAR}
    REPLACES+="s@\$($VAR)@$EVAL@g; "
done

sed -i "$REPLACES" "$MKSPEC_PATH/qmake.conf"

# set absolute paths
VARLIST=" \
QMAKE_AR \
QMAKE_STRIP \
QMAKE_WAYLAND_SCANNER \
QMAKE_CC \
QMAKE_CXX \
QMAKE_LINK \
QMAKE_LINK_SHLIB \
QMAKE_LINK_C \
QMAKE_LINK_C_SHLIB \
"

for VAR in $VARLIST; do
    VALUE=$(sed -n "s/$VAR *= *\([^ ]*\).*/\1/p" "$MKSPEC_PATH/qmake.conf")
    ABSOLUTE_VALUE=$(command -v $VALUE)
    sed -i "s%\($VAR *= *\)$VALUE%\1$ABSOLUTE_VALUE%" "$MKSPEC_PATH/qmake.conf"
done

echo "${SDK_TARGET_DIRECTORY}" > ${SDK_TARGET_DIRECTORY}/last-install-directory

exit 0
EOF
    chmod +x  ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/setup-sdk.sh
    ## create script that add a kit of the SDK to Qt Creator
    cat << "EOF" > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/add-kit.sh
#! /bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    echo "Usage: $0 [ <sdktool path> ]"
    exit 1
fi

SDK_TARGET_DIRECTORY="$(cd $(dirname $(readlink -f $0)) && pwd)"

if [ $# -gt 0 ]; then
    SDKTOOL=$(which "$1")
else
    SDKTOOL=$(which sdktool)
fi

if [ -z "$SDKTOOL" ]; then
    echo "error: Cannot found sdktool"
    exit 2
fi

# export PATH for the command `command'
source ${SDK_TARGET_DIRECTORY}/environment-setup-${REAL_MULTIMACH_TARGET_SYS}

BASE_ID="${DISTRO_NAME}_"
BASE_NAME="${DISTRO_NAME}"

QTVERSION=qmake
QTVERSION_ID=${BASE_ID}QT5-${REAL_MULTIMACH_TARGET_SYS}
QTVERSION_NAME="Qt5 for ${BASE_NAME} (${REAL_MULTIMACH_TARGET_SYS})"
QTVERSION_PATH=$(command -v $QTVERSION)

DEBUGGER=${TARGET_PREFIX}gdb
DEBUGGER_ID=${BASE_ID}GDB-${REAL_MULTIMACH_TARGET_SYS}
DEBUGGER_NAME="GDB for ${BASE_NAME} (${REAL_MULTIMACH_TARGET_SYS})"
DEBUGGER_PATH=$(command -v $DEBUGGER)

TOOLCHAIN=${TARGET_PREFIX}g++
TOOLCHAIN_ID=${BASE_ID}G++-${REAL_MULTIMACH_TARGET_SYS}
# Toolchain IDs need a prefix
TOOLCHAIN_PREFIX=ProjectExplorer.ToolChain.Gcc
TOOLCHAIN_NAME="G++ for ${BASE_NAME} (${REAL_MULTIMACH_TARGET_SYS})"
TOOLCHAIN_PATH=$(command -v $TOOLCHAIN)

KIT_ID=${BASE_ID}KIT-${REAL_MULTIMACH_TARGET_SYS}
KIT_NAME="${BASE_NAME} (${REAL_MULTIMACH_TARGET_SYS})"

MKSPEC="linux-${DISTRO}-g++"

####################################[ ABI ]#####################################

# We need to detect ABI of the toolchain for add the toolchain and the debugger.
# We use the same algorithm found in qtcreator sources in the file:
#   src/plugins/projectexplorer/abi.cpp

arch=unknown
os=unknown
flavor=unknown
format=unknown
width=unknown

for p in $($TOOLCHAIN_PATH -dumpmachine | sed 's/-/ /g'); do
    case $p in
        unknown | pc | gnu | none | w64 | uclibc | 86_64 | redhat | gnueabi )
            continue
            ;;
        i386 | i486 | i586 | i686 | x86 )
            arch=x86
            width=32bit
            ;;
        arm* )
            arch=arm
            width=32bit
            ;;
        mipsel )
            arch=mips
            width=32bit
            ;;
        x86_64 | amd64 )
            arch=x86
            width=64bit
            ;;
        powerpc64 )
            arch=ppc
            width=64bit
            ;;
        powerpc )
            arch=ppc
            width=32bit
            ;;
        linux | linux6e )
            os=linux
            [[ $flavor = unknown ]] && flavor=generic
            format=elf
            ;;
        android | androideabi )
            flavor=android
            ;;
        freebsd* )
            os=bsd
            [[ $flavor = unknown ]] && flavor=freebsd
            format=elf
            ;;
        mingw32 | win32 | mingw32msvc )
            arch=x86
            os=windows
            flavor=msys
            format=pe
            ;;
        apple )
            os=macos
            flavor=generic
            format=mach_o
            ;;
        darwin10 )
            width=64bit
            ;;
        darwin9 )
            width=32bit
            ;;
        gnueabi )
            format=elf
            ;;
    esac
done

ABI=${arch}-${os}-${flavor}-${format}-${width}

#################################[ QTVERSION ]##################################

exists=$($SDKTOOL find qtversions QString:"$QTVERSION_NAME")
if [[ -n $exists ]]; then
    $SDKTOOL rmQt --id "$QTVERSION_ID"
fi

$SDKTOOL addQt \
    --id "$QTVERSION_ID" \
    --name "$QTVERSION_NAME" \
    --qmake "$QTVERSION_PATH"  \
    --type "RemoteLinux.EmbeddedLinuxQt"

error_code=$?
if [ $error_code -ne 0 ]; then
    echo "error: failed to add QtVersion"
    exit $error_code
fi

###############################[ DEBUGGER ]#####################################

exists=$($SDKTOOL find debuggers QString:"$DEBUGGER_ID")
if [[ -n $exists ]];then
    $SDKTOOL rmDebugger --id $DEBUGGER_ID
fi

$SDKTOOL addDebugger \
    --id "$DEBUGGER_ID" \
    --name "$DEBUGGER_NAME" \
    --binary "$DEBUGGER_PATH" \
    --abis "$ABI"

error_code=$?
if [ $error_code -ne 0 ]; then
    $SDKTOOL rmQt --id "$QTVERSION_ID"
    echo "error: failed to add debbuger"
    exit $error_code
fi

#################################[ TOOLCHAIN ]##################################

exists=$($SDKTOOL find toolchains QByteArray:"$TOOLCHAIN_PREFIX:$TOOLCHAIN_ID")
if [[ -n $exists ]]; then
    $SDKTOOL rmTC --id "$TOOLCHAIN_PREFIX:$TOOLCHAIN_ID"
fi

$SDKTOOL addTC \
    --id "$TOOLCHAIN_PREFIX:$TOOLCHAIN_ID" \
    --name "$TOOLCHAIN_NAME" \
    --path "$TOOLCHAIN_PATH" \
    --abi "$ABI"

error_code=$?
if [ $error_code -ne 0 ]; then
    $SDKTOOL rmQt --id "$QTVERSION_ID"
    $SDKTOOL rmDebugger --id "$DEBUGGER_ID"
    echo "error: failed to add toolchain"
    exit $error_code
fi

##################################[ KIT ]#######################################

exists=$($SDKTOOL find profiles QString:"$KIT_ID")
if [[ -n $exists ]]; then
    $SDKTOOL rmKit --id "$KIT_ID"
fi

$SDKTOOL addKit \
    --id "$KIT_ID" \
    --name "$KIT_NAME" \
    --debuggerid "$DEBUGGER_ID" \
    --devicetype "${FREENIVI_DEVICE_TYPE}" \
    --sysroot "$SDKTARGETSYSROOT" \
    --toolchain "$TOOLCHAIN_PREFIX:$TOOLCHAIN_ID" \
    --qt "$QTVERSION_ID" \
    --mkspec "$MKSPEC" \
    &>/dev/null

error_code=$?
if [ $error_code -ne 0 ]; then
    $SDKTOOL rmQt --id "$QTVERSION_ID"
    $SDKTOOL rmDebugger --id "$DEBUGGER_ID"
    $SDKTOOL rmTC --id "$TOOLCHAIN_PREFIX:$TOOLCHAIN_ID"
    echo "error: failed to add kit"
    exit $error_code
fi

echo "${DISTRO_NAME} kit for ${REAL_MULTIMACH_TARGET_SYS} has been successfully added."

exit 0
EOF
    chmod +x  ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/add-kit.sh
    ## create script that remove a kit of the SDK from Qt Creator
    cat << "EOF" > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/del-kit.sh
#! /bin/bash

if [ $# -gt 0 ]; then
    if [ "$1" == "-h" -o "$1" == "--help" ]; then
        echo "Usage: $0 [ SDKTOOL_PATH ]"
        exit 0
    fi
    SDKTOOL=$(which "$1")
else
    SDKTOOL=$(which sdktool)
fi

if [ -z "$SDKTOOL" ]; then
    echo "error: Cannot found sdktool"
    exit 2
fi

echo "Adding ${DISTRO_NAME} kit for ${REAL_MULTIMACH_TARGET_SYS}..."

BASE_ID=${DISTRO_NAME}_
TOOLCHAIN_ID=${BASE_ID}G++-${REAL_MULTIMACH_TARGET_SYS}
TOOLCHAIN_PREFIX=ProjectExplorer.ToolChain.Gcc
DEBUGGER_ID=${BASE_ID}GDB-${REAL_MULTIMACH_TARGET_SYS}
QTVERSION_ID=${BASE_ID}QT5-${REAL_MULTIMACH_TARGET_SYS}
KIT_ID=${BASE_ID}KIT-${REAL_MULTIMACH_TARGET_SYS}

echo "Removing ..."

$SDKTOOL rmKit --id "$KIT_ID"
$SDKTOOL rmTC --id "$TOOLCHAIN_PREFIX:$TOOLCHAIN_ID"
$SDKTOOL rmDebugger --id "$DEBUGGER_ID"
$SDKTOOL rmQt --id "$QTVERSION_ID"

echo "${DISTRO_NAME} kit for ${REAL_MULTIMACH_TARGET_SYS} has been successfully removed."

exit 0

EOF
    chmod +x  ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}/data/SDK/${FREENIVI_SDK_TARGET}/del-kit.sh
}
