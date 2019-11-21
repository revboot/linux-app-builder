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
  else
    notify "errorRoutine" "lib:openssl:package:uninstall";
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
  else
    notify "errorRoutine" "lib:openssl:package:install";
  fi;
  # whereis library
  echo "whereis package library: $(whereis libssl.so)";
}

# declare routine package:test
function task_lib_openssl_package_test() {
  # ldconfig tests
  openssl_ldconfig_test_file="libssl.so";
  if [ -f "${global_package_path_usr_lib}/${openssl_ldconfig_test_file}" ] || [ -f "${global_package_path_usr_lib64}/${openssl_ldconfig_test_file}" ]; then
    # check ldconfig paths
    openssl_ldconfig_test_cmd1="ldconfig -p | grep ${global_package_path_usr_lib} | grep ${openssl_ldconfig_test_file}";
    echo "find package libraries #1: sudo bash -c \"${openssl_ldconfig_test_cmd1}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd1}";
    # check ldconfig versions
    openssl_ldconfig_test_cmd2="ldconfig -v | grep ${openssl_ldconfig_test_file}";
    echo "find package libraries #2: sudo bash -c \"${openssl_ldconfig_test_cmd2}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:openssl:package:test";
  fi;
  # binary tests
  openssl_binary_test_cmd="${global_package_path_usr_bin}/openssl";
  if [ -f "$openssl_binary_test_cmd" ]; then
    # test binary
    openssl_binary_test_cmd1="${openssl_binary_test_cmd} version";
    echo "test package binary: ${openssl_binary_test_cmd1}";
    $openssl_binary_test_cmd1;
    openssl_binary_test_cmd2="${openssl_binary_test_cmd} version -f";
    echo "test package binary: ${openssl_binary_test_cmd2}";
    $openssl_binary_test_cmd2;
  else
    notify "errorRoutine" "lib:openssl:package:test";
  fi;
}

# declare routine source:cleanup
function task_lib_openssl_source_cleanup() {
  # remove source files
  if [ -d "$openssl_source_path" ]; then
    sudo rm -Rf "${openssl_source_path}"*;
  else
    notify "warnRoutine" "lib:openssl:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$openssl_source_tar" ]; then
    sudo rm -f "${openssl_source_tar}"*;
  else
    notify "warnRoutine" "lib:openssl:source:cleanup";
  fi;
}

# declare routine source:download
function task_lib_openssl_source_download() {
  if [ ! -d "$openssl_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$openssl_source_tar" ]; then
      sudo bash -c "cd \"${global_source_path_usr_src}\" && wget \"${openssl_source_url}\" -O \"${openssl_source_tar}\" && tar -xzf \"${openssl_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_path_usr_src}\" && tar -xzf \"${openssl_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "lib:openssl:source:download";
  fi;
}

