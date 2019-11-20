#!/bin/bash
#
# Task: Library: pcre
#

# declare routine package:uninstall
function task_lib_pcre_package_uninstall() {
  # uninstall binary packages
  if [ "$pcre_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $pcre_package_pkgs_bin;
  # uninstall development packages
  elif [ "$pcre_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $pcre_package_pkgs_dev;
  # uninstall both packages
  elif [ "$pcre_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $pcre_package_pkgs_bin $pcre_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:pcre:package:uninstall";
  fi;
}

# declare routine package:install
function task_lib_pcre_package_install() {
  # install binary packages
  if [ "$pcre_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $pcre_package_pkgs_bin;
  # install development packages
  elif [ "$pcre_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $pcre_package_pkgs_dev;
  # install both packages
  elif [ "$pcre_package_pkgs" == "both" ]; then
    sudo apt-get install -y $pcre_package_pkgs_bin $pcre_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:pcre:package:install";
  fi;
  # whereis library
  echo "whereis package library: $(whereis libpcre.so)";
}

# declare routine package:test
function task_lib_pcre_package_test() {
  # ldconfig tests
  pcre_ldconfig_test_cmd="${global_package_path_usr_lib64}/libpcre.so";
  if [ -f "$pcre_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    pcre_ldconfig_test_cmd1="ldconfig -p | grep ${pcre_ldconfig_test_cmd}";
    echo "find package libraries #1: sudo bash -c \"${pcre_ldconfig_test_cmd1}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd1}";
    # check ldconfig versions
    pcre_ldconfig_test_cmd2="ldconfig -v | grep libpcre.so";
    echo "find package libraries #2: sudo bash -c \"${pcre_ldconfig_test_cmd2}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:pcre:package:test";
  fi;
  # binary tests
  pcre_binary_test_cmd="${global_package_path_usr_bin}/pcre-config";
  if [ -f "$pcre_binary_test_cmd" ]; then
    # test binary
    pcre_binary_test_cmd="${pcre_binary_test_cmd} --version --libs --cflags";
    echo "test package binary: ${pcre_binary_test_cmd}";
    $pcre_binary_test_cmd;
  else
    notify "errorRoutine" "lib:pcre:package:test";
  fi;
}

# declare routine source:cleanup
function task_lib_pcre_source_cleanup() {
  # remove source files
  if [ -d "$pcre_source_path" ]; then
    sudo rm -Rf "${pcre_source_path}"*;
  else
    notify "warnRoutine" "lib:pcre:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$pcre_source_tar" ]; then
    sudo rm -f "${pcre_source_tar}"*;
  else
    notify "warnRoutine" "lib:pcre:source:cleanup";
  fi;
}

# declare routine source:download
function task_lib_pcre_source_download() {
  if [ ! -d "$pcre_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$pcre_source_tar" ]; then
      sudo bash -c "cd \"${global_source_path_usr_src}\" && wget \"${pcre_source_url}\" -O \"${pcre_source_tar}\" && tar -xzf \"${pcre_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_path_usr_src}\" && tar -xzf \"${pcre_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "lib:pcre:source:download";
  fi;
}

# declare routine source:make
function task_lib_pcre_source_make() {
  if [ -d "$pcre_source_path" ]; then
    # command - add configuration tool
    pcre_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$pcre_source_arg_arch" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --target=${pcre_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$pcre_source_arg_prefix_usr" ]; then
      pcre_source_cmd_full="${pcre_source_cmd_full} --prefix=${pcre_source_arg_prefix_usr}";
    fi;

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
  else
    notify "errorRoutine" "lib:pcre:source:make";
  fi;
}

# declare routine source:uninstall
function task_lib_pcre_source_uninstall() {
  if [ -f "${global_source_path_usr_lib}/libpcre.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${pcre_source_path}\" && make uninstall";
  else
    notify "errorRoutine" "lib:pcre:source:uninstall";
  fi;
}

# declare routine source:install
function task_lib_pcre_source_install() {
  if [ -f "$pcre_source_path/.libs/libpcre.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${pcre_source_path}\" && make install";
    # whereis library
    echo "whereis source library: ${global_source_path_usr_lib}/libpcre.so";
  else
    notify "errorRoutine" "lib:pcre:source:install";
  fi;
}

# declare routine source:test
function task_lib_pcre_source_test() {
  # ldconfig tests
  pcre_ldconfig_test_cmd="${global_source_path_usr_lib}/libpcre.so";
  if [ -f "$pcre_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    pcre_ldconfig_test_cmd1="ldconfig -p | grep ${pcre_ldconfig_test_cmd}";
    echo "find source libraries #1: sudo bash -c \"${pcre_ldconfig_test_cmd1}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd1}";
    # check ldconfig versions
    pcre_ldconfig_test_cmd2="ldconfig -v | grep libpcre.so";
    echo "find source libraries #2: sudo bash -c \"${pcre_ldconfig_test_cmd2}\"";
    sudo bash -c "${pcre_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:pcre:source:test";
  fi;
  # binary tests
  pcre_binary_test_cmd="${global_source_path_usr_bin}/pcre-config";
  if [ -f "$pcre_binary_test_cmd" ]; then
    # test binary
    pcre_binary_test_cmd="${pcre_binary_test_cmd} --version --libs --cflags";
    echo "test source binary: ${pcre_binary_test_cmd}";
    $pcre_binary_test_cmd;
  else
    notify "errorRoutine" "lib:pcre:source:test";
  fi;
}

# declare subtask package
function task_lib_pcre_package() {
  # run routine package:uninstall
  if ([ "$pcre_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:pcre:package:uninstall";
    task_lib_pcre_package_uninstall;
    notify "stopRoutine" "lib:pcre:package:uninstall";
  else
    notify "skipRoutine" "lib:pcre:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$pcre_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:pcre:package:install";
    task_lib_pcre_package_install;
    notify "stopRoutine" "lib:pcre:package:install";
  else
    notify "skipRoutine" "lib:pcre:package:install";
  fi;

  # run routine package:test
  if ([ "$pcre_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:pcre:package:test";
    task_lib_pcre_package_test;
    notify "stopRoutine" "lib:pcre:package:test";
  else
    notify "skipRoutine" "lib:pcre:package:test";
  fi;
}

# declare subtask source
function task_lib_pcre_source() {
  # run routine source:cleanup
  if ([ "$pcre_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:pcre:source:cleanup";
    task_lib_pcre_source_cleanup;
    notify "stopRoutine" "lib:pcre:source:cleanup";
  else
    notify "skipRoutine" "lib:pcre:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$pcre_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "lib:pcre:source:download";
    task_lib_pcre_source_download;
    notify "stopRoutine" "lib:pcre:source:download";
  else
    notify "skipRoutine" "lib:pcre:source:download";
  fi;

  # run routine source:make
  if ([ "$pcre_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "lib:pcre:source:make";
    task_lib_pcre_source_make;
    notify "stopRoutine" "lib:pcre:source:make";
  else
    notify "skipRoutine" "lib:pcre:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$pcre_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:pcre:source:uninstall";
    task_lib_pcre_source_uninstall;
    notify "stopRoutine" "lib:pcre:source:uninstall";
  else
    notify "skipRoutine" "lib:pcre:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$pcre_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:pcre:source:install";
    task_lib_pcre_source_install;
    notify "stopRoutine" "lib:pcre:source:install";
  else
    notify "skipRoutine" "lib:pcre:source:install";
  fi;

  # run routine source:test
  if ([ "$pcre_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:pcre:source:test";
    task_lib_pcre_source_test;
    notify "stopRoutine" "lib:pcre:source:test";
  else
    notify "skipRoutine" "lib:pcre:source:test";
  fi;
}

# declare task
function task_lib_pcre() {
  # run subtask package
  if ([ "$pcre_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:pcre:package";
    task_lib_pcre_package;
    notify "stopSubTask" "lib:pcre:package";
  else
    notify "skipSubTask" "lib:pcre:package";
  fi;

  # run subtask source
  if ([ "$pcre_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:pcre:source";
    task_lib_pcre_source;
    notify "stopSubTask" "lib:pcre:source";
  else
    notify "skipSubTask" "lib:pcre:source";
  fi;
}
