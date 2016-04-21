inherit populate_sdk freenivi_package

# we do not need to make a tarball of the SDK
fakeroot tar_sdk() {
}

# use our packing function instead of the default on, to create a Qt Installer
# Framework package
SDK_PACKAGING_FUNC = "create_setup; freenivi_package_sdk"

# setup-sdk.sh.in is based on toolchain-shar-extract.sh
# but the default install folder is the script location
# the archive is not extracted but the content is expected to be present
fakeroot create_setup() {
	# copy in the template setup script
	cp ${FREENIVI_TEMPLATES}/setup-sdk.sh.in ${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh

	rm -f ${T}/pre_install_command ${T}/post_install_command

	if [ ${SDK_RELOCATE_AFTER_INSTALL} -eq 1 ] ; then
		cp ${COREBASE}/meta/files/toolchain-shar-relocate.sh ${T}/post_install_command
	fi
	cat << "EOF" >> ${T}/pre_install_command
${SDK_PRE_INSTALL_COMMAND}
EOF

	cat << "EOF" >> ${T}/post_install_command
${SDK_POST_INSTALL_COMMAND}
EOF
	sed -i -e '/@SDK_PRE_INSTALL_COMMAND@/r ${T}/pre_install_command' \
		-e '/@SDK_POST_INSTALL_COMMAND@/r ${T}/post_install_command' \
		${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh

	# substitute variables
	sed -i -e 's#@SDK_ARCH@#${SDK_ARCH}#g' \
		-e 's#@SDKPATH@#${SDKPATH}#g' \
		-e 's#@SDKEXTPATH@#${SDKEXTPATH}#g' \
		-e 's#@OLDEST_KERNEL@#${SDK_OLDEST_KERNEL}#g' \
		-e 's#@REAL_MULTIMACH_TARGET_SYS@#${REAL_MULTIMACH_TARGET_SYS}#g' \
		-e 's#@SDK_TITLE@#${SDK_TITLE}#g' \
		-e 's#@SDK_VERSION@#${SDK_VERSION}#g' \
		-e '/@SDK_PRE_INSTALL_COMMAND@/d' \
		-e '/@SDK_POST_INSTALL_COMMAND@/d' \
		${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh

	# add execution permission
	chmod +x ${SDK_OUTPUT}/${SDKPATH}/setup-sdk.sh

}

