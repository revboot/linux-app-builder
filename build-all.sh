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

  # - zlib
  if [ "$zlib_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$zlib_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${zlib_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$zlib_build_path" ]; then
      if [ ! -f "${zlib_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${zlib_build_url} && tar xzf ${zlib_build_tar}";
      fi;
    fi;
    cd $zlib_build_path;
    # compile binaries
    if [ "$zlib_build_make" == "yes" ]; then
      # command - add configuration tool
      zlib_build_cmd_full="./configure";

      # command - add arch
      if [ -n "$zlib_build_arg_arch" ]; then
        zlib_build_cmd_full="${zlib_build_cmd_full} --archs=\"${zlib_build_arg_arch}\"";
      fi;

      # command - add prefix (usr)
      if [ -n "$zlib_build_arg_usrprefix" ]; then
        zlib_build_cmd_full="${zlib_build_cmd_full} --prefix=${zlib_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$zlib_build_arg_libraries" ]; then
      #  zlib_build_cmd_full="${zlib_build_cmd_full} --libraries=${zlib_build_arg_libraries}";
      #fi;

      # command - add options
      if [ -n "$zlib_build_arg_options" ]; then
        zlib_build_cmd_full="${zlib_build_cmd_full} ${zlib_build_arg_options}";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${zlib_build_cmd_full}";
      sudo $zlib_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$zlib_build_install" == "yes" ] && [ -f "${zlib_build_path}/libz.so" ]; then
      sudo make uninstall; sudo make install;
      echo "system library: $(whereis libz.so)";
      echo "built library: ${global_build_usrprefix}/lib/libz.so";
      zlib_ldconfig_test_cmd="ldconfig -p | grep libz.so; ldconfig -v | grep libz.so";
      echo "list libraries: ${zlib_ldconfig_test_cmd}"; ${zlib_ldconfig_test_cmd};
    fi;
  fi;

  # - pcre
  if [ "$pcre_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$pcre_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${pcre_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$pcre_build_path" ]; then
      if [ ! -f "${pcre_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${pcre_build_url} && tar xzf ${pcre_build_tar}";
      fi;
    fi;
    cd $pcre_build_path;
    # compile binaries
    if [ "$pcre_build_make" == "yes" ]; then
      # command - add configuration tool
      pcre_build_cmd_full="./configure";

      # command - add arch
      if [ -n "$pcre_build_arg_arch" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --target=${pcre_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$pcre_build_arg_usrprefix" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --prefix=${pcre_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$pcre_build_arg_libraries" ]; then
      #  pcre_build_cmd_full="${pcre_build_cmd_full} --libraries=${pcre_build_arg_libraries}";
      #fi;

      # command - add options
      if [ -n "$pcre_build_arg_options" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} ${pcre_build_arg_options}";
      fi;

      # command - add main: pcre8
      if [ "$pcre_build_arg_main_pcre8" == "yes" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcre8";
      elif [ "$pcre_build_arg_main_pcre8" == "no" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --disable-pcre8";
      fi;

      # command - add main: pcre16
      if [ "$pcre_build_arg_main_pcre16" == "yes" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcre16";
      fi;

      # command - add main: pcre32
      if [ "$pcre_build_arg_main_pcre32" == "yes" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcre32";
      fi;

      # command - add main: jit
      if [ "$pcre_build_arg_main_jit" == "yes" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-jit=auto";
      fi;

      # command - add main: utf8
      if [ "$pcre_build_arg_main_utf8" == "yes" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-utf8";
      fi;

      # command - add main: unicode
      if [ "$pcre_build_arg_main_unicode" == "yes" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-unicode-properties";
      fi;

      # command - add tool: pcregreplib
      if [ "$pcre_build_arg_tool_pcregreplib" == "libz" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcregrep-libz";
      elif [ "$pcre_build_arg_tool_pcregreplib" == "libbz2" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcregrep-libbz2";
      fi;

      # command - add tool: pcretestlib
      if [ "$pcre_build_arg_tool_pcretestlib" == "libreadline" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcretest-libreadline";
      elif [ "$pcre_build_arg_tool_pcretestlib" == "libedit" ]; then
        pcre_build_cmd_full="${pcre_build_cmd_full} --enable-pcretest-libedit";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${pcre_build_cmd_full}";
      sudo $pcre_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$pcre_build_install" == "yes" ] && [ -f "${pcre_build_path}/.libs/libpcre.so" ]; then
      sudo make uninstall; sudo make install;
      echo "system library: ${pcre_link_cmd}$(whereis libpcre.so)";
      echo "built library: ${global_build_usrprefix}/lib/libpcre.so";
      pcre_ldconfig_test_cmd="ldconfig -p | grep libpcre.so; ldconfig -v | grep libpcre.so";
      echo "list libraries: ${pcre_ldconfig_test_cmd}"; ${pcre_ldconfig_test_cmd};
    fi;
    # test binaries
    if [ "$pcre_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/pcre-config" ]; then
      pcre_binary_test_cmd="pcre-config --version --libs --cflags";
      echo "test system binary: /usr/bin/${pcre_binary_test_cmd}"; /usr/bin/$pcre_binary_test_cmd;
      echo "test built binary: ${global_build_usrprefix}/bin/${pcre_binary_test_cmd}"; ${global_build_usrprefix}/bin/${pcre_binary_test_cmd};
    fi;
  fi;

  # - openssl
  if [ "$openssl_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$openssl_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${openssl_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$openssl_build_path" ]; then
      if [ ! -f "${openssl_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${openssl_build_url} && tar xzf ${openssl_build_tar}";
      fi;
    fi;
    cd $openssl_build_path;
    # compile binaries
    if [ "$openssl_build_make" == "yes" ]; then
      # command - add configuration tool
      openssl_build_cmd_full="./Configure";

      # command - add arch
      if [ -n "$openssl_build_arg_arch" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} ${openssl_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$openssl_build_arg_usrprefix" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} --prefix=${openssl_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$openssl_build_arg_libraries" ]; then
      #  openssl_build_cmd_full="${openssl_build_cmd_full} --libraries=${openssl_build_arg_libraries}";
      #fi;

      # command - add libraries: zlib
      if [ "$openssl_build_arg_libraries_zlib" == "system" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} --with-zlib";
      elif [ "$openssl_build_arg_libraries_zlib" == "custom" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} --with-zlib-include=${global_build_usrprefix}/include --with-zlib-lib=${global_build_usrprefix}/lib";
      fi;

      # command - add options
      if [ -n "$openssl_build_arg_options" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} ${openssl_build_arg_options}";
      fi;

      # command - add main: threads
      if [ "$openssl_build_arg_main_threads" == "yes" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} threads";
      elif [ "$openssl_build_arg_main_threads" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-threads";
      fi;

      # command - add main: zlib
      if [ "$openssl_build_arg_main_zlib" == "yes" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} zlib";
      fi;

      # command - add main: nistp gcc
      if [ "$openssl_build_arg_main_nistp" == "yes" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} enable-ec_nistp_64_gcc_128";
      fi;

      # command - add proto: tls 1.3
      if [ "$openssl_build_arg_proto_tls1_3" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1_3";
      fi;

      # command - add proto: tls 1.2
      if [ "$openssl_build_arg_proto_tls1_2" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1_2";
      fi;

      # command - add proto: tls 1.1
      if [ "$openssl_build_arg_proto_tls1_1" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1_1";
      fi;

      # command - add proto: tls 1.0
      if [ "$openssl_build_arg_proto_tls1_0" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1";
      fi;

      # command - add proto: ssl 3
      if [ "$openssl_build_arg_proto_ssl3" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-ssl3";
      fi;

      # command - add proto: ssl 2
      if [ "$openssl_build_arg_proto_ssl2" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-ssl2";
      fi;

      # command - add proto: dtls 1.2
      if [ "$openssl_build_arg_proto_dtls1_2" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-dtls1_2";
      fi;

      # command - add proto: dtls 1.0
      if [ "$openssl_build_arg_proto_dtls1_0" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-dtls1";
      fi;

      # command - add proto: next proto negotiation
      if [ "$openssl_build_arg_proto_npn" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-nextprotoneg";
      fi;

      # command - add cypher: idea
      if [ "$openssl_build_arg_cypher_idea" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-idea";
      fi;

      # command - add cypher: weak ciphers
      if [ "$openssl_build_arg_cypher_weak" == "no" ]; then
        openssl_build_cmd_full="${openssl_build_cmd_full} no-weak-ssl-ciphers";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${openssl_build_cmd_full}";
      sudo $openssl_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$openssl_build_install" == "yes" ] && [ -f "${openssl_build_path}/libssl.so" ]; then
      sudo make uninstall; sudo make install;
      echo "system library: $(whereis libssl.so)";
      echo "built library: ${global_build_usrprefix}/lib/libssl.so";
      openssl_ldconfig_test_cmd="ldconfig -p | grep libssl.so; ldconfig -v | grep libssl.so";
      echo "list libraries: ${openssl_ldconfig_test_cmd}"; ${openssl_ldconfig_test_cmd};
    fi;
    # test binaries
    if [ "$openssl_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/openssl" ]; then
      openssl_binary_test_cmd="openssl version -f";
      echo "test system binary: /usr/bin/${openssl_binary_test_cmd}"; /usr/bin/$openssl_binary_test_cmd;
      echo "test built binary: ${global_build_usrprefix}/bin/${openssl_binary_test_cmd}"; ${global_build_usrprefix}/bin/${openssl_binary_test_cmd};
    fi;
  fi;

  # - gd2
  if [ "$gd2_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$gd2_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${gd2_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$gd2_build_path" ]; then
      if [ ! -f "${gd2_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${gd2_build_url} && tar xzf ${gd2_build_tar}";
      fi;
    fi;
    cd $gd2_build_path;
    # compile binaries
    if [ "$gd2_build_make" == "yes" ]; then
      # command - add configuration tool
      gd2_build_cmd_full="./configure";

      # command - add arch
      if [ -n "$gd2_build_arg_arch" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --target=${gd2_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$gd2_build_arg_usrprefix" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --prefix=${gd2_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$gd2_build_arg_libraries" ]; then
      #  gd2_build_cmd_full="${gd2_build_cmd_full} --libraries=${gd2_build_arg_libraries}";
      #fi;

      # command - add libraries: zlib
      if [ "$gd2_build_arg_libraries_zlib" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-zlib";
      elif [ "$gd2_build_arg_libraries_zlib" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-zlib=${zlib_build_path}";
      fi;

      # command - add libraries: png
      if [ "$gd2_build_arg_libraries_png" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-png";
      elif [ "$gd2_build_arg_libraries_png" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-png=${png_build_path}";
      fi;

      # command - add libraries: jpeg
      if [ "$gd2_build_arg_libraries_jpeg" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-jpeg";
      elif [ "$gd2_build_arg_libraries_jpeg" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-jpeg=${jpeg_build_path}";
      fi;

      # command - add libraries: webp
      if [ "$gd2_build_arg_libraries_webp" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-webp";
      elif [ "$gd2_build_arg_libraries_webp" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-webp=${webp_build_path}";
      fi;

      # command - add libraries: tiff
      if [ "$gd2_build_arg_libraries_tiff" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-tiff";
      elif [ "$gd2_build_arg_libraries_tiff" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-tiff=${tiff_build_path}";
      fi;

      # command - add libraries: xpm
      if [ "$gd2_build_arg_libraries_xpm" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-xpm";
      elif [ "$gd2_build_arg_libraries_xpm" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-xpm=${xpm_build_path}";
      fi;

      # command - add libraries: liq
      if [ "$gd2_build_arg_libraries_liq" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-liq";
      elif [ "$gd2_build_arg_libraries_liq" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-liq=${liq_build_path}";
      fi;

      # command - add libraries: freetype
      if [ "$gd2_build_arg_libraries_freetype" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-freetype";
      elif [ "$gd2_build_arg_libraries_freetype" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-freetype=${freetype_build_path}";
      fi;

      # command - add libraries: fontconfig
      if [ "$gd2_build_arg_libraries_fontconfig" == "system" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-fontconfig";
      elif [ "$gd2_build_arg_libraries_fontconfig" == "custom" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} --with-fontconfig=${fontconfig_build_path}";
      fi;

      # command - add options
      if [ -n "$gd2_build_arg_options" ]; then
        gd2_build_cmd_full="${gd2_build_cmd_full} ${gd2_build_arg_options}";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${gd2_build_cmd_full}";
      sudo $gd2_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$gd2_build_install" == "yes" ] && [ -f "${gd2_build_path}/src/.libs/libgd.so" ]; then
      sudo make uninstall; sudo make install;
      echo "system library: $(whereis libgd.so)";
      echo "built library: ${global_build_usrprefix}/lib/libgd.so";
      gd2_ldconfig_test_cmd="ldconfig -p | grep libgd.so; ldconfig -v | grep libgd.so";
      echo "list libraries: ${gd2_ldconfig_test_cmd}"; ${gd2_ldconfig_test_cmd};
    fi;
    # test binaries
    if [ "$gd2_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/gdlib-config" ]; then
      gd2_binary_test_cmd="gdlib-config --version --libs --cflags --ldflags --features";
      echo "test system binary: /usr/bin/${gd2_binary_test_cmd}"; /usr/bin/${gd2_binary_test_cmd};
      echo "test built binary: ${global_build_usrprefix}/bin/${gd2_binary_test_cmd}"; ${global_build_usrprefix}/bin/${gd2_binary_test_cmd};
    fi;
  fi;

  # - xml2
  if [ "$xml2_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$xml2_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${xml2_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$xml2_build_path" ]; then
      if [ ! -f "${xml2_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${xml2_build_url} && tar xzf ${xml2_build_tar}";
      fi;
    fi;
    cd $xml2_build_path;
    # compile binaries
    if [ "$xml2_build_make" == "yes" ]; then
      # command - add configuration tool
      xml2_build_cmd_full="./configure";

      # command - add arch
      if [ -n "$xml2_build_arg_arch" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --target=${xml2_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$xml2_build_arg_usrprefix" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --prefix=${xml2_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$xml2_build_arg_libraries" ]; then
      #  xml2_build_cmd_full="${xml2_build_cmd_full} --libraries=${xml2_build_arg_libraries}";
      #fi;

      # command - add libraries: zlib
      if [ "$xml2_build_arg_libraries_zlib" == "system" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-zlib";
      elif [ "$xml2_build_arg_libraries_zlib" == "custom" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-zlib=${zlib_build_path}";
      fi;

      # command - add libraries: lzma
      if [ "$xml2_build_arg_libraries_lzma" == "system" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-lzma";
      elif [ "$xml2_build_arg_libraries_lzma" == "custom" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-lzma=${lzma_build_path}";
      fi;

      # command - add libraries: readline
      if [ "$xml2_build_arg_libraries_readline" == "system" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-readline";
      elif [ "$xml2_build_arg_libraries_readline" == "custom" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-readline=${readline_build_path}";
      fi;

      # command - add libraries: iconv
      if [ "$xml2_build_arg_libraries_iconv" == "system" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-iconv";
      elif [ "$xml2_build_arg_libraries_iconv" == "custom" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-iconv=${iconv_build_path}";
      fi;

      # command - add libraries: python
      if [ "$xml2_build_arg_libraries_python" == "system" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-python";
      elif [ "$xml2_build_arg_libraries_python" == "custom" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-python=${python_build_path}";
      fi;

      # command - add options
      if [ -n "$xml2_build_arg_options" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} ${xml2_build_arg_options}";
      fi;

      # command - add main: threads
      if [ "$xml2_build_arg_main_threads" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-threads";
      fi;

      # command - add main: thread alloc
      if [ "$xml2_build_arg_main_threadalloc" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-thread-alloc";
      fi;

      # command - add main: ipv6
      if [ "$xml2_build_arg_main_ipv6" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --enable-ipv6";
      fi;

      # command - add main: regular expressions
      if [ "$xml2_build_arg_main_regexps" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-regexps";
      fi;

      # command - add main: dso
      if [ "$xml2_build_arg_main_dso" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-modules";
      fi;

      # command - add encoding: iso8859x
      if [ "$xml2_build_arg_encoding_iso8859x" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-iso8859x";
      fi;

      # command - add encoding: unicode
      if [ "$xml2_build_arg_encoding_unicode" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-icu";
      fi;

      # command - add xml: canonicalization
      if [ "$xml2_build_arg_xml_canonical" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-c14n";
      fi;

      # command - add xml: catalog
      if [ "$xml2_build_arg_xml_catalog" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-catalog";
      fi;

      # command - add xml: schemas
      if [ "$xml2_build_arg_xml_schemas" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-schemas";
      fi;

      # command - add xml: schematron
      if [ "$xml2_build_arg_xml_schematron" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-schematron";
      fi;

      # command - add sgml: docbook
      if [ "$xml2_build_arg_sgml_docbook" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-docbook";
      fi;

      # command - add sgml: html
      if [ "$xml2_build_arg_sgml_html" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-html";
      fi;

      # command - add sgml: tree dom
      if [ "$xml2_build_arg_sgml_treedom" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-tree";
      fi;

      # command - add parser: pattern
      if [ "$xml2_build_arg_parser_pattern" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-pattern";
      fi;

      # command - add parser: push
      if [ "$xml2_build_arg_parser_push" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-push";
      fi;

      # command - add parser: reader
      if [ "$xml2_build_arg_parser_reader" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-reader";
      fi;

      # command - add parser: sax 1
      if [ "$xml2_build_arg_parser_sax1" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-sax1";
      fi;

      # command - add api: legacy
      if [ "$xml2_build_arg_api_legacy" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-legacy";
      fi;

      # command - add api: output serial
      if [ "$xml2_build_arg_api_outputserial" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-output";
      fi;

      # command - add api: valid dtd
      if [ "$xml2_build_arg_api_validdtd" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-valid";
      fi;

      # command - add api: writer
      if [ "$xml2_build_arg_api_writer" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-writer";
      fi;

      # command - add api: xinclude
      if [ "$xml2_build_arg_api_xinclude" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-xinclude";
      fi;

      # command - add api: xpath
      if [ "$xml2_build_arg_api_xpath" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-xpath";
      fi;

      # command - add api: pointer
      if [ "$xml2_build_arg_api_xpointer" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-xptr";
      fi;

      # command - add proto: ftp
      if [ "$xml2_build_arg_proto_ftp" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-ftp";
      fi;

      # command - add proto: http
      if [ "$xml2_build_arg_proto_http" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-http";
      fi;

      # command - add tool: history
      if [ "$xml2_build_arg_tool_history" == "yes" ]; then
        xml2_build_cmd_full="${xml2_build_cmd_full} --with-history";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${xml2_build_cmd_full}";
      sudo bash -c "libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf" && sudo $xml2_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$xml2_build_install" == "yes" ] && [ -f "${xml2_build_path}/.libs/libxml2.so" ]; then
      sudo make uninstall; sudo make install;
      echo "system library: $(whereis libxml2.so)";
      echo "built library: ${global_build_usrprefix}/lib/libxml2.so";
      xml2_ldconfig_test_cmd="ldconfig -p | grep libxml2.so; ldconfig -v | grep libxml2.so";
      echo "list libraries: ${xml2_ldconfig_test_cmd}"; ${xml2_ldconfig_test_cmd};
    fi;
    # test binaries
    if [ "$xml2_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/xml2-config" ]; then
      xml2_binary_test_cmd="xml2-config --libs --cflags --modules --version";
      echo "test system binary: /usr/bin/${xml2_binary_test_cmd}"; /usr/bin/${xml2_binary_test_cmd};
      echo "test built binary: ${global_build_usrprefix}/bin/${xml2_binary_test_cmd}"; ${global_build_usrprefix}/bin/${xml2_binary_test_cmd};
    fi;
  fi;

  # - xslt
  if [ "$xslt_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$xslt_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${xslt_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$xslt_build_path" ]; then
      if [ ! -f "${xslt_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${xslt_build_url} && tar xzf ${xslt_build_tar}";
      fi;
    fi;
    cd $xslt_build_path;
    # compile binaries
    if [ "$xslt_build_make" == "yes" ]; then
      # command - add configuration tool
      xslt_build_cmd_full="./configure";

      # command - add arch
      if [ -n "$xslt_build_arg_arch" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --target=${xslt_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$xslt_build_arg_usrprefix" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --prefix=${xslt_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$xslt_build_arg_libraries" ]; then
      #  xslt_build_cmd_full="${xslt_build_cmd_full} ${xslt_build_arg_libraries}";
      #fi;

      # command - add libraries: xml2
      if [ "$xslt_build_arg_libraries_xml2" == "system" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --with-libxml-prefix";
      elif [ "$xslt_build_arg_libraries_xml2" == "custom" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --with-libxml-prefix=${global_build_usrprefix}";
      fi;

      # command - add libraries: python
      if [ "$xslt_build_arg_libraries_python" == "system" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --with-python";
      elif [ "$xslt_build_arg_libraries_python" == "custom" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --with-python=${python_build_path}";
      fi;

      # command - add options
      if [ -n "$xslt_build_arg_options" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} ${xslt_build_arg_options}";
      fi;

      # command - add main: crypto
      if [ "$xslt_build_arg_main_crypto" == "yes" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --with-crypto";
      fi;

      # command - add main: plugins
      if [ "$xslt_build_arg_main_plugins" == "yes" ]; then
        xslt_build_cmd_full="${xslt_build_cmd_full} --with-plugins";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${xslt_build_cmd_full}";
      sudo wget -P $xslt_build_path/doc "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd";
      sudo wget -P $xslt_build_path/doc "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl";
      sudo bash -c "libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf" && sudo $xslt_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$xslt_build_install" == "yes" ] && [ -f "${xslt_build_path}/libxslt/.libs/libxslt.so" ]; then
      sudo make uninstall; sudo make install;
      sudo cp "${xslt_build_path}/xsltproc/.libs/xsltproc" "${global_build_usrprefix}/bin/xsltproc";
      sudo cp "${xslt_build_path}/xslt-config" "${global_build_usrprefix}/bin/xslt-config";
      sudo chmod +x "${global_build_usrprefix}/bin/xslt-config";
      echo "system library: $(whereis libxslt.so)";
      echo "built library: ${global_build_usrprefix}/lib/libxslt.so";
      xslt_ldconfig_test_cmd="ldconfig -p | grep libxslt.so; ldconfig -v | grep libxslt.so";
      echo "list libraries: ${xslt_ldconfig_test_cmd}"; ${xslt_ldconfig_test_cmd};
    fi;
    # test binaries
    if [ "$xslt_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/xslt-config" ]; then
      xslt_binary_test_cmd1="xslt-config --libs --cflags";
      xslt_binary_test_cmd2="xslt-config --plugins";
      xslt_binary_test_cmd3="xslt-config --version";
      echo "test system binary #1: /usr/bin/${xslt_binary_test_cmd1}" && /usr/bin/${xslt_binary_test_cmd1};
      echo "test system binary #2: /usr/bin/${xslt_binary_test_cmd2}" && /usr/bin/${xslt_binary_test_cmd2};
      echo "test system binary #3: /usr/bin/${xslt_binary_test_cmd3}" && /usr/bin/${xslt_binary_test_cmd3};
      echo "test built binary #1: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd1}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd1};
      echo "test built binary #2: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd2}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd2};
      echo "test built binary #3: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd3}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd3};
    fi;
  fi;

  # - geoip
  if [ "$geoip_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$geoip_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${geoip_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$geoip_build_path" ]; then
      if [ ! -f "${geoip_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${geoip_build_url} && tar xzf ${geoip_build_tar}";
      fi;
    fi;
    cd $geoip_build_path;
    # compile binaries
    if [ "$geoip_build_make" == "yes" ]; then
      # command - add configuration tool
      geoip_build_cmd_full="./configure";

      # command - add arch
      if [ -n "$geoip_build_arg_arch" ]; then
        geoip_build_cmd_full="${geoip_build_cmd_full} --target=${geoip_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$geoip_build_arg_usrprefix" ]; then
        geoip_build_cmd_full="${geoip_build_cmd_full} --prefix=${geoip_build_arg_usrprefix}";
      fi;

      ## command - add libraries
      #if [ -n "$geoip_build_arg_libraries" ]; then
      #  geoip_build_cmd_full="${geoip_build_cmd_full} ${geoip_build_arg_libraries}";
      #fi;

      # command - add options
      if [ -n "$geoip_build_arg_options" ]; then
        geoip_build_cmd_full="${geoip_build_cmd_full} ${geoip_build_arg_options}";
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${geoip_build_cmd_full}";
      sudo $geoip_build_cmd_full && sudo make;
    fi;
    # install binaries
    if [ "$geoip_build_install" == "yes" ] && [ -f "${geoip_build_path}/libGeoIP/.libs/libGeoIP.so" ]; then
      sudo make uninstall; sudo make install;
      sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoIP.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoIP.dat.gz\" && rm -f GeoIP.dat && gunzip GeoIP.dat.gz";
      sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoIPv6.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz\" && rm -f GeoIPv6.dat && gunzip GeoIPv6.dat.gz";
      sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoLiteCity.dat.xz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.xz\" && rm -f GeoLiteCity.dat && unxz GeoLiteCity.dat.xz";
      sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoLiteCityv6.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoLiteCityv6.dat.gz\" && rm -f GeoLiteCityv6.dat && gunzip GeoLiteCityv6.dat.gz";
      echo "system library: $(whereis libGeoIP.so)";
      echo "built library: ${global_build_usrprefix}/lib/libGeoIP.so";
      geoip_ldconfig_test_cmd="ldconfig -p | grep libGeoIP.so; ldconfig -v | grep libGeoIP.so";
      echo "list libraries: ${geoip_ldconfig_test_cmd}"; ${geoip_ldconfig_test_cmd};
    fi;
  fi;

  # Build nginx
  if [ "$nginx_build_flag" == "yes" ]; then
    # cleanup code and tar
    if [ "$nginx_build_cleanup" == "yes" ]; then
      sudo rm -Rf ${nginx_build_path}*;
    fi;
    # extract code from tar
    if [ ! -d "$nginx_build_path" ]; then
      if [ ! -f "${nginx_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src; wget ${nginx_build_url} && tar xzf ${nginx_build_tar}";
      fi;
    fi;
    cd $nginx_build_path;
    # compile binaries
    if [ "$nginx_build_make" == "yes" ]; then
      # command - add configuration tool
      nginx_build_cmd_full="./configure";

      # command - add compiler
      if [ "$nginx_build_arg_compiler_flag" == "yes" ]; then
        # command - add compiler: li
        if [ "$nginx_build_arg_compiler_L_I" == "custom" ]; then
          nginx_build_arg_compiler_cc="${nginx_build_arg_compiler_cc} -I ${global_build_usrprefix}/include";
          nginx_build_arg_compiler_ld="${nginx_build_arg_compiler_ld} -L ${global_build_usrprefix}/lib";
        fi;

        # command - add compiler: cc
        if [ -n "$nginx_build_arg_compiler_cc" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-cc-opt=\'${nginx_build_arg_compiler_cc}\'";
        fi;

        # command - add compiler: ld
        if [ -n "$nginx_build_arg_compiler_ld" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-ld-opt=\'${nginx_build_arg_compiler_ld}\'";
        fi;
      fi;

      # command - add arch
      if [ -n "$nginx_build_arg_arch" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-cpu-opt=${nginx_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$nginx_build_arg_usrprefix" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --prefix=${nginx_build_arg_usrprefix}/share/nginx";
        nginx_build_cmd_full="${nginx_build_cmd_full} --sbin-path=${nginx_build_arg_usrprefix}/sbin/nginx";
        nginx_build_cmd_full="${nginx_build_cmd_full} --modules-path=${nginx_build_arg_usrprefix}/lib/nginx/modules";
      fi;
      # command - add prefix (var)
      if [ -n "$nginx_build_arg_varprefix" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-client-body-temp-path=${nginx_build_arg_varprefix}/lib/nginx/body";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-proxy-temp-path=${nginx_build_arg_varprefix}/lib/nginx/proxy";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-fastcgi-temp-path=${nginx_build_arg_varprefix}/lib/nginx/fastcgi";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-scgi-temp-path=${nginx_build_arg_varprefix}/lib/nginx/scgi";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-uwsgi-temp-path=${nginx_build_arg_varprefix}/lib/nginx/uwsgi";
        nginx_build_cmd_full="${nginx_build_cmd_full} --pid-path=${nginx_build_arg_varprefix}/run/nginx.pid";
        nginx_build_cmd_full="${nginx_build_cmd_full} --lock-path=${nginx_build_arg_varprefix}/lock/nginx.lock";
        nginx_build_cmd_full="${nginx_build_cmd_full} --error-log-path=${nginx_build_arg_varprefix}/log/nginx/error.log";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-log-path=${nginx_build_arg_varprefix}/log/nginx/access.log";
        nginx_build_cmd_full="${nginx_build_cmd_full} --conf-path=${nginx_build_arg_varprefix}/etc/nginx/nginx.conf";
      fi;

      # command - add libraries: zlib
      if [ "$nginx_build_arg_libraries_zlib" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_zlib" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-zlib=${zlib_build_path}";
      fi;

      # command - add libraries: pcre
      if [ "$nginx_build_arg_libraries_pcre" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_pcre" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-pcre=${pcre_build_path} --with-pcre-jit";
      elif [ "$nginx_build_arg_libraries_pcre" == "no" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --without-pcre";
      fi;

      # command - add libraries: openssl
      if [ "$nginx_build_arg_libraries_openssl" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_openssl" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl=${openssl_build_path}";
      fi;
      if [ "$nginx_build_arg_libraries_openssl" == "system" ] || [ "$nginx_build_arg_libraries_openssl" == "custom" ]; then
        # command - add openssl arch
        if [ -n "$openssl_build_arg_arch" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=${openssl_build_arg_arch}";
        fi;

        # command - add openssl options
        if [ -n "$openssl_build_arg_options" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=${openssl_build_arg_options}";
        fi;

        # command - add openssl main: threads
        if [ "$openssl_build_arg_main_threads" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=threads";
        elif [ "$openssl_build_arg_main_threads" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-threads";
        fi;

        # command - add openssl main: zlib
        if [ "$openssl_build_arg_main_zlib" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=zlib";
        fi;

        # command - add openssl main: nistp gcc
        if [ "$openssl_build_arg_main_nistp" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=enable-ec_nistp_64_gcc_128";
        fi;

        # command - add openssl proto: tls 1.3
        if [ "$openssl_build_arg_proto_tls1_3" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1_3";
        fi;

        # command - add openssl proto: tls 1.2
        if [ "$openssl_build_arg_proto_tls1_2" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1_2";
        fi;

        # command - add openssl proto: tls 1.1
        if [ "$openssl_build_arg_proto_tls1_1" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1_1";
        fi;

        # command - add openssl proto: tls 1.0
        if [ "$openssl_build_arg_proto_tls1_0" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1";
        fi;

        # command - add openssl proto: ssl 3
        if [ "$openssl_build_arg_proto_ssl3" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-ssl3";
        fi;

        # command - add openssl proto: ssl 2
        if [ "$openssl_build_arg_proto_ssl2" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-ssl2";
        fi;

        # command - add openssl proto: dtls 1.2
        if [ "$openssl_build_arg_proto_dtls1_2" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-dtls1_2";
        fi;

        # command - add openssl proto: dtls 1.0
        if [ "$openssl_build_arg_proto_dtls1_0" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-dtls1";
        fi;

        # command - add openssl proto: next proto negotiation
        if [ "$openssl_build_arg_proto_npn" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-nextprotoneg";
        fi;

        # command - add openssl cypher: idea
        if [ "$openssl_build_arg_cypher_idea" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-idea";
        fi;

        # command - add openssl cypher: weak ciphers
        if [ "$openssl_build_arg_cypher_weak" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-weak-ssl-ciphers";
        fi;
      fi;

      # command - add libraries: libatomic
      if [ "$nginx_build_arg_libraries_libatomic" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_libatomic" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-libatomic=${libatomic_build_path}";
      fi;

      # command - add options
      if [ -n "$nginx_build_arg_options" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} ${nginx_build_arg_options}";
      fi;

      # command - add main: distro
      if [ -n "$nginx_build_arg_main_distro" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --build=${nginx_build_arg_main_distro}";
      fi;

      # command - add main: user
      if [ -n "$nginx_build_arg_main_user" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --user=${nginx_build_arg_main_user}";
      fi;

      # command - add main: group
      if [ -n "$nginx_build_arg_main_group" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --group=${nginx_build_arg_main_group}";
      fi;

      # command - add main: debug
      if [ "$nginx_build_arg_main_debug_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-debug";
      fi;

      # command - add main: threads
      if [ "$nginx_build_arg_main_threads_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-threads";
      fi;

      # command - add main: asynchronous io
      if [ "$nginx_build_arg_main_fileaio_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-file-aio";
      fi;

      # command - add main: ipv6
      if [ "$nginx_build_arg_main_ipv6_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-ipv6";
      fi;

      # command - add main: (dynamic module) compat(ibility)
      if [ "$nginx_build_arg_main_compat_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-compat";
      fi;

      # command - add connection modules: poll
      if [ "$nginx_build_arg_module_poll_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-poll_module";
      elif [ "$nginx_build_arg_module_poll_flag" == "no" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --without-poll_module";
      fi;

      # command - add connection modules: select
      if [ "$nginx_build_arg_module_select_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-select_module";
      elif [ "$nginx_build_arg_module_select_flag" == "no" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --without-select_module";
      fi;

      if [ "$nginx_build_arg_modules_http_flag" == "yes" ]; then
        # command - add http modules: protocol: (http)v2
        if [ "$nginx_build_arg_modules_http_http2_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_v2_module";
        fi;

        # command - add http modules: protocol: spdy
        if [ "$nginx_build_arg_modules_http_spdy_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_spdy_module";
        fi;

        # command - add http modules: protocol: ssl
        if [ "$nginx_build_arg_modules_http_ssl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_ssl_module";
        fi;

       # command - add http modules: protocol: dav
        if [ "$nginx_build_arg_modules_http_webdav_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_dav_module";
        fi;

        # command - add http modules: core: rewrite
        if [ "$nginx_build_arg_modules_http_rewrite_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_rewrite_module";
        fi;

        # command - add http modules: core: map
        if [ "$nginx_build_arg_modules_http_map_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_map_module";
        fi;

        # command - add http modules: core: browser
        if [ "$nginx_build_arg_modules_http_browser_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_browser_module";
        fi;

        # command - add http modules: core: userid
        if [ "$nginx_build_arg_modules_http_userid_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_userid_module";
        fi;

        # command - add http modules: index: auto_index
        if [ "$nginx_build_arg_modules_http_autoindex_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_autoindex_module";
        fi;

        # command - add http modules: index: random_index
        if [ "$nginx_build_arg_modules_http_randomindex_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_random_index_module";
        fi;

        # command - add http modules: access/limit: access
        if [ "$nginx_build_arg_modules_http_access_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_access_module";
        fi;

        # command - add http modules: access/limit: limit_conn
        if [ "$nginx_build_arg_modules_http_limitconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_limit_conn_module";
        fi;

        # command - add http modules: access/limit: limit_req
        if [ "$nginx_build_arg_modules_http_limitreq_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_limit_req_module";
        fi;

        # command - add http modules: auth: auth_basic
        if [ "$nginx_build_arg_modules_http_authbasic_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_auth_basic_module";
        fi;

        # command - add http modules: auth: auth_(sub)request
        if [ "$nginx_build_arg_modules_http_authrequest_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_auth_request_module";
        fi;

        # command - add http modules: security: referer
        if [ "$nginx_build_arg_modules_http_referer_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_referer_module";
        fi;

        # command - add http modules: security: secure_link
        if [ "$nginx_build_arg_modules_http_securelink_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_secure_link_module";
        fi;

        # command - add http modules: location: realip
        if [ "$nginx_build_arg_modules_http_realip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_realip_module";
        fi;

        # command - add http modules: location: geo
        if [ "$nginx_build_arg_modules_http_geo_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_geo_module";
        fi;

        # command - add http modules: location: geoip --static
        if [ "$nginx_build_arg_modules_http_geoip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_geoip_module";
        fi;

        # command - add http modules: location: geoip --dso
        if [ "$nginx_build_arg_modules_http_geoip_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_geoip_module=dynamic";
        fi;

        # command - add http modules: encoding: gzip_static/gzip
        if [ "$nginx_build_arg_modules_http_gzip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_gzip_static_module";
        elif [ "$nginx_build_arg_modules_http_gzip_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_gzip_module";
        fi;

        # command - add http modules: encoding: gunzip
        if [ "$nginx_build_arg_modules_http_gunzip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_gunzip_module";
        fi;

        # command - add http modules: encoding: charset
        if [ "$nginx_build_arg_modules_http_charset_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_charset_module";
        fi;

        # command - add http modules: filter: empty_gif
        if [ "$nginx_build_arg_modules_http_emptygif_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_empty_gif_module";
        fi;

        # command - add http modules: filter: image_filter --static
        if [ "$nginx_build_arg_modules_http_imagefilter_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_image_filter_module";
        fi;

        # command - add http modules: filter: image_filter --dso
        if [ "$nginx_build_arg_modules_http_imagefilter_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_image_filter_module=dynamic";
        fi;

        # command - add http modules: filter: xslt --static
        if [ "$nginx_build_arg_modules_http_xslt_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_xslt_module";
        fi;

        # command - add http modules: filter: xslt --dso
        if [ "$nginx_build_arg_modules_http_xslt_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_xslt_module=dynamic";
        fi;

        # command - add http modules: filter: sub(stitute)
        if [ "$nginx_build_arg_modules_http_sub_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_sub_module";
        fi;

        # command - add http modules: filter: addition
        if [ "$nginx_build_arg_modules_http_addition_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_addition_module";
        fi;

        # command - add http modules: filter: slice
        if [ "$nginx_build_arg_modules_http_slice_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_slice_module";
        fi;

        # command - add http modules: pseudo-stream: mp4
        if [ "$nginx_build_arg_modules_http_mp4_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_mp4_module";
        fi;

        # command - add http modules: pseudo-stream: flv
        if [ "$nginx_build_arg_modules_http_flv_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_flv_module";
        fi;

        # command - add http modules: upstream: upstream_keepalive
        if [ "$nginx_build_arg_modules_http_upstream_keepalive_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_keepalive_module";
        fi;

        # command - add http modules: upstream: upstream_least_conn
        if [ "$nginx_build_arg_modules_http_upstream_leastconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_least_conn_module";
        fi;

        # command - add http modules: upstream: upstream_random
        if [ "$nginx_build_arg_modules_http_upstream_random_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_random_module";
        fi;

        # command - add http modules: upstream: upstream_hash
        if [ "$nginx_build_arg_modules_http_upstream_hash_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_hash_module";
        fi;

        # command - add http modules: upstream: upstream_ip_hash
        if [ "$nginx_build_arg_modules_http_upstream_iphash_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_ip_hash_module";
        fi;

        # command - add http modules: upstream: upstream_zone
        if [ "$nginx_build_arg_modules_http_upstream_zone_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_zone_module";
        fi;

        # command - add http modules: proxy/cgi: proxy
        if [ "$nginx_build_arg_modules_http_proxy_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_proxy_module";
        fi;

        # command - add http modules: proxy/cgi: fastcgi
        if [ "$nginx_build_arg_modules_http_fastcgi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_fastcgi_module";
        fi;

        # command - add http modules: proxy/cgi: scgi
        if [ "$nginx_build_arg_modules_http_scgi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_scgi_module";
        fi;

        # command - add http modules: proxy/cgi: uwsgi
        if [ "$nginx_build_arg_modules_http_uwsgi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_uwsgi_module";
        fi;

        # command - add http modules: proxy/cgi: grpc
        if [ "$nginx_build_arg_modules_http_grpc_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_grpc_module";
        fi;

        # command - add http modules: script: ssi
        if [ "$nginx_build_arg_modules_http_ssi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_ssi_module";
        fi;

        # command - add http modules: script: perl --static
        if [ "$nginx_build_arg_modules_http_perl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_perl_module";
        fi;

        # command - add http modules: script: perl --dso
        if [ "$nginx_build_arg_modules_http_perl_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_perl_module=dynamic";
        fi;

        # command - add http modules: cache
        if [ "$nginx_build_arg_modules_http_cache_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http-cache";
        fi;

        # command - add http modules: cache: memcached
        if [ "$nginx_build_arg_modules_http_memcached_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_memcached_module";
        fi;

        # command - add http modules: other: mirror
        if [ "$nginx_build_arg_modules_http_mirror_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_mirror_module";
        fi;

        # command - add http modules: other: split_clients
        if [ "$nginx_build_arg_modules_http_splitclients_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_split_clients_module";
        fi;

        # command - add http modules: other: stub_status:
        if [ "$nginx_build_arg_modules_http_stub_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_stub_status_module";
        fi;
      fi;

      # command - add stream modules
      if [ "$nginx_build_arg_modules_stream_flag" == "yes" ] || [ "$nginx_build_arg_modules_stream_flag" == "dso" ]; then
        # command - add stream modules: --static
        if [ "$nginx_build_arg_modules_stream_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream";
        fi;

        # command - add stream modules: --dso
        if [ "$nginx_build_arg_modules_stream_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream=dynamic";
        fi;

        # command - add stream modules: protocol: ssl
        if [ "$nginx_build_arg_modules_stream_ssl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_ssl_module";
        fi;

        # command - add stream modules: protocol: ssl_preread
        if [ "$nginx_build_arg_modules_stream_ssl_preread_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_ssl_preread_module";
        fi;

        # command - add stream modules: core: map
        if [ "$nginx_build_arg_modules_stream_map_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_map_module";
        fi;

        # command - add stream modules: access/limit: limit_conn
        if [ "$nginx_build_arg_modules_stream_limitconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_limit_conn_module";
        fi;

        # command - add stream modules: access/limit: access
        if [ "$nginx_build_arg_modules_stream_access_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_access_module";
        fi;

        # command - add stream modules: location: realip
        if [ "$nginx_build_arg_modules_stream_realip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_realip_module";
        fi;

        # command - add stream modules: location: geo
        if [ "$nginx_build_arg_modules_stream_geo_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_geo_module";
        fi;

        # command - add stream modules: location: geoip: --static
        if [ "$nginx_build_arg_modules_stream_geoip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_geoip_module";
        # command - add stream modules: location: geoip: --dso
        elif [ "$nginx_build_arg_modules_stream_geoip_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_geoip_module=dynamic";
        fi;

        # command - add stream modules: upstream: upstream_least_conn
        if [ "$nginx_build_arg_modules_stream_upstream_leastconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_least_conn_module";
        fi;

        # command - add stream modules: upstream: upstream_random
        if [ "$nginx_build_arg_modules_stream_upstream_random_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_random_module";
        fi;

        # command - add stream modules: upstream: upstream_hash
        if [ "$nginx_build_arg_modules_stream_upstream_hash_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_hash_module";
        fi;

        # command - add stream modules: upstream: upstream_zone
        if [ "$nginx_build_arg_modules_stream_upstream_zone_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_zone_module";
        fi;

        # command - add stream modules: other: return
        if [ "$nginx_build_arg_modules_stream_return_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_return_module";
        fi;

        # command - add stream modules: other: split_clients
        if [ "$nginx_build_arg_modules_stream_splitclients_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_split_clients_module";
        fi;
      fi;

      # command - add mail modules
      if [ "$nginx_build_arg_modules_mail_flag" == "yes" ] || [ "$nginx_build_arg_modules_mail_flag" == "dso" ]; then
        # command - add mail modules: --static
        if [ "$nginx_build_arg_modules_mail_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-mail";
        # command - add mail modules: --dso
        elif [ "$nginx_build_arg_modules_mail_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-mail=dynamic";
        fi;

        # command - add mail modules: protocol: ssl
        if [ "$nginx_build_arg_modules_mail_ssl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-mail_ssl_module";
        fi;

        # command - add mail modules: protocol: smtp
        if [ "$nginx_build_arg_modules_mail_smtp_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-mail_smtp_module";
        fi;

        # command - add mail modules: protocol: pop3
        if [ "$nginx_build_arg_modules_mail_pop3_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-mail_pop3_module";
        fi;

        # command - add mail modules: protocol: imap
        if [ "$nginx_build_arg_modules_mail_imap_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-mail_imap_module";
        fi;

      fi;

      # command - add other modules
      if [ "$nginx_build_arg_modules_other_flag" == "yes" ]; then
        # command - add other modules: cpp_test
        if [ "$nginx_build_arg_modules_other_cpptest_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-cpp_test_module";
        fi;

        # command - add other modules: google_perftools
        if [ "$nginx_build_arg_modules_other_googleperftools_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-google_perftools_module";
        fi;
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${nginx_build_cmd_full}";
      sudo bash -c "eval $nginx_build_cmd_full" && sudo make -j1;
      echo "system library: ldd /usr/sbin/nginx"; ldd /usr/sbin/nginx;
      echo "system library: ldd ${nginx_build_path}/objs/nginx"; ldd ${nginx_build_path}/objs/nginx;
      echo "env LD_DEBUG=statistics /usr/sbin/nginx -v"; env LD_DEBUG=statistics /usr/sbin/nginx -v;
      echo "env LD_DEBUG=statistics ${nginx_build_path}/objs/nginx -v"; env LD_DEBUG=statistics ${nginx_build_path}/objs/nginx -v;
    fi;
    # install binaries
    if [ "$nginx_build_install" == "yes" ] && [ -f "${nginx_build_path}/objs/nginx" ]; then
      sudo make uninstall; sudo make install;
      sudo mkdir -p "${global_build_varprefix}/lib/nginx";
      echo "system binary: $(whereis nginx)";
      echo "built binary: ${global_build_usrprefix}/sbin/nginx";
    fi;
    # install config
    if [ "$nginx_build_install_etc" == "system" ]; then
      if [ -d "${global_build_varprefix}/etc/nginx" ]; then
        sudo rm -Rf "${global_build_varprefix}/etc/nginx";
      elif [ -L "${global_build_varprefix}/etc/nginx" ]; then
        sudo rm -f "${global_build_varprefix}/etc/nginx";
      fi;
      sudo ln -s "/etc/nginx" "${global_build_varprefix}/etc/nginx";
      sudo rm -f "${global_build_varprefix}/etc/nginx/*.default";
    elif [ "$nginx_build_install_etc" == "build" ]; then
      sudo cp "${global_build_varprefix}/etc/nginx/*" "/etc/nginx";
    fi;
    # test binaries
    if [ "$nginx_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/sbin/nginx" ]; then
      nginx_test_cmd="nginx -v -V -t";
      echo "test system binary: sudo /usr/sbin/${nginx_test_cmd}"; sudo /usr/sbin/${nginx_test_cmd};
      echo "test built binary: sudo ${global_build_usrprefix}/sbin/${nginx_test_cmd}"; sudo ${global_build_usrprefix}/sbin/${nginx_test_cmd};
    fi;
  fi;

fi;
