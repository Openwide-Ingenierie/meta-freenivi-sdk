FREENIVI_PACKAGE_DEPLOY_DIRECTORY ?= "${DEPLOY_DIR}/installer-packages/"

FREENIVI_PACKAGE_TARGET ?= "${DISTRO}_v${DISTRO_VERSION}/${REAL_MULTIMACH_TARGET_SYS}"

FREENIVI_PACKAGE_DISTRO_NAME ?= "${@'${DISTRO}'.replace('-', '_')}_v${@'${DISTRO_VERSION}'.replace('.', '_')}"
FREENIVI_PACKAGE_DISTRO_DISPLAY_NAME ?= "${DISTRO_NAME} (${DISTRO_VERSION})"
FREENIVI_PACKAGE_DISTRO_DESCRIPTION ?= "${DISTRO_NAME} (version ${DISTRO_VERSION}) SDKs, images and emulators"

FREENIVI_PACKAGE_ARCH_NAME ?= "${FREENIVI_PACKAGE_DISTRO_NAME}.${@'${REAL_MULTIMACH_TARGET_SYS}'.replace('-', '_')}"
FREENIVI_PACKAGE_ARCH_DISPLAY_NAME ?= "${REAL_MULTIMACH_TARGET_SYS}"
FREENIVI_PACKAGE_ARCH_DESCRIPTION ?= "${DISTRO_NAME} (version ${DISTRO_VERSION}) SDKs and images, and emulator for ${REAL_MULTIMACH_TARGET_SYS}"

FREENIVI_PACKAGE_IMAGES_NAME ?= "${FREENIVI_PACKAGE_ARCH_NAME}.images"
FREENIVI_PACKAGE_IMAGES_DISPLAY_NAME ?= "Images"
FREENIVI_PACKAGE_IMAGES_DESCRIPTION ?= "${DISTRO_NAME} (version ${DISTRO_VERSION}) images for ${REAL_MULTIMACH_TARGET_SYS}"
FREENIVI_PACKAGE_IMAGES_PRIORITY = "70"

FREENIVI_PACKAGE_SDK_NAME ?= "${FREENIVI_PACKAGE_ARCH_NAME}.sdk"
FREENIVI_PACKAGE_SDK_DISPLAY_NAME ?= "SDK"
FREENIVI_PACKAGE_SDK_DESCRIPTION ?= "${DISTRO_NAME} (version ${DISTRO_VERSION}) SDK for ${REAL_MULTIMACH_TARGET_SYS}, with Qt Creator Kit"
FREENIVI_PACKAGE_SDK_PRIORITY ?= "100"
FREENIVI_PACKAGE_SDK_SCRIPT ?= "installscript.qs"
FREENIVI_PACKAGE_SDK_DIRECTORY ?= "SDK/${DISTRO}_v${DISTRO_VERSION}/${REAL_MULTIMACH_TARGET_SYS}/"
FREENIVI_PACKAGE_SDK_SCRIPT_FUNCTION ?= "freenivi_package_sdk_script_function"
FREENIVI_PACKAGE_SDK_FILL_DATA ?= "freenivi_package_sdk_fill_data"

FREENIVI_IMAGE_NAME ?= "${IMAGE_BASENAME}"
FREENIVI_PACKAGE_IMAGE_NAME ?= "${FREENIVI_PACKAGE_ARCH_NAME}.images.${@'${FREENIVI_IMAGE_NAME}'.replace('-', '_')}"
FREENIVI_PACKAGE_IMAGE_DISPLAY_NAME ?= "${FREENIVI_IMAGE_NAME}"
FREENIVI_PACKAGE_IMAGE_DESCRIPTION ?= "${FREENIVI_IMAGE_DESCRIPTION}"
FREENIVI_PACKAGE_IMAGE_DIRECTORY ?= "images/${DISTRO}_v${DISTRO_VERSION}/${REAL_MULTIMACH_TARGET_SYS}/"
FREENIVI_PACKAGE_IMAGE_FILL_DATA ?= "freenivi_package_image_fill_data"

