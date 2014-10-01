
IMAGE_NAME = "${IMAGE_LINK_NAME}"

# problably only right for qemux86
IMAGE_ROOTFS = "${IMAGE_LINK_NAME}.ext3"
IMAGE_KERNEL = "bzImage"

do_rootfs_append () {
    bb.build.exec_func("generate_installer_package", d)
}

fakeroot generate_installer_package () {
    INSTALLER_PACKAGE_DEPLOY_DIRECTORY="${DEPLOY_DIR}/installer-packages/"
    INSTALLER_PACKAGE_DISPLAY_NAME="${TUNE_PKGARCH}-${DISTRO}"
    INSTALLER_PACKAGE_NAME="${@'${TUNE_PKGARCH}'.replace('-', '_')}_${DISTRO}"
    INSTALLER_PACKAGE_VERSION="${SDK_VERSION}"
    INSTALLER_PACKAGE_DATE="$(date +%F)"

    # create node images package meta information (if necessary)
    if [ ! -e ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images ]; then
        mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images/meta/
        cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>Images</DisplayName>
    <Description>${DISTRO_NAME} images for target ${TUNE_PKGARCH}-${DISTRO} version ${DISTRO_VERSION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}.images</Name>
</Package>
EOF
    fi

    # create image package meta information
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images.${MACHINE}_${IMAGE_NAME}/meta/
    cat << EOF > ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images.${MACHINE}_${IMAGE_NAME}/meta/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>${MACHINE}-${IMAGE_NAME}</DisplayName>
    <Description>${MACHINE}-${IMAGE_NAME} image for target ${TUNE_PKGARCH}-${DISTRO} version ${DISTRO_VERSION}</Description>
    <Version>${INSTALLER_PACKAGE_VERSION}</Version>
    <ReleaseDate>${INSTALLER_PACKAGE_DATE}</ReleaseDate>
    <Name>${INSTALLER_PACKAGE_NAME}.images</Name>
</Package>
EOF

    # copy the image into the package
    mkdir -p ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images.${MACHINE}_${IMAGE_NAME}/data/images/${TUNE_PKGARCH}-${DISTRO}/
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_ROOTFS} ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images.${MACHINE}_${IMAGE_NAME}/data/images/${TUNE_PKGARCH}-${DISTRO}/
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_KERNEL} ${INSTALLER_PACKAGE_DEPLOY_DIRECTORY}/${INSTALLER_PACKAGE_NAME}.images.${MACHINE}_${IMAGE_NAME}/data/images/${TUNE_PKGARCH}-${DISTRO}/
}
