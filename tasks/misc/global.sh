#!/bin/bash
#
# Task: Misc: global
#

# declare routine package:install
function task_misc_global_package_install() {
  # install binary packages
  if [ "$global_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $global_package_pkgs_bin;
  # install development packages
  elif [ "$global_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $global_package_pkgs_dev;
  # install both packages
  elif [ "$global_package_pkgs" == "both" ]; then
    sudo apt-get install -y $global_package_pkgs_bin $global_package_pkgs_dev;
  fi;
}

# declare routine source:cleanup
function task_misc_global_source_cleanup() {
  # remove usr files
  sudo rm -Rf ${global_source_usrprefix}/{src,include,lib,bin,sbin}/{zlib*,libz*,pcre*,libpcre*,openssl*,libssl*,gd2*,libgd*,xml2*,libxml*,xslt*,libxslt*,geoip*,GeoIP*,libGeoIP*,nginx*};
  # remove var files
  sudo rm -Rf ${global_source_varprefix}/{src,include,lib,bin,sbin}/{zlib*,libz*,pcre*,libpcre*,openssl*,libssl*,gd2*,libgd*,xml2*,libxml*,xslt*,libxslt*,geoip*,GeoIP*,libGeoIP*,nginx*};
}

# declare subtask package
function task_misc_global_package() {
  # run routine package:install
  if ([ "$global_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:global:package:install";
    task_misc_global_package_install;
    notify "stopRoutine" "lib:global:package:install";
  else
    notify "skipRoutine" "lib:global:package:install";
  fi;
}

# declare subtask source
function task_misc_global_source() {
  # run routine source:cleanup
  if ([ "$global_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:global:source:cleanup";
    task_misc_global_source_cleanup;
    notify "stopRoutine" "lib:global:source:cleanup";
  else
    notify "skipRoutine" "lib:global:source:cleanup";
  fi;
}

# declare task
function task_misc_global() {
  # run subtask package
  if ([ "$global_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:global:package";
    task_misc_global_package;
    notify "stopSubTask" "lib:global:package";
  else
    notify "skipSubTask" "lib:global:package";
  fi;

  # run subtask source
  if ([ "$global_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:global:source";
    task_misc_global_source;
    notify "stopSubTask" "lib:global:source";
  else
    notify "skipSubTask" "lib:global:source";
  fi;
}
