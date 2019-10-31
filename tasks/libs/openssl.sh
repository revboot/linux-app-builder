#!/bin/bash
#
# Task: Library: openssl
#

# task:lib:openssl:build:cleanup
function task_lib_openssl_build_cleanup() {
  # remove source files
  if [ -d "$openssl_build_path" ]; then
    sudo rm -Rf "${openssl_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$openssl_build_tar" ]; then
    sudo rm -f "${openssl_build_tar}"*;
  fi;
}

# task:lib:openssl:build:download
function task_lib_openssl_build_download() {
  if [ ! -d "$openssl_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$openssl_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${openssl_build_url}\" && tar xzf \"${openssl_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${openssl_build_tar}\"";
    fi;
  fi;
}

# task:lib:openssl:build:make
function task_lib_openssl_build_make() {
  if [ -d "$openssl_build_path" ]; then
    # command - add configuration tool
    openssl_build_cmd_full="./Configure";

    # command - add arch
    if [ -n "$openssl_build_arg_arch" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} ${openssl_build_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$openssl_build_arg_usrprefix" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} --prefix=${openssl_build_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$openssl_build_arg_libraries" ]; then
    #  openssl_build_cmd_full="${openssl_build_cmd_full} --libraries=${openssl_build_arg_libraries}";
    #fi;

    # command - add libraries: zlib
    if [ "$openssl_build_arg_libraries_zlib" == "system" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} --with-zlib";
    elif [ "$openssl_build_arg_libraries_zlib" == "custom" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} --with-zlib-include=${global_build_usrprefix}/include --with-zlib-lib=${global_build_usrprefix}/lib";
    fi;

    # command - add options
    if [ -n "$openssl_build_arg_options" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} ${openssl_build_arg_options}";
    fi;

    # command - add main: threads
    if [ "$openssl_build_arg_main_threads" == "yes" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} threads";
    elif [ "$openssl_build_arg_main_threads" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-threads";
    fi;

    # command - add main: zlib
    if [ "$openssl_build_arg_main_zlib" == "yes" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} zlib";
    fi;

    # command - add main: nistp gcc
    if [ "$openssl_build_arg_main_nistp" == "yes" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} enable-ec_nistp_64_gcc_128";
    fi;

    # command - add proto: tls 1.3
    if [ "$openssl_build_arg_proto_tls1_3" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1_3";
    fi;

    # command - add proto: tls 1.2
    if [ "$openssl_build_arg_proto_tls1_2" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1_2";
    fi;

    # command - add proto: tls 1.1
    if [ "$openssl_build_arg_proto_tls1_1" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1_1";
    fi;

    # command - add proto: tls 1.0
    if [ "$openssl_build_arg_proto_tls1_0" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-tls1";
    fi;

    # command - add proto: ssl 3
    if [ "$openssl_build_arg_proto_ssl3" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-ssl3";
    fi;

    # command - add proto: ssl 2
    if [ "$openssl_build_arg_proto_ssl2" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-ssl2";
    fi;

    # command - add proto: dtls 1.2
    if [ "$openssl_build_arg_proto_dtls1_2" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-dtls1_2";
    fi;

    # command - add proto: dtls 1.0
    if [ "$openssl_build_arg_proto_dtls1_0" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-dtls1";
    fi;

    # command - add proto: next proto negotiation
    if [ "$openssl_build_arg_proto_npn" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-nextprotoneg";
    fi;

    # command - add cypher: idea
    if [ "$openssl_build_arg_cypher_idea" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-idea";
    fi;

    # command - add cypher: weak ciphers
    if [ "$openssl_build_arg_cypher_weak" == "no" ]; then
      openssl_build_cmd_full="${openssl_build_cmd_full} no-weak-ssl-ciphers";
    fi;

    # clean, configure and make
    cd $openssl_build_path;
    sudo make clean;
    echo "${openssl_build_cmd_full}";
    sudo $openssl_build_cmd_full && \
    sudo make;
  fi;
}

# task:lib:openssl:build:install
function task_lib_openssl_build_install() {
  if [ -f "$openssl_build_path/libssl.so" ]; then
    # uninstall and install
    cd $openssl_build_path;
    sudo make uninstall;
    sudo make install;
    # find binary
    echo "system library: $(whereis libssl.so)";
    echo "built library: ${global_build_usrprefix}/lib/libssl.so";
    # check ldconfig
    openssl_ldconfig_test_cmd="ldconfig -p | grep libssl.so; ldconfig -v | grep libssl.so";
    echo "list libraries: ${openssl_ldconfig_test_cmd}"; ${openssl_ldconfig_test_cmd};
  fi;
}

function task_lib_openssl() {

  # build subtask
  if [ "$openssl_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:openssl:build";

    # run task:lib:openssl:build:cleanup
    if [ "$openssl_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:openssl:build:cleanup";
      task_lib_openssl_build_cleanup;
      notify "stopRoutine" "lib:openssl:build:cleanup";
    else
      notify "skipRoutine" "lib:openssl:build:cleanup";
    fi;

    # run task:lib:openssl:build:download
    if [ ! -d "$openssl_build_path" ]; then
      notify "startRoutine" "lib:openssl:build:download";
      task_lib_openssl_build_download;
      notify "stopRoutine" "lib:openssl:build:download";
    else
      notify "skipRoutine" "lib:openssl:build:download";
    fi;

    # run task:lib:openssl:build:make
    if [ "$openssl_build_make" == "yes" ]; then
      notify "startRoutine" "lib:openssl:build:make";
      task_lib_openssl_build_make;
      notify "stopRoutine" "lib:openssl:build:make";
    else
      notify "skipRoutine" "lib:openssl:build:make";
    fi;

    # run task:lib:openssl:build:install
    if [ "$openssl_build_install" == "yes" ]; then
      notify "startRoutine" "lib:openssl:build:install";
      task_lib_openssl_build_install;
      notify "stopRoutine" "lib:openssl:build:install";
    else
      notify "skipRoutine" "lib:openssl:build:install";
    fi;

    # test binaries
    if [ "$openssl_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/openssl" ]; then
      notify "startRoutine" "lib:openssl:build:test";
      openssl_binary_test_cmd="openssl version -f";
      echo "test system binary: /usr/bin/${openssl_binary_test_cmd}"; /usr/bin/$openssl_binary_test_cmd;
      echo "test built binary: ${global_build_usrprefix}/bin/${openssl_binary_test_cmd}"; ${global_build_usrprefix}/bin/${openssl_binary_test_cmd};
      notify "stopRoutine" "lib:openssl:build:test";
    else
      notify "skipRoutine" "lib:openssl:build:test";
    fi;

    notify "stopSubTask" "lib:openssl:build";
  else
    notify "skipSubTask" "lib:openssl:build";
  fi;

}
