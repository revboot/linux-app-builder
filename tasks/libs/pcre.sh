#!/bin/bash
#
# Task: Library: pcre
#

# task:lib:pcre:package:install
function task_lib_pcre_package_install() {
  # install packages
  sudo apt-get install -y $pcre_package_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libpcre.so)";
}

# task:lib:pcre:package:test
function task_lib_pcre_package_test() {
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

# task:lib:pcre:source:cleanup
function task_lib_pcre_source_cleanup() {
  # remove source files
  if [ -d "$pcre_source_path" ]; then
    sudo rm -Rf "${pcre_source_path}"*;
  fi;
  # remove source tar
  if [ -f "$pcre_source_tar" ]; then
    sudo rm -f "${pcre_source_tar}"*;
  fi;
}

# task:lib:pcre:source:download
function task_lib_pcre_source_download() {
  if [ ! -d "$pcre_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$pcre_source_tar" ]; then
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && wget \"${pcre_source_url}\" && tar xzf \"${pcre_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && tar xzf \"${pcre_source_tar}\"";
    fi;
  fi;
}

# task:lib:pcre:source:make
function task_lib_pcre_source_make() {
  if [ -d "$pcre_source_path" ]; then
    # command - add configuration tool
    pcre_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$pcre_source_arg_arch" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --target=${pcre_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$pcre_source_arg_usrprefix" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --prefix=${pcre_source_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$pcre_source_arg_libraries" ]; then
    #  pcre_source_cmd_full="${pcre_source_cmd_full} --libraries=${pcre_source_arg_libraries}";
    #fi;

    # command - add options
    if [ -n "$pcre_source_arg_options" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} ${pcre_source_arg_options}";
    fi;

    # command - add main: pcre8
    if [ "$pcre_source_arg_main_pcre8" == "yes" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcre8";
    elif [ "$pcre_source_arg_main_pcre8" == "no" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --disable-pcre8";
    fi;

    # command - add main: pcre16
    if [ "$pcre_source_arg_main_pcre16" == "yes" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcre16";
    fi;

    # command - add main: pcre32
    if [ "$pcre_source_arg_main_pcre32" == "yes" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcre32";
    fi;

    # command - add main: jit
    if [ "$pcre_source_arg_main_jit" == "yes" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-jit=auto";
    fi;

    # command - add main: utf8
    if [ "$pcre_source_arg_main_utf8" == "yes" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-utf8";
    fi;

    # command - add main: unicode
    if [ "$pcre_source_arg_main_unicode" == "yes" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-unicode-properties";
    fi;

    # command - add tool: pcregreplib
    if [ "$pcre_source_arg_tool_pcregreplib" == "libz" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcregrep-libz";
    elif [ "$pcre_source_arg_tool_pcregreplib" == "libbz2" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcregrep-libbz2";
    fi;

    # command - add tool: pcretestlib
    if [ "$pcre_source_arg_tool_pcretestlib" == "libreadline" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcretest-libreadline";
    elif [ "$pcre_source_arg_tool_pcretestlib" == "libedit" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --enable-pcretest-libedit";
    fi;

    # clean, configure and make
    sudo bash -c "cd \"${pcre_source_path}\" && make clean";
    echo "configure arguments: ${pcre_source_cmd_full}";
    sudo bash -c "cd \"${pcre_source_path}\" && eval ${pcre_source_cmd_full} && make";
  fi;
}

# task:lib:pcre:source:install
function task_lib_pcre_source_install() {
  if [ -f "$pcre_source_path/.libs/libpcre.so" ]; then
    # uninstall and install
    sudo bash -c "cd \"${pcre_source_path}\" && make uninstall";
    sudo bash -c "cd \"${pcre_source_path}\" && make install";
    # whereis library
    echo "whereis built library: ${global_source_usrprefix}/lib/libpcre.so";
  fi;
}

# task:lib:pcre:source:test
function task_lib_pcre_source_test() {
  # ldconfig tests
  pcre_ldconfig_test_cmd="${global_source_usrprefix}/lib/libpcre.so";
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
  pcre_binary_test_cmd="${global_source_usrprefix}/bin/pcre-config";
  if [ -f "$pcre_binary_test_cmd" ]; then
    # test binary
    pcre_binary_test_cmd="${pcre_binary_test_cmd} --version --libs --cflags";
    echo "test built binary: ${pcre_binary_test_cmd}";
    $pcre_binary_test_cmd;
  fi;
}

function task_lib_pcre() {

  # package subtask
  if [ "$pcre_package_flag" == "yes" ]; then
    notify "startSubTask" "lib:pcre:package";

    # run task:lib:pcre:package:install
    if [ "$pcre_package_install" == "yes" ]; then
      notify "startRoutine" "lib:pcre:package:install";
      task_lib_pcre_package_install;
      notify "stopRoutine" "lib:pcre:package:install";
    else
      notify "skipRoutine" "lib:pcre:package:install";
    fi;

    # run task:lib:pcre:package:test
    if [ "$pcre_package_test" == "yes" ]; then
      notify "startRoutine" "lib:pcre:package:test";
      task_lib_pcre_package_test;
      notify "stopRoutine" "lib:pcre:package:test";
    else
      notify "skipRoutine" "lib:pcre:package:test";
    fi;

    notify "stopSubTask" "lib:pcre:package";
  else
    notify "skipSubTask" "lib:pcre:package";
  fi;

  # source subtask
  if [ "$pcre_source_flag" == "yes" ]; then
    notify "startSubTask" "lib:pcre:source";

    # run task:lib:pcre:source:cleanup
    if [ "$pcre_source_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:pcre:source:cleanup";
      task_lib_pcre_source_cleanup;
      notify "stopRoutine" "lib:pcre:source:cleanup";
    else
      notify "skipRoutine" "lib:pcre:source:cleanup";
    fi;

    # run task:lib:pcre:source:download
    if [ ! -d "$pcre_source_path" ]; then
      notify "startRoutine" "lib:pcre:source:download";
      task_lib_pcre_source_download;
      notify "stopRoutine" "lib:pcre:source:download";
    else
      notify "skipRoutine" "lib:pcre:source:download";
    fi;

    # run task:lib:pcre:source:make
    if [ "$pcre_source_make" == "yes" ]; then
      notify "startRoutine" "lib:pcre:source:make";
      task_lib_pcre_source_make;
      notify "stopRoutine" "lib:pcre:source:make";
    else
      notify "skipRoutine" "lib:pcre:source:make";
    fi;

    # run task:lib:pcre:source:install
    if [ "$pcre_source_install" == "yes" ]; then
      notify "startRoutine" "lib:pcre:source:install";
      task_lib_pcre_source_install;
      notify "stopRoutine" "lib:pcre:source:install";
    else
      notify "skipRoutine" "lib:pcre:source:install";
    fi;

    # run task:lib:pcre:source:test
    if [ "$pcre_source_test" == "yes" ]; then
      notify "startRoutine" "lib:pcre:source:test";
      task_lib_pcre_source_test;
      notify "stopRoutine" "lib:pcre:source:test";
    else
      notify "skipRoutine" "lib:pcre:source:test";
    fi;

    notify "stopSubTask" "lib:pcre:source";
  else
    notify "skipSubTask" "lib:pcre:source";
  fi;

}