FREENIVI_PACKAGE_EMULATOR_NAME ?= "${FREENIVI_PACKAGE_ARCH_NAME}.emulator"
FREENIVI_PACKAGE_EMULATOR_DISPLAY_NAME ?= "Emulator"
FREENIVI_PACKAGE_EMULATOR_DESCRIPTION ?= "${DISTRO_NAME} (version ${DISTRO_VERSION}) emulator for ${REAL_MULTIMACH_TARGET_SYS}"
FREENIVI_PACKAGE_EMULATOR_DEPENDENCIES ?= "${FREENIVI_PACKAGE_SDK_NAME}"
FREENIVI_PACKAGE_EMULATOR_PRIORITY = "40"
FREENIVI_PACKAGE_EMULATOR_DIRECTORY ?= "SDK/${DISTRO}_v${DISTRO_VERSION}/${REAL_MULTIMACH_TARGET_SYS}/emulator"
FREENIVI_PACKAGE_EMULATOR_FILL_DATA ?= "freenivi_package_emulator_fill_data"

FREENIVI_PACKAGE_DEFAULT_SCRIPT ?= ""
FREENIVI_PACKAGE_DEFAULT_VERSION ?= "${SDK_VERSION}"
FREENIVI_PACKAGE_DEFAULT_PRIORITY ?= "0"

def freenivi_package_create(type, d):
    import time, shutil

    display_name = d.getVar('FREENIVI_PACKAGE_' + type + '_DISPLAY_NAME', True)
    name = d.getVar('FREENIVI_PACKAGE_' + type + '_NAME', True)
    description = d.getVar('FREENIVI_PACKAGE_' + type + '_DESCRIPTION', True)
    version = d.getVar('FREENIVI_PACKAGE_' + type + '_VERSION', True) or d.getVar('FREENIVI_PACKAGE_DEFAULT_VERSION', True)
    priority = d.getVar('FREENIVI_PACKAGE_' + type + '_PRIORITY', True) or d.getVar('FREENIVI_PACKAGE_DEFAULT_PRIORITY', True)
    dependencies = d.getVar('FREENIVI_PACKAGE_' + type + '_DEPENDENCIES', True) or ""
    script = d.getVar('FREENIVI_PACKAGE_' + type + '_SCRIPT', True) or d.getVar('FREENIVI_PACKAGE_DEFAULT_SCRIPT', True)
    release_date = time.strftime("%F")

    if os.path.exists(d.getVar('FREENIVI_PACKAGE_DEPLOY_DIRECTORY', True) + name):
        shutil.rmtree(d.getVar('FREENIVI_PACKAGE_DEPLOY_DIRECTORY', True) + name)
    os.makedirs(d.getVar('FREENIVI_PACKAGE_DEPLOY_DIRECTORY', True) + name + "/meta", 0755)
    os.makedirs(d.getVar('FREENIVI_PACKAGE_DEPLOY_DIRECTORY', True) + name + "/data", 0755)

    package_file = open(d.getVar('FREENIVI_PACKAGE_DEPLOY_DIRECTORY', True) + name + "/meta/package.xml", 'w+')
    package_file.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    package_file.write("<Package>\n")
    package_file.write("    <DisplayName>" + display_name + "</DisplayName>\n")
    package_file.write("    <Description>" + description + "</Description>\n")
    package_file.write("    <Version>" + version + "</Version>\n")
    package_file.write("    <ReleaseDate>" + release_date + "</ReleaseDate>\n")
    package_file.write("    <Name>" + name + "</Name>\n")
    if script != "":
        package_file.write("    <Script>" + script + "</Script>\n")
    if dependencies != "":
        package_file.write("    <Dependencies>" + dependencies + "</Dependencies>\n")
    package_file.write("    <SortingPriority>" + priority + "</SortingPriority>\n")
    package_file.write("</Package>")


