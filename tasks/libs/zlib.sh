#!/bin/bash
#
# Task: Library: zlib
#

# task:lib:zlib:build:cleanup
function task_lib_zlib_build_cleanup() {
  # remove source files
  if [ -d "$zlib_build_path" ]; then
    sudo rm -Rf "${zlib_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$zlib_build_tar" ]; then
    sudo rm -f "${zlib_build_tar}"*;
  fi;
}

# task:lib:zlib:build:download
function task_lib_zlib_build_download() {
  if [ ! -d "$zlib_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$zlib_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${zlib_build_url}\" && tar xzf \"${zlib_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${zlib_build_tar}\"";
    fi;
  fi;
}

# task:lib:zlib:build:make
function task_lib_zlib_build_make() {
  if [ -d "$zlib_build_path" ]; then
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
    cd $zlib_build_path;
    sudo make clean;
    echo "${zlib_build_cmd_full}";
    sudo $zlib_build_cmd_full && sudo make;
  fi;
}

function task_lib_zlib() {

  # build subtask
  if [ "$zlib_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:zlib:build";

    # run task:lib:zlib:build:cleanup
    if [ "$zlib_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:zlib:build:cleanup";
      task_lib_zlib_build_cleanup;
      notify "stopRoutine" "lib:zlib:build:cleanup";
    else
      notify "skipRoutine" "lib:zlib:build:cleanup";
    fi;

    # run task:lib:zlib:build:download
    if [ ! -d "$zlib_build_path" ]; then
      notify "startRoutine" "lib:zlib:build:download";
      task_lib_zlib_build_download;
      notify "stopRoutine" "lib:zlib:build:download";
    else
      notify "skipRoutine" "lib:zlib:build:download";
    fi;

    cd $zlib_build_path;

    # run task:lib:zlib:build:make
    if [ "$zlib_build_make" == "yes" ]; then
      notify "startRoutine" "lib:zlib:build:make";
      task_lib_zlib_build_make;
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
