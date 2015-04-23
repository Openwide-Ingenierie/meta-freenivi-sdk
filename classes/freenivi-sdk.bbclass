inherit populate_sdk freenivi_package

# we do not need to make a tarball of the SDK
fakeroot tar_sdk() {
}

# use our packing function instead of the default on, to create a Qt Installer
# Framework package
SDK_PACKAGING_FUNC = "freenivi_package_sdk"
