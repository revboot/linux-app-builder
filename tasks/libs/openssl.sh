#!/bin/bash
#
# Task: Library: openssl
#

# declare routine package:uninstall
function task_lib_openssl_package_uninstall() {
  # uninstall binary packages
  if [ "$openssl_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $openssl_package_pkgs_bin;
  # uninstall development packages
  elif [ "$openssl_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $openssl_package_pkgs_dev;
  # uninstall both packages
  elif [ "$openssl_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $openssl_package_pkgs_bin $openssl_package_pkgs_dev;
  fi;
}

# declare routine package:install
function task_lib_openssl_package_install() {
  # install binary packages
  if [ "$openssl_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $openssl_package_pkgs_bin;
  # install development packages
  elif [ "$openssl_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $openssl_package_pkgs_dev;
  # install both packages
  elif [ "$openssl_package_pkgs" == "both" ]; then
    sudo apt-get install -y $openssl_package_pkgs_bin $openssl_package_pkgs_dev;
  fi;
  # whereis library
  echo "whereis system library: $(whereis libssl.so)";
}

# declare routine package:test
function task_lib_openssl_package_test() {
  # ldconfig tests
  openssl_ldconfig_test_cmd="/usr/lib/x86_64-linux-gnu/libssl.so";
  if [ -f "$openssl_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    openssl_ldconfig_test_cmd1="ldconfig -p | grep ${openssl_ldconfig_test_cmd}";
    echo "find system libraries #1: sudo bash -c \"${openssl_ldconfig_test_cmd1}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd1}";
    # check ldconfig versions
    openssl_ldconfig_test_cmd2="ldconfig -v | grep libssl.so";
    echo "find system libraries #2: sudo bash -c \"${openssl_ldconfig_test_cmd2}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd2}";
  fi;
  # binary tests
  openssl_binary_test_cmd="/usr/bin/openssl";
  if [ -f "$openssl_binary_test_cmd" ]; then
    # test binary
    openssl_binary_test_cmd="${openssl_binary_test_cmd} version -f";
    echo "test system binary: ${openssl_binary_test_cmd}";
    $openssl_binary_test_cmd;
  fi;
}

# declare routine source:cleanup
function task_lib_openssl_source_cleanup() {
  # remove source files
  if [ -d "$openssl_source_path" ]; then
    sudo rm -Rf "${openssl_source_path}"*;
  fi;
  # remove source tar
  if [ -f "$openssl_source_tar" ]; then
    sudo rm -f "${openssl_source_tar}"*;
  fi;
}

# declare routine source:download
function task_lib_openssl_source_download() {
  if [ ! -d "$openssl_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$openssl_source_tar" ]; then
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && wget \"${openssl_source_url}\" -O \"${openssl_source_tar}\" && tar -xzf \"${openssl_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && tar -xzf \"${openssl_source_tar}\"";
    fi;
  fi;
}

# declare routine source:make
function task_lib_openssl_source_make() {
  if [ -d "$openssl_source_path" ]; then
    # command - add configuration tool
    openssl_source_cmd_full="./Configure";

    # command - add arch
    if [ -n "$openssl_source_arg_arch" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} ${openssl_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$openssl_source_arg_usrprefix" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} --prefix=${openssl_source_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$openssl_source_arg_libraries" ]; then
    #  openssl_source_cmd_full="${openssl_source_cmd_full} --libraries=${openssl_source_arg_libraries}";
    #fi;

    # command - add libraries: zlib
    if [ "$openssl_source_arg_libraries_zlib" == "system" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} --with-zlib";
    elif [ "$openssl_source_arg_libraries_zlib" == "custom" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} --with-zlib-include=${global_source_usrprefix}/include --with-zlib-lib=${global_source_usrprefix}/lib";
    fi;

    # command - add options
    if [ -n "$openssl_source_arg_options" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} ${openssl_source_arg_options}";
    fi;

    # command - add main: threads
    if [ "$openssl_source_arg_main_threads" == "yes" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} threads";
    elif [ "$openssl_source_arg_main_threads" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-threads";
    fi;

    # command - add main: zlib
    if [ "$openssl_source_arg_main_zlib" == "yes" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} zlib";
    fi;

    # command - add main: nistp gcc
    if [ "$openssl_source_arg_main_nistp" == "yes" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} enable-ec_nistp_64_gcc_128";
    fi;

    # command - add proto: tls 1.3
    if [ "$openssl_source_arg_proto_tls1_3" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-tls1_3";
    fi;

    # command - add proto: tls 1.2
    if [ "$openssl_source_arg_proto_tls1_2" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-tls1_2";
    fi;

    # command - add proto: tls 1.1
    if [ "$openssl_source_arg_proto_tls1_1" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-tls1_1";
    fi;

    # command - add proto: tls 1.0
    if [ "$openssl_source_arg_proto_tls1_0" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-tls1";
    fi;

    # command - add proto: ssl 3
    if [ "$openssl_source_arg_proto_ssl3" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-ssl3";
    fi;

    # command - add proto: ssl 2
    if [ "$openssl_source_arg_proto_ssl2" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-ssl2";
    fi;

    # command - add proto: dtls 1.2
    if [ "$openssl_source_arg_proto_dtls1_2" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-dtls1_2";
    fi;

    # command - add proto: dtls 1.0
    if [ "$openssl_source_arg_proto_dtls1_0" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-dtls1";
    fi;

    # command - add proto: next proto negotiation
    if [ "$openssl_source_arg_proto_npn" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-nextprotoneg";
    fi;

    # command - add cypher: idea
    if [ "$openssl_source_arg_cypher_idea" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-idea";
    fi;

    # command - add cypher: weak ciphers
    if [ "$openssl_source_arg_cypher_weak" == "no" ]; then
      openssl_source_cmd_full="${openssl_source_cmd_full} no-weak-ssl-ciphers";
    fi;

    # clean, configure and make
    sudo bash -c "cd \"${openssl_source_path}\" && make clean";
    echo "configure arguments: ${openssl_source_cmd_full}";
    sudo bash -c "cd \"${openssl_source_path}\" && eval ${openssl_source_cmd_full} && make";
  fi;
}

# declare routine source:uninstall
function task_lib_openssl_source_uninstall() {
  if [ -f "${global_source_usrprefix}/lib/libssl.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${openssl_source_path}\" && make uninstall";
  fi;
}

# declare routine source:install
function task_lib_openssl_source_install() {
  if [ -f "$openssl_source_path/libssl.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${openssl_source_path}\" && make install";
    # whereis library
    echo "whereis built library: ${global_source_usrprefix}/lib/libssl.so";
  fi;
}

# declare routine source:test
function task_lib_openssl_source_test() {
  # ldconfig tests
  openssl_ldconfig_test_cmd="${global_source_usrprefix}/lib/libssl.so";
  if [ -f "$openssl_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    openssl_ldconfig_test_cmd1="ldconfig -p | grep ${openssl_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${openssl_ldconfig_test_cmd1}\"";
    sudo  bash -c "${openssl_ldconfig_test_cmd1}";
    # check ldconfig versions
    openssl_ldconfig_test_cmd2="ldconfig -v | grep libssl.so";
    echo "find built libraries #2: sudo bash -c \"${openssl_ldconfig_test_cmd2}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd2}";
  fi;
  # binary tests
  openssl_binary_test_cmd="${global_source_usrprefix}/bin/openssl";
  if [ -f "$openssl_binary_test_cmd" ]; then
    # test binary
    openssl_binary_test_cmd="${openssl_binary_test_cmd} version -f";
    echo "test built binary: ${openssl_binary_test_cmd}";
    $openssl_binary_test_cmd;
  fi;
}

# declare subtask package
function task_lib_openssl_package() {
  # run routine package:uninstall
  if ([ "$openssl_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:openssl:package:uninstall";
    task_lib_openssl_package_uninstall;
    notify "stopRoutine" "lib:openssl:package:uninstall";
  else
    notify "skipRoutine" "lib:openssl:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$openssl_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:openssl:package:install";
    task_lib_openssl_package_install;
    notify "stopRoutine" "lib:openssl:package:install";
  else
    notify "skipRoutine" "lib:openssl:package:install";
  fi;

  # run routine package:test
  if ([ "$openssl_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:openssl:package:test";
    task_lib_openssl_package_test;
    notify "stopRoutine" "lib:openssl:package:test";
  else
    notify "skipRoutine" "lib:openssl:package:test";
  fi;
}

# declare subtask source
function task_lib_openssl_source() {
  # run routine source:cleanup
  if ([ "$openssl_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:openssl:source:cleanup";
    task_lib_openssl_source_cleanup;
    notify "stopRoutine" "lib:openssl:source:cleanup";
  else
    notify "skipRoutine" "lib:openssl:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$openssl_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "lib:openssl:source:download";
    task_lib_openssl_source_download;
    notify "stopRoutine" "lib:openssl:source:download";
  else
    notify "skipRoutine" "lib:openssl:source:download";
  fi;

  # run routine source:make
  if ([ "$openssl_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "lib:openssl:source:make";
    task_lib_openssl_source_make;
    notify "stopRoutine" "lib:openssl:source:make";
  else
    notify "skipRoutine" "lib:openssl:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$openssl_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:openssl:source:uninstall";
    task_lib_openssl_source_uninstall;
    notify "stopRoutine" "lib:openssl:source:uninstall";
  else
    notify "skipRoutine" "lib:openssl:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$openssl_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:openssl:source:install";
    task_lib_openssl_source_install;
    notify "stopRoutine" "lib:openssl:source:install";
  else
    notify "skipRoutine" "lib:openssl:source:install";
  fi;

  # run routine source:test
  if ([ "$openssl_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:openssl:source:test";
    task_lib_openssl_source_test;
    notify "stopRoutine" "lib:openssl:source:test";
  else
    notify "skipRoutine" "lib:openssl:source:test";
  fi;
}

# declare task
function task_lib_openssl() {
  # run subtask package
  if ([ "$openssl_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:openssl:package";
    task_lib_openssl_package;
    notify "stopSubTask" "lib:openssl:package";
  else
    notify "skipSubTask" "lib:openssl:package";
  fi;

  # run subtask source
  if ([ "$openssl_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:openssl:source";
    task_lib_openssl_source;
    notify "stopSubTask" "lib:openssl:source";
  else
    notify "skipSubTask" "lib:openssl:source";
  fi;
}
