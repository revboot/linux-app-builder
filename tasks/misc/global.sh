#!/bin/bash
#
# Task: Misc: global
#

# task:misc:global:package:install
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

# task:misc:global:source:cleanup
function task_misc_global_source_cleanup() {
  # remove usr files
  sudo rm -Rf ${global_source_usrprefix}/{src,include,lib,bin,sbin}/{zlib*,libz*,pcre*,libpcre*,openssl*,libssl*,gd2*,libgd*,xml2*,libxml*,xslt*,libxslt*,geoip*,GeoIP*,libGeoIP*,nginx*};
  # remove var files
  sudo rm -Rf ${global_source_varprefix}/{src,include,lib,bin,sbin}/{zlib*,libz*,pcre*,libpcre*,openssl*,libssl*,gd2*,libgd*,xml2*,libxml*,xslt*,libxslt*,geoip*,GeoIP*,libGeoIP*,nginx*};
}

function task_misc_global() {

  # package subtask
  if ([ "$global_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:global:package";

    # run task:misc:global:package:install
    if ([ "$global_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
      notify "startRoutine" "lib:global:package:install";
      task_misc_global_package_install;
      notify "stopRoutine" "lib:global:package:install";
    else
      notify "skipRoutine" "lib:global:package:install";
    fi;

    notify "stopSubTask" "lib:global:package";
  else
    notify "skipSubTask" "lib:global:package";
  fi;

  # source subtask
  if ([ "$global_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:global:source";

    # run task:misc:global:source:cleanup
    if ([ "$global_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "cleanup" ]; then
      notify "startRoutine" "lib:global:source:cleanup";
      task_misc_global_source_cleanup;
      notify "stopRoutine" "lib:global:source:cleanup";
    else
      notify "skipRoutine" "lib:global:source:cleanup";
    fi;

    notify "stopSubTask" "lib:global:source";
  else
    notify "skipSubTask" "lib:global:source";
  fi;

}
