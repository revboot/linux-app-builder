#!/bin/bash
#
# Task: Library: pcre
#

function task_lib_pcre() {

  # build subtask
  if [ "$pcre_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:pcre:build";

    # cleanup code and tar
    if [ "$pcre_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:pcre:build:cleanup";
      sudo rm -Rf ${pcre_build_path}*;
      notify "stopRoutine" "lib:pcre:build:cleanup";
    else
      notify "skipRoutine" "lib:pcre:build:cleanup";
    fi;

    # extract code from tar
    if [ ! -d "$pcre_build_path" ]; then
      notify "startRoutine" "lib:pcre:build:download";
      if [ ! -f "${pcre_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src && wget ${pcre_build_url} && tar xzf ${pcre_build_tar}";
      else
        sudo bash -c "cd ${global_build_usrprefix}/src && tar xzf ${pcre_build_tar}";
      fi;
      notify "stopRoutine" "lib:pcre:build:download";
    else
      notify "skipRoutine" "lib:pcre:build:download";
    fi;

    cd $pcre_build_path;

    # compile binaries
    if [ "$pcre_build_make" == "yes" ]; then
      notify "startRoutine" "lib:pcre:build:make";
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
      sudo make clean;
      echo "${pcre_build_cmd_full}";
      sudo $pcre_build_cmd_full && sudo make;
      notify "stopRoutine" "lib:pcre:build:make";
    else
      notify "skipRoutine" "lib:pcre:build:make";
    fi;

    # install binaries
    if [ "$pcre_build_install" == "yes" ] && [ -f "${pcre_build_path}/.libs/libpcre.so" ]; then
      notify "startRoutine" "lib:pcre:build:install";
      sudo make uninstall; sudo make install;
      echo "system library: ${pcre_link_cmd}$(whereis libpcre.so)";
      echo "built library: ${global_build_usrprefix}/lib/libpcre.so";
      pcre_ldconfig_test_cmd="ldconfig -p | grep libpcre.so; ldconfig -v | grep libpcre.so";
      echo "list libraries: ${pcre_ldconfig_test_cmd}"; ${pcre_ldconfig_test_cmd};
      notify "stopRoutine" "lib:pcre:build:install";
    else
      notify "skipRoutine" "lib:pcre:build:install";
    fi;

    # test binaries
    if [ "$pcre_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/pcre-config" ]; then
      notify "startRoutine" "lib:pcre:build:test";
      pcre_binary_test_cmd="pcre-config --version --libs --cflags";
      echo "test system binary: /usr/bin/${pcre_binary_test_cmd}"; /usr/bin/$pcre_binary_test_cmd;
      echo "test built binary: ${global_build_usrprefix}/bin/${pcre_binary_test_cmd}"; ${global_build_usrprefix}/bin/${pcre_binary_test_cmd};
      notify "stopRoutine" "lib:pcre:build:test";
    else
      notify "skipRoutine" "lib:pcre:build:test";
    fi;

    notify "stopSubTask" "lib:pcre:build";
  else
    notify "skipSubTask" "lib:pcre:build";
  fi;

}
