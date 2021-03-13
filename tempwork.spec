
%define  debug_package %{nil}

Name:   tempwork
Version:  0.1.7
Release:  1%{?dist}
Summary:  Execute a command in a temporary directory.

Group:    Development/Tools
License:  MIT
URL:    https://github.com/winebarrel/tempwork
Source0:  %{name}.tar.gz
# https://github.com/winebarrel/tempwork/releases/download/v%{version}/tempwork_%{version}.tar.gz

%description
Execute a command in a temporary directory.

%prep
%setup -q -n src

%build
make

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/bin
install -m 755 tempwork %{buildroot}/usr/bin/

%files
%defattr(755,root,root,-)
/usr/bin/tempwork
