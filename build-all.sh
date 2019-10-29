#!/bin/bash
#
# https://www.nginx.com/resources/wiki/start/topics/tutorials/installoptions/
# https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#sources
# https://www.vultr.com/docs/how-to-compile-nginx-from-source-on-ubuntu-16-04
# https://github.com/dimitrijp/Organizr-Nginx/wiki/Build-Nginx-from-source-with-GeoIP-module
# https://gist.github.com/rjeczalik/7057434
# https://gist.github.com/sergeifilippov/ef6c5ad43b3a2167211acd0cf3176fd5
# https://gist.github.com/pothi/a95ed8b1d089e5d87268
#
# https://wiki.openssl.org/index.php/Compilation_and_Installation
# https://geeksww.com/tutorials/libraries/libxslt/installation/installing_libxslt_on_ubuntu_linux.php
# https://dev.maxmind.com/geoip/geoip2/geolite2/
# https://stackoverflow.com/questions/54097838/geoip-dat-gz-and-geolitecity-dat-gz-not-longer-available-getting-404-trying-to
#
# https://stackoverflow.com/questions/11824772/compile-nginx-with-existing-pcre
# https://stackoverflow.com/questions/8835108/how-to-specify-non-default-shared-library-path-in-gcc-linux-getting-error-whil
# https://superuser.com/questions/690306/find-out-library-version
# https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc/
# http://www.linuxfromscratch.org/hints/downloads/files/ssp.txt
# https://stackoverflow.com/questions/8692128/static-option-for-gcc
# https://www.akkadia.org/drepper/dsohowto.pdf
# https://bytefreaks.net/gnulinux/bash/bash-get-script-file-name-and-location
# https://stackoverflow.com/questions/7868818/in-bash-is-there-an-equivalent-of-die-error-msg
#
# Main script
#

#
## Auxiliary functions
#

# Interrupts script execution
die() {
  exit $1;
}

# Prints error and die()
error() {
  echo "$SCRIPT_NAME($1):" "error: $2" >&2;
  die $1;
}

# Prints warning
warn() {
  echo "$SCRIPT_NAME($1):" "warning: $2" >&2;
}

# Loads source file
loadSource() {
  if [ -f "$SCRIPT_DIR/$1" ]; then
    source "$SCRIPT_DIR/$1";
  else
    msg="could not find source ${SCRIPT_DIR}/$1";
    if [ "$2" = false ]; then warn 0 "$msg"; else error 1 "$msg"; fi;
  fi;
}

#
# Initialization
#

# Get paths
SCRIPT_NAME=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
SCRIPT_DIR=$(cd $(dirname "$0") && pwd);

# Set environment
#LD_LIBRARY_PATH=/usr/local/lib;
#export LD_LIBRARY_PATH;

#
# Load configuration
#

# Load default config
loadSource "config/config.default.inc" true;
# Load local config
loadSource "config/config.local.inc" false;

#
# Load tasks
#

# task: library: zlib
loadSource "tasks/libs/zlib.sh" true;
# task: library: pcre
loadSource "tasks/libs/pcre.sh" true;
# task: library: openssl
loadSource "tasks/libs/openssl.sh" true;
# task: library: gd2
loadSource "tasks/libs/gd2.sh" true;
# task: library: xml2
loadSource "tasks/libs/xml2.sh" true;
# task: library: xslt
loadSource "tasks/libs/xslt.sh" true;
# task: library: geoip
loadSource "tasks/libs/geoip.sh" true;
# task: application: nginx
loadSource "tasks/apps/nginx.sh" true;

#
# Main program
#

# Cleanup
if [ "$global_build_cleanup" == "yes" ]; then
  sudo rm -Rf ${global_build_usrprefix}/{src,include,lib,bin,sbin}/{zlib*,libz*,pcre*,libpcre*,openssl*,libssl*,gd2*,libgd*,xml2*,libxml*,xslt*,libxslt*,geoip*,GeoIP*,libGeoIP*,nginx*};
  sudo rm -Rf ${global_build_varprefix}/{src,include,lib,bin,sbin}/{zlib*,libz*,pcre*,libpcre*,openssl*,libssl*,gd2*,libgd*,xml2*,libxml*,xslt*,libxslt*,geoip*,GeoIP*,libGeoIP*,nginx*};
fi;

# Install dependencies via apt
if [ "$global_apt_flag" == "yes" ]; then
  # - development tools
  if [ "$dev_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${dev_apt_pkgs}";
  fi;
  # - zlib
  if [ "$zlib_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${zlib_apt_pkgs}";
  fi;
  # - pcre
  if [ "$pcre_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${pcre_apt_pkgs}";
  fi;
  # - openssl
  if [ "$openssl_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${openssl_apt_pkgs}";
  fi;
  # - gd2
  if [ "$gd2_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${gd2_apt_pkgs}";
  fi;
  # - xml2
  if [ "$xml2_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${xml2_apt_pkgs}";
  fi;
  # - xslt
  if [ "$xslt_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${xslt_apt_pkgs}";
  fi;
  # - geoip
  if [ "$geoip_apt_flag" == "yes" ]; then
    global_apt_pkgs="${global_apt_pkgs} ${geoip_apt_pkgs}";
  fi;
  sudo apt-get install -y $global_apt_pkgs;
fi;

# Build dependencies
if [ "$global_build_flag" == "yes" ]; then

  # task: library: zlib
  if [ "$zlib_task" == "yes" ]; then
    task_lib_zlib;
  fi;

  # task: library: pcre
  if [ "$pcre_task" == "yes" ]; then
    task_lib_pcre;
  fi;

  # task: library: openssl
  if [ "$openssl_task" == "yes" ]; then
    task_lib_openssl;
  fi;

  # task: library: gd2
  if [ "$gd2_task" == "yes" ]; then
    task_lib_gd2;
  fi;

  # task: library: xml2
  if [ "$xml2_task" == "yes" ]; then
    task_lib_xml2;
  fi;

  # task: library: xslt
  if [ "$xslt_task" == "yes" ]; then
    task_lib_xslt;
  fi;

  # task: library: geoip
  if [ "$geoip_task" == "yes" ]; then
    task_lib_geoip;
  fi;

  # task: application: nginx
  if [ "$nginx_task" == "yes" ]; then
    task_app_nginx;
  fi;

fi;

# Terminate script
die 0;
