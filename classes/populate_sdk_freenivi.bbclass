inherit populate_sdk_base populate_sdk_qt5

# this will be included in the generated install script by populate_sdk_base.bbclass
freenivi_sdk_postinst () {
for create_mkspec_script in `ls $target_sdk_dir/create-mkspec-*.sh`; do
	$SUDO_EXEC $create_mkspec_script
done
}

SDK_POST_INSTALL_COMMAND_append = "${freenivi_sdk_postinst}"

