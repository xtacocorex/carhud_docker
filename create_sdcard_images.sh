#!/bin/bash

export MACHINE=raspberrypi

DSTDIR=/home/build/shared/
IMG=${1}
IMG_LONG="${IMG}-image-${MACHINE}"
export OETMP=/home/build/carhud/build/tmp
HOSTNAME=carhud

if [ ! -d /media/card ]; then
        echo "Temporary mount point [/media/card] not found"
        exit 1
fi

if [ "x${2}" = "x" ]; then
	CARDSIZE=1
	COUNT=900
else
	if [ "${2}" -eq 1 ]; then
		CARDSIZE=1
		COUNT=900
	elif [ "${2}" -eq 2 ]; then
		CARDSIZE=2
		COUNT=1800
	elif [ "${2}" -eq 4 ]; then
		CARDSIZE=4
		COUNT=3600
	else
		echo "Unsupported card size: ${2}"
		exit 1
	fi
fi

if [ -z "${OETMP}" ]; then
	echo "OETMP environment variable not set"
	exit 1
fi

if [ -z "${MACHINE}" ]; then
	echo "MACHINE environment variable not set"
	exit 1
fi

if [ "${MACHINE}" = "raspberrypi2" ]; then
	MACH="rpi3"
elif [ "${MACHINE}" = "raspberrypi" ]; then
	MACH="rpi"
else
	echo "Invalid MACHINE: ${MACHINE}"
	exit 1
fi

SRCDIR=${OETMP}/deploy/images/${MACHINE}

if [ ! -f "${SRCDIR}/${IMG_LONG}.tar.bz2" ]; then
	echo "File not found: ${SRCDIR}/${IMG_LONG}.tar.bz2"
	exit 1
fi

SDIMG=${IMG}-${MACH}-${CARDSIZE}gb.img

if [ -f "${DSTDIR}/${SDIMG}" ]; then
        rm ${DSTDIR}/${SDIMG}
fi

if [ -f "${DSTDIR}/${SDIMG}.bz2" ]; then
        rm -f ${DSTDIR}/${SDIMG}.bz2*
fi

echo -e "\n***** Creating the loop device *****"
LOOPDEV=`losetup -f`
echo "LOOP DEVICE: $LOOPDEV"

echo -e "\n***** Creating an empty SD image file *****"
dd if=/dev/zero of=${DSTDIR}/${SDIMG} bs=1M count=${COUNT}

echo -e "\n***** Partitioning the SD image file *****"
sudo fdisk ${DSTDIR}/${SDIMG} <<EOF
o
n
p
1

+64M
n
p
2


t
1
c
a
1
w
EOF

echo -e "\n***** Attaching to the loop device *****"
sudo losetup -P ${LOOPDEV} ${DSTDIR}/${SDIMG}

echo -e "\n***** Copying the boot partition *****"
DEV=${LOOPDEV}p1
echo "DEVICE: $DEV"
./copy_boot.sh ${DEV} 

if [ $? -ne 0 ]; then
	sudo losetup -D
	exit
fi

echo -e "\n***** Copying the rootfs *****"
DEV=${LOOPDEV}p2
echo "DEVICE: $DEV"
./copy_rootfs.sh ${DEV} ${IMG} ${HOSTNAME} 

if [ $? -ne 0 ]; then
	sudo losetup -D
	exit
fi

echo -e "\n***** Detatching loop device *****"
sudo losetup -D

echo -e "\n***** Compressing the SD card image *****"
sudo xz -9 ${DSTDIR}/${SDIMG}

echo -e "\n***** Creating an md5sum *****"
cd ${DSTDIR}
md5sum ${SDIMG}.xz > ${SDIMG}.xz.md5
cd ${OLDPWD}

echo -e "\n***** Done *****\n"
