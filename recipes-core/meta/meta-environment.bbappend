inherit qtkit-scripts

create_sdk_files_append() {

	# Create kit related files
	qtkit_create_sdk_createmkspec ${SDK_OUTPUT}/${SDKPATH}/create-mkspec-${REAL_MULTIMACH_TARGET_SYS}.sh

	qtkit_create_sdk_addkit ${SDK_OUTPUT}/${SDKPATH}/add-kit-${REAL_MULTIMACH_TARGET_SYS}.sh

	qtkit_create_sdk_delkit ${SDK_OUTPUT}/${SDKPATH}/del-kit-${REAL_MULTIMACH_TARGET_SYS}.sh
}

do_install_append() {
    chmod +x ${D}/${SDKPATH}/*.sh
}
