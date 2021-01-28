if rpm -q zfs >/dev/null 2>&1;then
	export ALIAS_DEVICE_PATH=/dev/disk/by-vdev
	export ALIAS_CONFIG_PATH=/etc/zfs
else
        export ALIAS_DEVICE_PATH=/dev
        export ALIAS_CONFIG_PATH=/etc
fi

ln -sf /opt/45drives/tools /opt/tools
alias lshealth="echo lshealth is deprecated. Using \'lsdev -H\'; lsdev -H"
alias lsmodel="echo lsmodel is deprecated. Using \'lsdev -m\'; lsdev -m"
alias lsosd="echo lsosd is deprecated. Using \'lsdev -o\'; lsdev -o"
alias lstype="echo lstype is deprecated. Using \'lsdev -t\'; lsdev -t"
