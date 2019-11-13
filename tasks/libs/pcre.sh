#!/bin/bash
#
# Task: Library: pcre
#

# task:lib:pcre:apt:install
function task_lib_pcre_apt_install() {
  # install packages
  sudo apt-get install -y $pcre_apt_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libpcre.so)";
}

# task:lib:pcre:apt:test
function task_lib_pcre_apt_test() {
  # ldconfig tests
  pcre_ldconfig_test_cmd="/usr/lib/x86_64-linux-gnu/libpcre.so";
  if [ -f "$pcre_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    pcre_ldconfig_test_cmd1="ldconfig -p | grep ${pcre_ldconfig_test_cmd}";
    echo "find system libraries #1: sudo bash -c \"${pcre_ldconfig_test_cmd1}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd1}";
    # check ldconfig versions
    pcre_ldconfig_test_cmd2="ldconfig -v | grep libpcre.so";
    echo "find system libraries #2: sudo bash -c \"${pcre_ldconfig_test_cmd2}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd2}";
  fi;
  # binary tests
  pcre_binary_test_cmd="/usr/bin/pcre-config";
  if [ -f "$pcre_binary_test_cmd" ]; then
    # test binary
    pcre_binary_test_cmd="${pcre_binary_test_cmd} --version --libs --cflags";
    echo "test system binary: ${pcre_binary_test_cmd}";
    $pcre_binary_test_cmd;
  fi;
}

# task:lib:pcre:build:cleanup
function task_lib_pcre_build_cleanup() {
  # remove source files
  if [ -d "$pcre_build_path" ]; then
    sudo rm -Rf "${pcre_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$pcre_build_tar" ]; then
    sudo rm -f "${pcre_build_tar}"*;
  fi;
}

# task:lib:pcre:build:download
function task_lib_pcre_build_download() {
  if [ ! -d "$pcre_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$pcre_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${pcre_build_url}\" && tar xzf \"${pcre_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${pcre_build_tar}\"";
    fi;
  fi;
}

# task:lib:pcre:build:make
function task_lib_pcre_build_make() {
  if [ -d "$pcre_build_path" ]; then
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
    sudo bash -c "cd \"${pcre_build_path}\" && make clean";
    echo "configure arguments: ${pcre_build_cmd_full}";
    sudo bash -c "cd \"${pcre_build_path}\" && eval ${pcre_build_cmd_full} && make";
  fi;
}

# task:lib:pcre:build:install
function task_lib_pcre_build_install() {
  if [ -f "$pcre_build_path/.libs/libpcre.so" ]; then
    # uninstall and install
    sudo bash -c "cd \"${pcre_build_path}\" && make uninstall";
    sudo bash -c "cd \"${pcre_build_path}\" && make install";
    # whereis library
    echo "whereis built library: ${global_build_usrprefix}/lib/libpcre.so";
  fi;
}

# task:lib:pcre:build:test
function task_lib_pcre_build_test() {
  # ldconfig tests
  pcre_ldconfig_test_cmd="${global_build_usrprefix}/lib/libpcre.so";
  if [ -f "$pcre_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    pcre_ldconfig_test_cmd1="ldconfig -p | grep ${pcre_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${pcre_ldconfig_test_cmd1}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd1}";
    # check ldconfig versions
    pcre_ldconfig_test_cmd2="ldconfig -v | grep libpcre.so";
    echo "find built libraries #2: sudo bash -c \"${pcre_ldconfig_test_cmd2}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd2}";
  fi;
  # binary tests
  pcre_binary_test_cmd="${global_build_usrprefix}/bin/pcre-config";
  if [ -f "$pcre_binary_test_cmd" ]; then
    # test binary
    pcre_binary_test_cmd="${pcre_binary_test_cmd} --version --libs --cflags";
    echo "test built binary: ${pcre_binary_test_cmd}";
    $pcre_binary_test_cmd;
  fi;
}

function task_lib_pcre() {

  # apt subtask
  if [ "$pcre_apt_flag" == "yes" ]; then
    notify "startSubTask" "lib:pcre:apt";

    # run task:lib:pcre:apt:install
    if [ "$pcre_apt_install" == "yes" ]; then
      notify "startRoutine" "lib:pcre:apt:install";
      task_lib_pcre_apt_install;
      notify "stopRoutine" "lib:pcre:apt:install";
    else
      notify "skipRoutine" "lib:pcre:apt:install";
    fi;

    # run task:lib:pcre:apt:test
    if [ "$pcre_apt_test" == "yes" ]; then
      notify "startRoutine" "lib:pcre:apt:test";
      task_lib_pcre_apt_test;
      notify "stopRoutine" "lib:pcre:apt:test";
    else
      notify "skipRoutine" "lib:pcre:apt:test";
    fi;

    notify "stopSubTask" "lib:pcre:apt";
  else
    notify "skipSubTask" "lib:pcre:apt";
  fi;

  # build subtask
  if [ "$pcre_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:pcre:build";

    # run task:lib:pcre:build:cleanup
    if [ "$pcre_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:pcre:build:cleanup";
      task_lib_pcre_build_cleanup;
      notify "stopRoutine" "lib:pcre:build:cleanup";
    else
      notify "skipRoutine" "lib:pcre:build:cleanup";
    fi;

    # run task:lib:pcre:build:download
    if [ ! -d "$pcre_build_path" ]; then
      notify "startRoutine" "lib:pcre:build:download";
      task_lib_pcre_build_download;
      notify "stopRoutine" "lib:pcre:build:download";
    else
      notify "skipRoutine" "lib:pcre:build:download";
    fi;

    # run task:lib:pcre:build:make
    if [ "$pcre_build_make" == "yes" ]; then
      notify "startRoutine" "lib:pcre:build:make";
      task_lib_pcre_build_make;
      notify "stopRoutine" "lib:pcre:build:make";
    else
      notify "skipRoutine" "lib:pcre:build:make";
    fi;

    # run task:lib:pcre:build:install
    if [ "$pcre_build_install" == "yes" ]; then
      notify "startRoutine" "lib:pcre:build:install";
      task_lib_pcre_build_install;
      notify "stopRoutine" "lib:pcre:build:install";
    else
      notify "skipRoutine" "lib:pcre:build:install";
    fi;

    # run task:lib:pcre:build:test
    if [ "$pcre_build_test" == "yes" ]; then
      notify "startRoutine" "lib:pcre:build:test";
      task_lib_pcre_build_test;
      notify "stopRoutine" "lib:pcre:build:test";
    else
      notify "skipRoutine" "lib:pcre:build:test";
    fi;

    notify "stopSubTask" "lib:pcre:build";
  else
    notify "skipSubTask" "lib:pcre:build";
  fi;

}
