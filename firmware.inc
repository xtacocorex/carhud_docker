RPIFW_SRCREV ?= "57090dc28c1aa777adb86b10a181f83b9d52a051"
RPIFW_DATE ?= "20151021"
RPIFW_SRC_URI ?= "git://github.com/xtacocorex/rpi_bootfiles_for_carhud_yocto.git;protocol=git;branch=master"
RPIFW_S ?= "${WORKDIR}/git"

SRC_URI = "${RPIFW_SRC_URI}"
SRCREV = "${RPIFW_SRCREV}"
PV = "${RPIFW_DATE}"
