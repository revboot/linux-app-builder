#!/bin/bash
#
# Task: Library: zlib
#

# task:lib:zlib:apt:install
function task_lib_zlib_apt_install() {
  # install packages
  sudo apt-get install -y $zlib_apt_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libz.so)";
}

# task:lib:zlib:apt:test
function task_lib_zlib_apt_test() {
  # ldconfig tests
  zlib_ldconfig_test_cmd="/usr/lib/x86_64-linux-gnu/libz.so";
  if [ -f "$zlib_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    zlib_ldconfig_test_cmd1="ldconfig -p | grep ${zlib_ldconfig_test_cmd}";
    echo "find system libraries #1: sudo bash -c \"${zlib_ldconfig_test_cmd1}\"";
    sudo bash -c "${zlib_ldconfig_test_cmd1}";
    # check ldconfig versions
    zlib_ldconfig_test_cmd2="ldconfig -v | grep libz.so";
    echo "find system libraries #2: sudo bash -c \"${zlib_ldconfig_test_cmd2}\"";
    sudo bash -c "${zlib_ldconfig_test_cmd2}";
  fi;
}

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
    sudo bash -c "cd \"${zlib_build_path}\" && make clean";
    echo "configure arguments: ${zlib_build_cmd_full}";
    sudo bash -c "cd \"${zlib_build_path}\" && eval ${zlib_build_cmd_full} && make";
  fi;
}

# task:lib:zlib:build:install
function task_lib_zlib_build_install() {
  if [ -f "$zlib_build_path/libz.so" ]; then
    # uninstall and install
    sudo bash -c "cd \"${zlib_build_path}\" && make uninstall";
    sudo bash -c "cd \"${zlib_build_path}\" && make install";
    # whereis library
    echo "whereis built library: ${global_build_usrprefix}/lib/libz.so";
  fi;
}

# task:lib:zlib:build:test
function task_lib_zlib_build_test() {
  # ldconfig tests
  zlib_ldconfig_test_cmd="${global_build_usrprefix}/lib/libz.so";
  if [ -f "$zlib_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    zlib_ldconfig_test_cmd1="ldconfig -p | grep ${zlib_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${zlib_ldconfig_test_cmd1}\"";
    sudo bash -c "${zlib_ldconfig_test_cmd1}";
    # check ldconfig versions
    zlib_ldconfig_test_cmd2="ldconfig -v | grep libz.so";
    echo "find built libraries #2: sudo bash -c \"${zlib_ldconfig_test_cmd2}\"";
    sudo bash -c "${zlib_ldconfig_test_cmd2}";
  fi;
}

function task_lib_zlib() {

  # apt subtask
  if [ "$zlib_apt_flag" == "yes" ]; then
    notify "startSubTask" "lib:zlib:apt";

    # run task:lib:zlib:apt:install
    if [ "$zlib_apt_install" == "yes" ]; then
      notify "startRoutine" "lib:zlib:apt:install";
      task_lib_zlib_apt_install;
      notify "stopRoutine" "lib:zlib:apt:install";
    else
      notify "skipRoutine" "lib:zlib:apt:install";
    fi;

    # run task:lib:zlib:apt:test
    if [ "$zlib_apt_test" == "yes" ]; then
      notify "startRoutine" "lib:zlib:apt:test";
      task_lib_zlib_apt_test;
      notify "stopRoutine" "lib:zlib:apt:test";
    else
      notify "skipRoutine" "lib:zlib:apt:test";
    fi;

    notify "stopSubTask" "lib:zlib:apt";
  else
    notify "skipSubTask" "lib:zlib:apt";
  fi;

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

    # run task:lib:zlib:build:make
    if [ "$zlib_build_make" == "yes" ]; then
      notify "startRoutine" "lib:zlib:build:make";
      task_lib_zlib_build_make;
      notify "stopRoutine" "lib:zlib:build:make";
    else
      notify "skipRoutine" "lib:zlib:build:make";
    fi;

    # run task:lib:zlib:build:install
    if [ "$zlib_build_install" == "yes" ]; then
      notify "startRoutine" "lib:zlib:build:install";
      task_lib_zlib_build_install;
      notify "stopRoutine" "lib:zlib:build:install";
    else
      notify "skipRoutine" "lib:zlib:build:install";
    fi;

    # run task:lib:zlib:build:test
    if [ "$zlib_build_test" == "yes" ]; then
      notify "startRoutine" "lib:zlib:build:test";
      task_lib_zlib_build_test;
      notify "stopRoutine" "lib:zlib:build:test";
    else
      notify "skipRoutine" "lib:zlib:build:test";
    fi;

    notify "stopSubTask" "lib:zlib:build";
  else
    notify "skipSubTask" "lib:zlib:build";
  fi;

}
