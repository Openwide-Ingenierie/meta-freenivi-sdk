# this variable allows to change the device type of the kit for the emulators
FREENIVI_DEVICE_TYPE = "GenericLinuxOsType"
FREENIVI_DEVICE_TYPE_emulator = "FreeniviEmulatorOsType"

# This function create a create-mkspec script
qtkit_create_sdk_createmkspec () {
	local createmkspec=$1
	# copy script to generate a mkspec with absolute path to use in kit
	cp -f ${FREENIVI_TEMPLATES}/create-mkspec.sh.in $createmkspec
	# substitute variables
	sed -i -e 's#@DISTRO@#${DISTRO}#g' \
		-e 's#@TARGET_VENDOR@#${TARGET_VENDOR}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		$createmkspec
}

# This function create a add-kit script
qtkit_create_sdk_addkit () {
	local addkit=$1
	# copy script to add SDK to Qt Creator as a kit
	cp -f ${FREENIVI_TEMPLATES}/add-kit.sh.in $addkit
	# substitute variables
	sed -i -e 's#@DISTRO@#${DISTRO}#g' \
		-e 's#@DISTRO_NAME@#${DISTRO_NAME}#g' \
		-e 's#@TARGET_VENDOR@#${TARGET_VENDOR}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		-e 's#@TARGET_PREFIX@#${TARGET_PREFIX}#g' \
		-e 's#@DEVICE_TYPE@#${FREENIVI_DEVICE_TYPE}#g' \
		$addkit
}

# This function create a del-kit script
qtkit_create_sdk_delkit () {
	local delkit=$1
        # copy script to remove Qt Creator kit from this SDK
	cp -f ${FREENIVI_TEMPLATES}/del-kit.sh.in $delkit
	# substitute variables
	sed -i -e 's#@DISTRO@#${DISTRO}#g' \
		-e 's#@DISTRO_NAME@#${DISTRO_NAME}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		$delkit
}
