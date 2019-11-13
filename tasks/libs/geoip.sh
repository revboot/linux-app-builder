#!/bin/bash
#
# Task: Library: geoip
#

# task:lib:geoip:apt:install
function task_lib_geoip_apt_install() {
  # install packages
  sudo apt-get install -y $geoip_apt_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libGeoIP.so)";
}

# task:lib:geoip:apt:test
function task_lib_geoip_apt_test() {
  # ldconfig tests
  geoip_ldconfig_test_cmd="/usr/lib/libGeoIP.so";
  if [ -f "$geoip_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    geoip_ldconfig_test_cmd1="ldconfig -p | grep ${geoip_ldconfig_test_cmd}";
    echo "find system libraries #1: sudo bash -c \"${geoip_ldconfig_test_cmd1}\"";
    sudo bash -c "${geoip_ldconfig_test_cmd1}";
    # check ldconfig versions
    geoip_ldconfig_test_cmd2="ldconfig -v | grep libGeoIP.so";
    echo "find system libraries #2: sudo bash -c \"${geoip_ldconfig_test_cmd2}\"";
    sudo bash -c "${geoip_ldconfig_test_cmd2}";
  fi;
}

# task:lib:geoip:build:cleanup
function task_lib_geoip_build_cleanup() {
  # remove source files
  if [ -d "$geoip_build_path" ]; then
    sudo rm -Rf "${geoip_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$geoip_build_tar" ]; then
    sudo rm -f "${geoip_build_tar}"*;
  fi;
}

# task:lib:geoip:build:download
function task_lib_geoip_build_download() {
  if [ ! -d "$geoip_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$geoip_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${geoip_build_url}\" && tar xzf \"${geoip_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${geoip_build_tar}\"";
    fi;
  fi;
}

# task:lib:geoip:build:make
function task_lib_geoip_build_make() {
  if [ -d "$geoip_build_path" ]; then
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
    sudo bash -c "cd \"${geoip_build_path}\" && make clean";
    echo "configure arguments: ${geoip_build_cmd_full}";
    sudo bash -c "cd \"${geoip_build_path}\" && eval ${geoip_build_cmd_full} && make";
  fi;
}

# task:lib:geoip:build:install
function task_lib_geoip_build_install() {
  if [ -f "$geoip_build_path/libGeoIP/.libs/libGeoIP.so" ]; then
    # uninstall and install
    sudo bash -c "cd \"${geoip_build_path}\" && make uninstall";
    sudo bash -c "cd \"${geoip_build_path}\" && make install";
    # download databases
    sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoIP.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoIP.dat.gz\" && rm -f GeoIP.dat && gunzip GeoIP.dat.gz";
    sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoIPv6.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz\" && rm -f GeoIPv6.dat && gunzip GeoIPv6.dat.gz";
    sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoLiteCity.dat.xz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.xz\" && rm -f GeoLiteCity.dat && unxz GeoLiteCity.dat.xz";
    sudo bash -c "cd \"${global_build_usrprefix}/share/GeoIP\" && rm -f GeoLiteCityv6.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoLiteCityv6.dat.gz\" && rm -f GeoLiteCityv6.dat && gunzip GeoLiteCityv6.dat.gz";
    # whereis library
    echo "whereis built library: ${global_build_usrprefix}/lib/libGeoIP.so";
  fi;
}

# task:lib:geoip:build:test
function task_lib_geoip_build_test() {
  # ldconfig tests
  geoip_ldconfig_test_cmd="${global_build_usrprefix}/lib/libGeoIP.so";
  if [ -f "$geoip_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    geoip_ldconfig_test_cmd1="ldconfig -p | grep ${geoip_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${geoip_ldconfig_test_cmd1}\"";
    sudo bash -c "${geoip_ldconfig_test_cmd1}";
    # check ldconfig versions
    geoip_ldconfig_test_cmd2="ldconfig -v | grep libGeoIP.so";
    echo "find built libraries #2: sudo bash -c \"${geoip_ldconfig_test_cmd2}\"";
    sudo bash -c "${geoip_ldconfig_test_cmd2}";
  fi;
}

function task_lib_geoip() {

  # apt subtask
  if [ "$geoip_apt_flag" == "yes" ]; then
    notify "startSubTask" "lib:geoip:apt";

    # run task:lib:geoip:apt:install
    if [ "$geoip_apt_install" == "yes" ]; then
      notify "startRoutine" "lib:geoip:apt:install";
      task_lib_geoip_apt_install;
      notify "stopRoutine" "lib:geoip:apt:install";
    else
      notify "skipRoutine" "lib:geoip:apt:install";
    fi;

    # run task:lib:geoip:apt:test
    if [ "$geoip_apt_test" == "yes" ]; then
      notify "startRoutine" "lib:geoip:apt:test";
      task_lib_geoip_apt_test;
      notify "stopRoutine" "lib:geoip:apt:test";
    else
      notify "skipRoutine" "lib:geoip:apt:test";
    fi;

    notify "stopSubTask" "lib:geoip:apt";
  else
    notify "skipSubTask" "lib:geoip:apt";
  fi;

  # build subtask
  if [ "$geoip_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:geoip:build";

    # run task:lib:geoip:build:cleanup
    if [ "$geoip_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:geoip:build:cleanup";
      task_lib_geoip_build_cleanup;
      notify "stopRoutine" "lib:geoip:build:cleanup";
    else
      notify "skipRoutine" "lib:geoip:build:cleanup";
    fi;

    # run task:lib:geoip:build:download
    if [ ! -d "$geoip_build_path" ]; then
      notify "startRoutine" "lib:geoip:build:download";
      task_lib_geoip_build_download;
      notify "stopRoutine" "lib:geoip:build:download";
    else
      notify "skipRoutine" "lib:geoip:build:download";
    fi;

    # run task:lib:geoip:build:make
    if [ "$geoip_build_make" == "yes" ]; then
      notify "startRoutine" "lib:geoip:build:make";
      task_lib_geoip_build_make;
      notify "stopRoutine" "lib:geoip:build:make";
    else
      notify "skipRoutine" "lib:geoip:build:make";
    fi;

    # run task:lib:geoip:build:install
    if [ "$geoip_build_install" == "yes" ]; then
      notify "startRoutine" "lib:geoip:build:install";
      task_lib_geoip_build_install;
      notify "stopRoutine" "lib:geoip:build:install";
    else
      notify "skipRoutine" "lib:geoip:build:install";
    fi;

    # run task:lib:geoip:build:test
    if [ "$geoip_build_test" == "yes" ]; then
      notify "startRoutine" "lib:geoip:build:test";
      task_lib_geoip_build_test;
      notify "stopRoutine" "lib:geoip:build:test";
    else
      notify "skipRoutine" "lib:geoip:build:test";
    fi;

    notify "stopSubTask" "lib:geoip:build";
  else
    notify "skipSubTask" "lib:geoip:build";
  fi;

}