fakeroot python freenivi_package_sdk() {
        freenivi_package_create('DISTRO', d)
        freenivi_package_create('ARCH', d)
        freenivi_package_create('SDK', d)

        bb.build.exec_func(d.getVar('FREENIVI_PACKAGE_SDK_SCRIPT_FUNCTION', True), d)
        bb.build.exec_func(d.getVar('FREENIVI_PACKAGE_SDK_FILL_DATA', True), d)
}

fakeroot freenivi_package_sdk_script_function() {
        # copy install script
        cp ${FREENIVI_TEMPLATES}/installscript.qs.in ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_SDK_NAME}/meta/installscript.qs
        # substitute variables
        sed -i -e 's#@FREENIVI_PACKAGE_SDK_DIRECTORY@#${FREENIVI_PACKAGE_SDK_DIRECTORY}#g' \
                ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_SDK_NAME}/meta/installscript.qs
}

fakeroot freenivi_package_sdk_fill_data() {
        # copy sdk files to package
        mkdir -p ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_SDK_NAME}/data/${FREENIVI_PACKAGE_SDK_DIRECTORY}
        cp -r ${SDK_OUTPUT}/${SDKPATH}/* ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_SDK_NAME}/data/${FREENIVI_PACKAGE_SDK_DIRECTORY}
}

fakeroot python freenivi_package_image() {
        freenivi_package_create('DISTRO', d)
        freenivi_package_create('ARCH', d)
        freenivi_package_create('IMAGES', d)
        freenivi_package_create('IMAGE', d)

        bb.build.exec_func(d.getVar('FREENIVI_PACKAGE_IMAGE_FILL_DATA', True), d)
}
fakeroot python do_freenivi_package_image() {
        bb.build.exec_func('freenivi_package_image', d)
}

fakeroot freenivi_package_image_fill_data() {
        # copy the image into the package
        mkdir -p ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_IMAGE_NAME}/data/${FREENIVI_PACKAGE_IMAGE_DIRECTORY}
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.ext4 ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_IMAGE_NAME}/data/${FREENIVI_PACKAGE_IMAGE_DIRECTORY}
        cp ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_IMAGE_NAME}/data/${FREENIVI_PACKAGE_IMAGE_DIRECTORY}
        if [ -e ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.sdcard ]; then
                cp ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.sdcard ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_IMAGE_NAME}/data/${FREENIVI_PACKAGE_IMAGE_DIRECTORY}
        fi

        # add documentation
        cat << EOF > ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_IMAGE_NAME}/data/${FREENIVI_PACKAGE_IMAGE_DIRECTORY}/README
Freenivi Image Package
======================

You can find in this directory the following files:
 - ${IMAGE_LINK_NAME}.ext4: the rootfs
 - ${KERNEL_IMAGETYPE}: the kernel
EOF
        if [ -e ${DEPLOY_DIR_IMAGE}/${IMAGE_PACKAGE_SDCARD} ]; then
                cat << EOF >> ${FREENIVI_PACKAGE_DEPLOY_DIRECTORY}/${FREENIVI_PACKAGE_IMAGE_NAME}/data/${FREENIVI_PACKAGE_IMAGE_DIRECTORY}/README
 - ${IMAGE_LINK_NAME}.sdcard: a SD card ready image

To put the SD card ready image, use this command:
 # dd if=${IMAGE_PACKAGE_SDCARD} of=<SD card device entry, e,g, /dev/mmcblk0>

/!\ The SD card must be unmounted!
EOF
        fi
}

fakeroot python freenivi_package_emu() {
        freenivi_package_create('DISTRO', d)
        freenivi_package_create('ARCH', d)
        freenivi_package_create('EMULATOR', d)

        bb.build.exec_func(d.getVar('FREENIVI_PACKAGE_EMULATOR_FILL_DATA', True), d)
}

fakeroot python do_freenivi_package_emu() {
        bb.build.exec_func('freenivi_package_emu', d)
}

fakeroot freenivi_package_emulator_fill_data() {
        # do nothing as it should be override (changing FREENIVI_PACKAGE_EMULATOR_FILL_DATA)
}
