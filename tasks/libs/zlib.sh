#!/bin/bash
#
# Task: Library: zlib
#

function task_lib_zlib() {

  # build subtask
  if [ "$zlib_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:zlib:build";

    # cleanup code and tar
    if [ "$zlib_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:zlib:build:cleanup";
      sudo rm -Rf ${zlib_build_path}*;
      notify "stopRoutine" "lib:zlib:build:cleanup";
    else
      notify "skipRoutine" "lib:zlib:build:cleanup";
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
      notify "startRoutine" "lib:zlib:build:make";
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
      notify "stopRoutine" "lib:zlib:build:make";
    else
      notify "skipRoutine" "lib:zlib:build:make";
    fi;

    # install binaries
    if [ "$zlib_build_install" == "yes" ] && [ -f "${zlib_build_path}/libz.so" ]; then
      notify "startRoutine" "lib:zlib:build:install";
      sudo make uninstall; sudo make install;
      echo "system library: $(whereis libz.so)";
      echo "built library: ${global_build_usrprefix}/lib/libz.so";
      zlib_ldconfig_test_cmd="ldconfig -p | grep libz.so; ldconfig -v | grep libz.so";
      echo "list libraries: ${zlib_ldconfig_test_cmd}"; ${zlib_ldconfig_test_cmd};
      notify "stopRoutine" "lib:zlib:build:install";
    else
      notify "skipRoutine" "lib:zlib:build:install";
    fi;

    notify "stopSubTask" "lib:zlib:build";
  else
    notify "skipSubTask" "lib:zlib:build";
  fi;

}
