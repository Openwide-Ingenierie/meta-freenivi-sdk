FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_emulator = " \
    file://yagl.patch \
    file://vigs.patch \
    file://emulator.cfg \
    "

COMPATIBLE_MACHINE_emulator-x86 = "emulator-x86"
KMACHINE_emulator-x86 = "qemux86"
KBRANCH_emulator-x86 = "standard/common-pc/base"
SRCREV_machine_emulator-x86 = "e19a1b40de44e756defdfb40349342d8037609bd" 
KERNEL_FEATURES_append_emulator-x86 = " cfg/sound.scc cfg/paravirt_kvm.scc"

COMPATIBLE_MACHINE_emulator-arm = "emulator-arm"
KMACHINE_emulator-arm = "qemuarm"
KBRANCH_emulator-arm = "standard/arm-versatile-926ejs"
KMACHINE_emualtor-arm = "qemuarm"
SRCREV_machine_emulator-arm = "127b621f2a4d3b1111e24423c12fac001e047c1c"

