#!/bin/bash
#
# Task: Library: geoip
#

# declare routine package:uninstall
function task_lib_geoip_package_uninstall() {
  # uninstall binary packages
  if [ "$geoip_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $geoip_package_pkgs_bin;
  # uninstall development packages
  elif [ "$geoip_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $geoip_package_pkgs_dev;
  # uninstall both packages
  elif [ "$geoip_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $geoip_package_pkgs_bin $geoip_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:geoip:package:uninstall";
  fi;
}

# declare routine package:install
function task_lib_geoip_package_install() {
  # install binary packages
  if [ "$geoip_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $geoip_package_pkgs_bin;
  # install development packages
  elif [ "$geoip_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $geoip_package_pkgs_dev;
  # install both packages
  elif [ "$geoip_package_pkgs" == "both" ]; then
    sudo apt-get install -y $geoip_package_pkgs_bin $geoip_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:geoip:package:install";
  fi;
  # whereis library
  echo "whereis system library: $(whereis libGeoIP.so)";
}

# declare routine package:test
function task_lib_geoip_package_test() {
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
  else
    notify "errorRoutine" "lib:geoip:package:test";
  fi;
}

# declare routine source:cleanup
function task_lib_geoip_source_cleanup() {
  # remove source files
  if [ -d "$geoip_source_path" ]; then
    sudo rm -Rf "${geoip_source_path}"*;
  else
    notify "warnRoutine" "lib:geoip:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$geoip_source_tar" ]; then
    sudo rm -f "${geoip_source_tar}"*;
  else
    notify "warnRoutine" "lib:geoip:source:cleanup";
  fi;
}

# declare routine source:download
function task_lib_geoip_source_download() {
  if [ ! -d "$geoip_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$geoip_source_tar" ]; then
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && wget \"${geoip_source_url}\" -O \"${geoip_source_tar}\" && tar -xzf \"${geoip_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && tar -xzf \"${geoip_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "lib:geoip:source:download";
  fi;
}

# declare routine source:make
function task_lib_geoip_source_make() {
  if [ -d "$geoip_source_path" ]; then
    # command - add configuration tool
    geoip_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$geoip_source_arg_arch" ]; then
      geoip_source_cmd_full="${geoip_source_cmd_full} --target=${geoip_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$geoip_source_arg_usrprefix" ]; then
      geoip_source_cmd_full="${geoip_source_cmd_full} --prefix=${geoip_source_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$geoip_source_arg_libraries" ]; then
    #  geoip_source_cmd_full="${geoip_source_cmd_full} ${geoip_source_arg_libraries}";
    #fi;

    # command - add options
    if [ -n "$geoip_source_arg_options" ]; then
      geoip_source_cmd_full="${geoip_source_cmd_full} ${geoip_source_arg_options}";
    fi;

    # clean, configure and make
    sudo bash -c "cd \"${geoip_source_path}\" && make clean";
    echo "configure arguments: ${geoip_source_cmd_full}";
    sudo bash -c "cd \"${geoip_source_path}\" && eval ${geoip_source_cmd_full} && make";
  else
    notify "errorRoutine" "lib:geoip:source:make";
  fi;
}

# declare routine source:uninstall
function task_lib_geoip_source_uninstall() {
  if [ -f "${global_source_usrprefix}/lib/libGeoIP.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${geoip_source_path}\" && make uninstall";
  else
    notify "errorRoutine" "lib:geoip:source:uninstall";
  fi;
}

# declare routine source:install
function task_lib_geoip_source_install() {
  if [ -f "$geoip_source_path/libGeoIP/.libs/libGeoIP.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${geoip_source_path}\" && make install";
    # download databases
    sudo bash -c "cd \"${global_source_usrprefix}/share/GeoIP\" && rm -f GeoIP.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoIP.dat.gz\" && rm -f GeoIP.dat && gunzip GeoIP.dat.gz";
    sudo bash -c "cd \"${global_source_usrprefix}/share/GeoIP\" && rm -f GeoIPv6.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz\" && rm -f GeoIPv6.dat && gunzip GeoIPv6.dat.gz";
    sudo bash -c "cd \"${global_source_usrprefix}/share/GeoIP\" && rm -f GeoLiteCity.dat.xz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.xz\" && rm -f GeoLiteCity.dat && unxz GeoLiteCity.dat.xz";
    sudo bash -c "cd \"${global_source_usrprefix}/share/GeoIP\" && rm -f GeoLiteCityv6.dat.gz && wget \"https://mirrors-cdn.liferay.com/geolite.maxmind.com/download/geoip/database/GeoLiteCityv6.dat.gz\" && rm -f GeoLiteCityv6.dat && gunzip GeoLiteCityv6.dat.gz";
    # whereis library
    echo "whereis built library: ${global_source_usrprefix}/lib/libGeoIP.so";
  else
    notify "errorRoutine" "lib:geoip:source:install";
  fi;
}

# declare routine source:test
function task_lib_geoip_source_test() {
  # ldconfig tests
  geoip_ldconfig_test_cmd="${global_source_usrprefix}/lib/libGeoIP.so";
  if [ -f "$geoip_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    geoip_ldconfig_test_cmd1="ldconfig -p | grep ${geoip_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${geoip_ldconfig_test_cmd1}\"";
    sudo bash -c "${geoip_ldconfig_test_cmd1}";
    # check ldconfig versions
    geoip_ldconfig_test_cmd2="ldconfig -v | grep libGeoIP.so";
    echo "find built libraries #2: sudo bash -c \"${geoip_ldconfig_test_cmd2}\"";
    sudo bash -c "${geoip_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:geoip:source:test";
  fi;
}

# declare subtask package
function task_lib_geoip_package() {
  # run routine package:uninstall
  if ([ "$geoip_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:geoip:package:uninstall";
    task_lib_geoip_package_uninstall;
    notify "stopRoutine" "lib:geoip:package:uninstall";
  else
    notify "skipRoutine" "lib:geoip:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$geoip_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:geoip:package:install";
    task_lib_geoip_package_install;
    notify "stopRoutine" "lib:geoip:package:install";
  else
    notify "skipRoutine" "lib:geoip:package:install";
  fi;

  # run routine package:test
  if ([ "$geoip_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:geoip:package:test";
    task_lib_geoip_package_test;
    notify "stopRoutine" "lib:geoip:package:test";
  else
    notify "skipRoutine" "lib:geoip:package:test";
  fi;
}

# declare subtask source
function task_lib_geoip_source() {
  # run routine source:cleanup
  if ([ "$geoip_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:geoip:source:cleanup";
    task_lib_geoip_source_cleanup;
    notify "stopRoutine" "lib:geoip:source:cleanup";
  else
    notify "skipRoutine" "lib:geoip:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$geoip_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "lib:geoip:source:download";
    task_lib_geoip_source_download;
    notify "stopRoutine" "lib:geoip:source:download";
  else
    notify "skipRoutine" "lib:geoip:source:download";
  fi;

  # run routine source:make
  if ([ "$geoip_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "lib:geoip:source:make";
    task_lib_geoip_source_make;
    notify "stopRoutine" "lib:geoip:source:make";
  else
    notify "skipRoutine" "lib:geoip:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$geoip_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:geoip:source:uninstall";
    task_lib_geoip_source_uninstall;
    notify "stopRoutine" "lib:geoip:source:uninstall";
  else
    notify "skipRoutine" "lib:geoip:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$geoip_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:geoip:source:install";
    task_lib_geoip_source_install;
    notify "stopRoutine" "lib:geoip:source:install";
  else
    notify "skipRoutine" "lib:geoip:source:install";
  fi;

  # run routine source:test
  if ([ "$geoip_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:geoip:source:test";
    task_lib_geoip_source_test;
    notify "stopRoutine" "lib:geoip:source:test";
  else
    notify "skipRoutine" "lib:geoip:source:test";
  fi;
}

# declare task
function task_lib_geoip() {
  # run subtask package
  if ([ "$geoip_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:geoip:package";
    task_lib_geoip_package;
    notify "stopSubTask" "lib:geoip:package";
  else
    notify "skipSubTask" "lib:geoip:package";
  fi;

  # run subtask source
  if ([ "$geoip_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:geoip:source";
    task_lib_geoip_source;
    notify "stopSubTask" "lib:geoip:source";
  else
    notify "skipSubTask" "lib:geoip:source";
  fi;
}
