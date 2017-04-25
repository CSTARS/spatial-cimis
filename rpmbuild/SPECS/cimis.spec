%define  __spec_install_post %{nil}
%define  debug_package %{nil}
%define  __os_install_post %{_dbpath}/brp-compress

Name:           cimis
Version:        1.0.3
Release:        1
Summary:        Spatial CIMIS Executables
License:        MIT
Group:          Devellopment/Tools
URL:            http://github.com/CSTARS/spatial-cimis
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root
Requires:       sqlite rsync wget curl perl cronie boost perl-JSON perl-Date-Manip perl-TimeDate perl-Test-Pod perl-SOAP-Lite perl-XML-Simple perl-Date-Calc perl-CGI perl-XML-Writer perl-XML-XPath perl-DBI perl-DBD-SQLite geos grass

%description
These are the executables needed to run the spatial CIMIS project

%prep
%setup -q

%build
# Empty

%install
rm -rf ${buildroot}
mkdir -p %{buildroot}
# in build dir
cp -a * %{buildroot}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,cimis,cimis,-)
%attr (-,root,root-) /usr/local/bin/gvar_inspector
%attr (-,root,root-) /usr/local/lib/libgvar.so
%attr (-,root,root-) /usr/local/lib/libgvar.so.0
%attr (-,root,root-) /usr/local/lib/libgvar.a
%attr (-,root,root-) /usr/local/lib/libgvar.la
%attr (-,root,root-) /usr/local/lib/libgvar.so.0.2.0
%attr (-,root,root-) /etc/httpd/conf.d/cimis.conf
%attr (-,root,root-) /var/www/cimis
%attr (-,root,root-) /var/www/html/cimis
%attr (-,root,root-) /var/www/html/wms
/home/%{name}/*

%changelog
* Sat Feb 18 2017 Quinn Hart <qjhart@ucdavis.edu> 1.0-1
- Fist Build