# declare routine source:make
function task_lib_openssl_source_make() {
  if [ -d "$openssl_source_path" ]; then
    # config command - add configuration tool
    openssl_source_config_cmd="./Configure";

    # config command - add arch
    if [ -n "$openssl_source_arg_arch" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} ${openssl_source_arg_arch}";
    fi;

    # config command - add prefix (usr)
    if [ -n "$openssl_source_arg_prefix_usr" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} --prefix=${openssl_source_arg_prefix_usr}";
    fi;

    # config command - add libraries: zlib
    if [ "$openssl_source_arg_libraries_zlib" == "package" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} --with-zlib";
    elif [ "$openssl_source_arg_libraries_zlib" == "source" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} --with-zlib-include=${global_source_path_usr_inc} --with-zlib-lib=${global_source_path_usr_lib}";
    fi;

    # config command - add options
    if [ -n "$openssl_source_arg_options" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} ${openssl_source_arg_options}";
    fi;

    # config command - add main: threads
    if [ "$openssl_source_arg_main_threads" == "yes" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} threads";
    elif [ "$openssl_source_arg_main_threads" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-threads";
    fi;

    # config command - add main: zlib
    if [ "$openssl_source_arg_main_zlib" == "yes" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} zlib";
    fi;

    # config command - add main: nistp gcc
    if [ "$openssl_source_arg_main_nistp" == "yes" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} enable-ec_nistp_64_gcc_128";
    fi;

    # config command - add proto: tls 1.3
    if [ "$openssl_source_arg_proto_tls1_3" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-tls1_3";
    fi;

    # config command - add proto: tls 1.2
    if [ "$openssl_source_arg_proto_tls1_2" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-tls1_2";
    fi;

    # config command - add proto: tls 1.1
    if [ "$openssl_source_arg_proto_tls1_1" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-tls1_1";
    fi;

    # config command - add proto: tls 1.0
    if [ "$openssl_source_arg_proto_tls1_0" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-tls1";
    fi;

    # config command - add proto: ssl 3
    if [ "$openssl_source_arg_proto_ssl3" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-ssl3";
    fi;

    # config command - add proto: ssl 2
    if [ "$openssl_source_arg_proto_ssl2" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-ssl2";
    fi;

    # config command - add proto: dtls 1.2
    if [ "$openssl_source_arg_proto_dtls1_2" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-dtls1_2";
    fi;

    # config command - add proto: dtls 1.0
    if [ "$openssl_source_arg_proto_dtls1_0" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-dtls1";
    fi;

    # config command - add proto: next proto negotiation
    if [ "$openssl_source_arg_proto_npn" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-nextprotoneg";
    fi;

    # config command - add cypher: idea
    if [ "$openssl_source_arg_cypher_idea" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-idea";
    fi;

    # config command - add cypher: weak ciphers
    if [ "$openssl_source_arg_cypher_weak" == "no" ]; then
      openssl_source_config_cmd="${openssl_source_config_cmd} no-weak-ssl-ciphers";
    fi;

    # make command - add make tool
    openssl_source_make_cmd="make -j${global_source_make_cores}";

    # clean, configure and make
    sudo bash -c "cd \"${openssl_source_path}\" && make clean";
    echo "config arguments: ${openssl_source_config_cmd}";
    echo "make arguments: ${openssl_source_make_cmd}";
    sudo bash -c "cd \"${openssl_source_path}\" && eval ${openssl_source_config_cmd} && eval ${openssl_source_make_cmd}";
  else
    notify "errorRoutine" "lib:openssl:source:make";
  fi;
}

# declare routine source:uninstall
function task_lib_openssl_source_uninstall() {
  if [ -f "${global_source_path_usr_lib}/libssl.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${openssl_source_path}\" && make uninstall";
  else
    notify "errorRoutine" "lib:openssl:source:uninstall";
  fi;
}

# declare routine source:install
function task_lib_openssl_source_install() {
  if [ -f "$openssl_source_path/libssl.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${openssl_source_path}\" && make install";
    # whereis library
    echo "whereis source library: ${global_source_path_usr_lib}/libssl.so";
  else
    notify "errorRoutine" "lib:openssl:source:install";
  fi;
}

# declare routine source:test
function task_lib_openssl_source_test() {
  # ldconfig tests
  openssl_ldconfig_test_file="libssl.so";
  if [ -f "${global_source_path_usr_lib}/${openssl_ldconfig_test_file}" ]; then
    # check ldconfig paths
    openssl_ldconfig_test_cmd1="ldconfig -p | grep ${global_source_path_usr_lib} | grep ${openssl_ldconfig_test_file}";
    echo "find source libraries #1: sudo bash -c \"${openssl_ldconfig_test_cmd1}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd1}";
    # check ldconfig versions
    openssl_ldconfig_test_cmd2="ldconfig -v | grep ${openssl_ldconfig_test_file}";
    echo "find source libraries #2: sudo bash -c \"${openssl_ldconfig_test_cmd2}\"";
    sudo bash -c "${openssl_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:openssl:source:test";
  fi;
  # binary tests
  openssl_binary_test_cmd="${global_source_path_usr_bin}/openssl";
  if [ -f "$openssl_binary_test_cmd" ]; then
    # test binary
    openssl_binary_test_cmd1="${openssl_binary_test_cmd} version";
    echo "test source binary: ${openssl_binary_test_cmd1}";
    $openssl_binary_test_cmd1;
    openssl_binary_test_cmd2="${openssl_binary_test_cmd} version -f";
    echo "test source binary: ${openssl_binary_test_cmd2}";
    $openssl_binary_test_cmd2;
  else
    notify "errorRoutine" "lib:openssl:source:test";
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
