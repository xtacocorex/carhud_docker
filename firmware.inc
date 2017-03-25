RPIFW_SRCREV ?= "bca4259a6aadb8e6bfc5a353d4d92906dd2fe59c"
RPIFW_DATE ?= "20151021"
RPIFW_SRC_URI ?= "git://github.com/xtacocorex/rpi_bootfiles_for_carhud_yocto.git;protocol=git;branch=master"
RPIFW_S ?= "${WORKDIR}/git"

SRC_URI = "${RPIFW_SRC_URI}"
SRCREV = "${RPIFW_SRCREV}"
PV = "${RPIFW_DATE}"
