#!/bin/bash
# ---------------------------------------------------------------------------
# dmap - Generate alias config for hardware

# Copyright 2016, Brett Kelly <bkelly@45drives.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

usage() { # Help
        cat << EOF
Usage:	dmap
		[-m] Creates map but doesnt trigger udev rules
		[-o] Use Old mapping (Non universal)
		[-s] Specify chassis size
		[-q] Quiet Mode
		[-r] Resets drive map
		[-h] Displays this message

EOF
        exit 0
}
gethba() {
	if [[ $(lspci | grep $R750) ]];then
		DISK_CONTROLLER=$R750
	elif [[ $(lspci | grep $LSI_9201) ]];then
		DISK_CONTROLLER=$LSI_9201
	elif [[ $(lspci | grep $LSI_9305) ]];then
		DISK_CONTROLLER=$LSI_9305
    elif [[ $(lspci | grep $LSI_9405) ]];then
        DISK_CONTROLLER=$LSI_9405
	elif [[ $(dmidecode -t baseboard | grep -i "product name" | cut -d : -f 2 | xargs echo) == "X11SSH-CTF" ]] && [[ ! $(lspci | grep $LSI_9305) ]];then
		DISK_CONTROLLER=$AV15BASE
	else
		echo "No Supported HBA Detected"
		exit
	fi
}
getsize(){
	if [[ $(ipmitool fru 2>&1 | grep "Product Part Number") ]];then
		SIZE=$(ipmitool fru | grep "Product Part Number" | cut -f2 -d ':' | xargs echo)
		case $SIZE in
		AV15|av15|15)
		CHASSIS=15
		;;
		Q30|q30|30)
		CHASSIS=30
      	;;
    	F32|f32|32)
      	CHASSIS=32
      	;;
    	S45|s45|45)
      	CHASSIS=45
      	;;
    	S45l|s45l|45l)
      	CHASSIS=45
      	;;
    	XL60|xl60|60)
      	CHASSIS=60
      	;;
    	esac
  	else
    		echo "Cant determine Chassis Size automatically"
    		read -p "Chassis Size? " CHASSIS
 
	fi
}
checkchassis(){
	if [ $1 -eq 30 ] || [ $1 -eq 32 ] || [ $1 -eq 45 ] || [ $1 -eq 60 ] || [ $1 -eq 15 ];then
		:
	elif [ $1 -eq 40 ];then
		if [ "$DISK_CONTROLLER" == "$R750" ];then
			:
		else
			echo "Chassis: $1 is only supported for Controller: $R750"
			exit 0
		fi
	elif [ $1 -eq 15 ];then
		if [ "$DISK_CONTROLLER" == "$R750" ];then
			echo "Chassis: $1 is not supported for Controller: $R750"
			exit 0
		else
			:
		fi
	else
		echo "$1 is not an available chassis size, (15,30,45,60 or 40(lite))"
		exit 0
	fi
}
checkroot(){
	SCRIPT_NAME=$(basename "$0")
	if [ "$EUID" -ne 0 ];then
		echo "You must have root privileges to run $SCRIPT_NAME"
		exit 0
	fi
}

R750="0750"
LSI_9201="2116"
LSI_9305="3224"
LSI_9361="3316"
LSI_9405="3616"
HBA1000="Adaptec Series 8"
AV15BASE="3008"
DISK_CONTROLLER=
CHASSIS=
QUIET=no
RESET_MAP=no
UDEV_TRIG=yes
OLD_MAP=no
COLOR_FLAG=yes
BIN_DIR=/opt/tools

while getopts 'c:oms:qrh' OPTION; do
	case ${OPTION} in
	c)
		DISK_CONTROLLER=${OPTARG}
		;;
	s)
		CHASSIS=${OPTARG}
		;;
	o)
		OLD_MAP=yes
		;;
	m)
		UDEV_TRIG=no
		;;
	q)
		QUIET=yes
		;;
	r)
		RESET_MAP=yes
		;;
	h)
		usage
		;;
	esac
done

checkroot
CONFIG_PATH=$ALIAS_CONFIG_PATH
if [ -z $CONFIG_PATH ];then
		echo "No alias config path set in profile.d ... Defaulting to /etc"
        CONFIG_PATH=/etc
fi

if [ $RESET_MAP == yes ];then
	rm -f $CONFIG_PATH/vdev_id.conf
	udevadm trigger
	udevadm settle
	echo "Drive Aliasing reset"
	exit 0
fi

if [ -z $CHASSIS ]; then
	getsize
fi
gethba
checkchassis $CHASSIS

if [ "$DISK_CONTROLLER" == "$R750" ];then
	$BIN_DIR/mapr750 $CHASSIS $DISK_CONTROLLER $OLD_MAP
elif [ "$DISK_CONTROLLER" == "$LSI_9201" ];then
	$BIN_DIR/mapSAS2116 $CHASSIS $DISK_CONTROLLER $OLD_MAP
elif [[ "$DISK_CONTROLLER" == "$LSI_9305" && ("$CHASSIS" -eq 32) ]];then
    $BIN_DIR/mapSAS3224_F $CHASSIS $DISK_CONTROLLER
elif [[ "$DISK_CONTROLLER" == "$LSI_9405" && ("$CHASSIS" -eq 32) ]];then
    $BIN_DIR/mapSAS3616 $CHASSIS $DISK_CONTROLLER
elif [ "$DISK_CONTROLLER" == "$LSI_9305" ];then
	$BIN_DIR/mapSAS3224 $CHASSIS $DISK_CONTROLLER $OLD_MAP
elif [ "$DISK_CONTROLLER" == "$AV15BASE" ];then
	$BIN_DIR/mapAV15BASE $CHASSIS $DISK_CONTROLLER
fi

if [ $UDEV_TRIG == "yes" ];then
	udevadm trigger
	udevadm settle
fi

if [ $QUIET == "yes" ];then
	:
else
	cat $CONFIG_PATH/vdev_id.conf
fi
