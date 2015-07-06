inherit populate_sdk_base populate_sdk_qt5

# use our packing function instead of the default on, to use our extraction script
SDK_PACKAGING_FUNC = "create_shar_freenivi"

# this variable allows to change the device type of the kit for the emulators
FREENIVI_DEVICE_TYPE = "GenericLinuxOsType"
FREENIVI_DEVICE_TYPE_emulator = "FreeniviEmulatorOsType"

create_sdk_files_prepend () {
	# copy script to add SDK to Qt Creator as a kit
	cp -f ${FREENIVI_TEMPLATES}/add-kit.sh.in ${SDK_OUTPUT}/${SDKPATH}/add-kit.sh
	# substitute variables
	sed -i -e 's#@DISTRO@#${DISTRO}#g' \
		-e 's#@DISTRO_NAME@#${DISTRO_NAME}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		-e 's#@TARGET_PREFIX@#${TARGET_PREFIX}#g' \
		-e 's#@DEVICE_TYPE@#${FREENIVI_DEVICE_TYPE}#g' \
		${SDK_OUTPUT}/${SDKPATH}/add-kit.sh
	# add execution permission
	chmod +x ${SDK_OUTPUT}/${SDKPATH}/add-kit.sh

        # copy script to remove Qt Creator kit from this SDK
	cp -f ${FREENIVI_TEMPLATES}/del-kit.sh.in ${SDK_OUTPUT}/${SDKPATH}/del-kit.sh
	# substitute variables
	sed -i -e 's#@DISTRO@#${DISTRO}#g' \
		-e 's#@DISTRO_NAME@#${DISTRO_NAME}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		${SDK_OUTPUT}/${SDKPATH}/del-kit.sh
	# add execution permission
	chmod +x ${SDK_OUTPUT}/${SDKPATH}/del-kit.sh

	# copy script to setup sdk installation (used by the extraction script)
	cp -f ${FREENIVI_TEMPLATES}/setup-sdk.sh.in ${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh
	# substitute variables
	sed -i -e 's#@DISTRO@#${DISTRO}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh
	# add execution permission
	chmod +x ${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh

	#  create the file containing the previous installation path for relocation
	echo "${SDKPATH}" > ${SDK_OUTPUT}/${SDKPATH}/last-install-directory
}

fakeroot create_shar_freenivi () {
	# copy extractor script
	cp -f ${FREENIVI_TEMPLATES}/extract-and-install.sh.in ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.sh

	# substitute variables
	sed -i -e 's#@SDK_ARCH@#${SDK_ARCH}#g' \
	        -e 's#@SDKPATH@#${SDKPATH}#g' \
	        -e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
	        ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.sh

	# add execution permission
	chmod +x ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.sh

	# append the SDK tarball
	cat ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.tar.bz2 >> ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.sh

	# delete the old tarball, we don't need it anymore
	rm ${SDK_DEPLOY}/${TOOLCHAIN_OUTPUTNAME}.tar.bz2
}
