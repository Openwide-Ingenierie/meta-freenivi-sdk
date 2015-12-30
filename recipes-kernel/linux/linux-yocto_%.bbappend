FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_emulator = " \
    file://emulator.cfg \
    "

COMPATIBLE_MACHINE_emulator-x86 = "emulator-x86"
KMACHINE_emulator-x86 = "qemux86"
KERNEL_FEATURES_append_emulator-x86 = " cfg/sound.scc cfg/paravirt_kvm.scc"

COMPATIBLE_MACHINE_emulator-arm = "emulator-arm"
KMACHINE_emulator-arm = "qemuarm"

COMPATIBLE_MACHINE_emulator-corei7 = "emulator-corei7"
KMACHINE_emulator-corei7 = "qemux86-64"

