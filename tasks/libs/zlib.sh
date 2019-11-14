#!/bin/bash
#
# Task: Library: zlib
#

# task:lib:zlib:package:install
function task_lib_zlib_package_install() {
  # install packages
  sudo apt-get install -y $zlib_package_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libz.so)";
}

# task:lib:zlib:package:test
function task_lib_zlib_package_test() {
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

# task:lib:zlib:source:cleanup
function task_lib_zlib_source_cleanup() {
  # remove source files
  if [ -d "$zlib_source_path" ]; then
    sudo rm -Rf "${zlib_source_path}"*;
  fi;
  # remove source tar
  if [ -f "$zlib_source_tar" ]; then
    sudo rm -f "${zlib_source_tar}"*;
  fi;
}

# task:lib:zlib:source:download
function task_lib_zlib_source_download() {
  if [ ! -d "$zlib_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$zlib_source_tar" ]; then
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && wget \"${zlib_source_url}\" && tar xzf \"${zlib_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && tar xzf \"${zlib_source_tar}\"";
    fi;
  fi;
}

# task:lib:zlib:source:make
function task_lib_zlib_source_make() {
  if [ -d "$zlib_source_path" ]; then
    # command - add configuration tool
    zlib_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$zlib_source_arg_arch" ]; then
      zlib_source_cmd_full="${zlib_source_cmd_full} --archs=\"${zlib_source_arg_arch}\"";
    fi;

    # command - add prefix (usr)
    if [ -n "$zlib_source_arg_usrprefix" ]; then
      zlib_source_cmd_full="${zlib_source_cmd_full} --prefix=${zlib_source_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$zlib_source_arg_libraries" ]; then
    #  zlib_source_cmd_full="${zlib_source_cmd_full} --libraries=${zlib_source_arg_libraries}";
    #fi;

    # command - add options
    if [ -n "$zlib_source_arg_options" ]; then
      zlib_source_cmd_full="${zlib_source_cmd_full} ${zlib_source_arg_options}";
    fi;

    # clean, configure and make
    sudo bash -c "cd \"${zlib_source_path}\" && make clean";
    echo "configure arguments: ${zlib_source_cmd_full}";
    sudo bash -c "cd \"${zlib_source_path}\" && eval ${zlib_source_cmd_full} && make";
  fi;
}

# task:lib:zlib:source:install
function task_lib_zlib_source_install() {
  if [ -f "$zlib_source_path/libz.so" ]; then
    # uninstall and install
    sudo bash -c "cd \"${zlib_source_path}\" && make uninstall";
    sudo bash -c "cd \"${zlib_source_path}\" && make install";
    # whereis library
    echo "whereis built library: ${global_source_usrprefix}/lib/libz.so";
  fi;
}

# task:lib:zlib:source:test
function task_lib_zlib_source_test() {
  # ldconfig tests
  zlib_ldconfig_test_cmd="${global_source_usrprefix}/lib/libz.so";
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

  # package subtask
  if [ "$zlib_package_flag" == "yes" ]; then
    notify "startSubTask" "lib:zlib:package";

    # run task:lib:zlib:package:install
    if [ "$zlib_package_install" == "yes" ]; then
      notify "startRoutine" "lib:zlib:package:install";
      task_lib_zlib_package_install;
      notify "stopRoutine" "lib:zlib:package:install";
    else
      notify "skipRoutine" "lib:zlib:package:install";
    fi;

    # run task:lib:zlib:package:test
    if [ "$zlib_package_test" == "yes" ]; then
      notify "startRoutine" "lib:zlib:package:test";
      task_lib_zlib_package_test;
      notify "stopRoutine" "lib:zlib:package:test";
    else
      notify "skipRoutine" "lib:zlib:package:test";
    fi;

    notify "stopSubTask" "lib:zlib:package";
  else
    notify "skipSubTask" "lib:zlib:package";
  fi;

  # source subtask
  if [ "$zlib_source_flag" == "yes" ]; then
    notify "startSubTask" "lib:zlib:source";

    # run task:lib:zlib:source:cleanup
    if [ "$zlib_source_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:zlib:source:cleanup";
      task_lib_zlib_source_cleanup;
      notify "stopRoutine" "lib:zlib:source:cleanup";
    else
      notify "skipRoutine" "lib:zlib:source:cleanup";
    fi;

    # run task:lib:zlib:source:download
    if [ ! -d "$zlib_source_path" ]; then
      notify "startRoutine" "lib:zlib:source:download";
      task_lib_zlib_source_download;
      notify "stopRoutine" "lib:zlib:source:download";
    else
      notify "skipRoutine" "lib:zlib:source:download";
    fi;

    # run task:lib:zlib:source:make
    if [ "$zlib_source_make" == "yes" ]; then
      notify "startRoutine" "lib:zlib:source:make";
      task_lib_zlib_source_make;
      notify "stopRoutine" "lib:zlib:source:make";
    else
      notify "skipRoutine" "lib:zlib:source:make";
    fi;

    # run task:lib:zlib:source:install
    if [ "$zlib_source_install" == "yes" ]; then
      notify "startRoutine" "lib:zlib:source:install";
      task_lib_zlib_source_install;
      notify "stopRoutine" "lib:zlib:source:install";
    else
      notify "skipRoutine" "lib:zlib:source:install";
    fi;

    # run task:lib:zlib:source:test
    if [ "$zlib_source_test" == "yes" ]; then
      notify "startRoutine" "lib:zlib:source:test";
      task_lib_zlib_source_test;
      notify "stopRoutine" "lib:zlib:source:test";
    else
      notify "skipRoutine" "lib:zlib:source:test";
    fi;

    notify "stopSubTask" "lib:zlib:source";
  else
    notify "skipSubTask" "lib:zlib:source";
  fi;

}
