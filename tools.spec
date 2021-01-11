%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Name:		45drives-tools
Version:	1.7
Release:	2%{?dist}
Summary:	Server CLI Tools

Group:		Development/Tools
License:	GPL
URL:		https://github.com/45Drives/tools
Source0:	%{name}-%{version}.tar.gz

BuildArch:	x86_64
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root

Requires: ipmitool
Requires: jq
Requires: smartmontools > 7.0
Requires: dmidecode
Requires: python3
Requires: pciutils
Requires: hdparm

%description
45Drives server cli tools

%prep
%setup -q

%build
# empty

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}
mkdir -p %{buildroot}%{_bindir}

# in builddir
cp -a etc/ %{buildroot}
cp -a opt/ %{buildroot}

pushd opt/tools/
    for i in lsdev dmap findosd zcreate; do
        ln -sf /opt/tools/$i %{buildroot}%{_bindir}
    done
popd

%clean
rm -rf %{buildroot}

%files
%dir /opt/tools
%dir /etc/profile.d
%defattr(-,root,root,-)
/opt/tools/*
/etc/profile.d/tools.sh
%{_bindir}/*

%changelog
* Mon Jan 11 2021 Mark Hooper <mhooper@45drives.com> 1.7-2
- fixed bus address bug in dmap encountered with X11DPL-i motherboards.
- made adjustments to server_identifier script to deal with VMs and VMs with HBA passthroughs.
- added an "Edit Mode" flag in /etc/server_info/server_info.json to allow for manual edits to this file to be used in dmap.
* Wed Jan 6 2021 Mark Hooper <mhooper@45drives.com> 1.7
- added hmap functionality into dmap.
- updated lsdev to display drives based on their physical location within the server.
- created server_identifier script, which can identify the 45Drives product type and store that information in /etc/server_info/server_info.json.
* Tue Sep 1 2020 Mark Hooper <mhooper@45drives.com> 1.6
- second build 1.6, fixed zfs ailiasing bug
* Tue Sep 1 2020 Mark Hooper <mhooper@45drives.com> 1.5
- First build 1.5, added hdparm dependancy
* Sat May 30 2020 Brett Kelly <bkelly@45drives.com> 1.3
- Second build 1.3, added python dependancy 
* Sat May 30 2020 Brett Kelly <bkelly@45drives.com> 1.3
- First build 1.3, added generate-osd-vars.sh 
* Tue May 26 2020 Brett Kelly <bkelly@45drives.com> 1.2
- First build 1.2, added lsdev json output, smartctl attr 
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- Second build, link files from opt/tools to bin dir
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- First build of v1.1. Added zfs check in profile.d script. Organized code. Removed unneeded scripts
* Tue May 12 2020 Josh Boudreau <jboudreau@45drives.com> 1.0
- First build of v1.0

