do_generate_qt_environment_file_append () {
    sed -i 's:/mkspecs/linux-oe-g++:/qt5/mkspecs/linux-oe-g++:' $script
}
