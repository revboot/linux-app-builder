#!/bin/bash
#
# Task: Application: haproxy
#

# declare routine package:uninstall
function task_app_haproxy_package_uninstall() {
  # uninstall binary packages
  if [ "$haproxy_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $haproxy_package_pkgs_bin;
  # uninstall development packages
  elif [ "$haproxy_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $haproxy_package_pkgs_dev;
  # uninstall both packages
  elif [ "$haproxy_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $haproxy_package_pkgs_bin $haproxy_package_pkgs_dev;
  else
    notify "errorRoutine" "app:haproxy:package:uninstall";
  fi;
}

# declare routine package:install
function task_app_haproxy_package_install() {
  # install binary packages
  if [ "$haproxy_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $haproxy_package_pkgs_bin;
  # install development packages
  elif [ "$haproxy_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $haproxy_package_pkgs_dev;
  # install both packages
  elif [ "$haproxy_package_pkgs" == "both" ]; then
    sudo apt-get install -y $haproxy_package_pkgs_bin $haproxy_package_pkgs_dev;
  else
    notify "errorRoutine" "app:haproxy:package:install";
  fi;
  # whereis binary
  echo "whereis package binary: $(whereis haproxy)";
}

# declare routine package:test
function task_app_haproxy_package_test() {
  # ldd, ld and binary tests
  haproxy_binary_test_cmd="${global_package_path_usr_sbin}/haproxy";
  if [ -f "$haproxy_binary_test_cmd" ]; then
    # print shared library dependencies
    haproxy_ldd_test_cmd="ldd ${haproxy_binary_test_cmd}";
    echo "shared library dependencies: ${haproxy_ldd_test_cmd}";
    $haproxy_ldd_test_cmd;
    # print ld debug statistics
    haproxy_lddebug_test_cmd="env LD_DEBUG=statistics $haproxy_binary_test_cmd -v";
    echo "ld debug statistics: ${haproxy_lddebug_test_cmd}";
    $haproxy_lddebug_test_cmd;
    # test binary
    haproxy_binary_test_cmd="${haproxy_binary_test_cmd} -vv";
    echo "test package binary: sudo ${haproxy_binary_test_cmd}";
    sudo $haproxy_binary_test_cmd;
  else
    notify "errorRoutine" "app:haproxy:package:test";
  fi;
}

# declare routine source:cleanup
function task_app_haproxy_source_cleanup() {
  # remove source files
  if [ -d "$haproxy_source_path" ]; then
    sudo rm -Rf "${haproxy_source_path}";
  else
    notify "warnRoutine" "app:haproxy:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$haproxy_source_tar" ]; then
    sudo rm -f "${haproxy_source_tar}";
  else
    notify "warnRoutine" "app:haproxy:source:cleanup";
  fi;
}

# declare routine source:download
function task_app_haproxy_source_download() {
  if [ ! -d "$haproxy_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$haproxy_source_tar" ]; then
      sudo bash -c "cd \"${global_source_path_usr_src}\" && wget \"${haproxy_source_url}\" -O \"${haproxy_source_tar}\" && tar -xzf \"${haproxy_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_path_usr_src}\" && tar -xzf \"${haproxy_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "app:haproxy:source:download";
  fi;
}

# declare routine source:make
function task_app_haproxy_source_make() {
  if [ -d "$haproxy_source_path" ]; then
    # make command - add make tool
    haproxy_source_make_cmd="make -j${global_source_make_cores}";

    # make command - add target
    if [ -n "$haproxy_source_arg_target" ]; then
      haproxy_source_make_cmd="${haproxy_source_make_cmd} TARGET=${haproxy_source_arg_target}";
    fi;

    # make command - add cpu
    if [ -n "$haproxy_source_arg_cpu" ]; then
      haproxy_source_make_cmd="${haproxy_source_make_cmd} CPU=${haproxy_source_arg_cpu}";
    fi;

    # make command - add arch
    if [ -n "$haproxy_source_arg_arch" ]; then
      haproxy_source_make_cmd="${haproxy_source_make_cmd} ARCH=${haproxy_source_arg_arch}";
    fi;

    # make command - add prefix
    if [ -n "$haproxy_source_arg_prefix_usr" ]; then
      haproxy_source_make_cmd="${haproxy_source_make_cmd} PREFIX=${haproxy_source_arg_prefix_usr}";
    fi;

    # make command - add options
    if [ -n "$haproxy_source_arg_options" ]; then
      haproxy_source_make_cmd="${haproxy_source_make_cmd} ${haproxy_source_arg_options}";
    fi;

    # clean and make
    sudo bash -c "cd \"${haproxy_source_path}\" && make clean";
    echo "make arguments: ${haproxy_source_make_cmd}";
    sudo bash -c "cd \"${haproxy_source_path}\" && eval ${haproxy_source_make_cmd}";
  else
    notify "errorRoutine" "app:haproxy:source:make";
  fi;
}

# declare routine source:uninstall
function task_app_haproxy_source_uninstall() {
  if [ -f "${global_source_path_usr_sbin}/haproxy" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${haproxy_source_path}\" && make uninstall";
  else
    notify "errorRoutine" "app:haproxy:source:uninstall";
  fi;
}

# declare routine source:install
function task_app_haproxy_source_install() {
  if [ -f "$haproxy_source_path//haproxy" ]; then
    # install binaries from source
    sudo bash -c "cd \"${haproxy_source_path}\" && make install";
    # whereis binary
    echo "whereis source binary: ${global_source_path_usr_sbin}/haproxy";
  else
    notify "errorRoutine" "app:haproxy:source:install";
  fi;
}

# declare routine source:test
function task_app_haproxy_source_test() {
  # ldd, ld and binary tests
  haproxy_binary_test_cmd="${global_source_path_usr_sbin}/haproxy";
  if [ -f "$haproxy_binary_test_cmd" ]; then
    # print shared library dependencies
    haproxy_ldd_test_cmd="ldd ${haproxy_binary_test_cmd}";
    echo "shared library dependencies: ${haproxy_ldd_test_cmd}";
    $haproxy_ldd_test_cmd;
    # print ld debug statistics
    haproxy_lddebug_test_cmd="env LD_DEBUG=statistics $haproxy_binary_test_cmd -v";
    echo "ld debug statistics: ${haproxy_lddebug_test_cmd}";
    $haproxy_lddebug_test_cmd;
    # test binary
    haproxy_binary_test_cmd="${haproxy_binary_test_cmd} -vv";
    echo "test source binary: sudo ${haproxy_binary_test_cmd}";
    sudo $haproxy_binary_test_cmd;
  else
    notify "errorRoutine" "app:haproxy:source:test";
  fi;
}

# declare subtask package
function task_app_haproxy_package() {
  # run routine package:uninstall
  if ([ "$haproxy_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "app:haproxy:package:uninstall";
    task_app_haproxy_package_uninstall;
    notify "stopRoutine" "app:haproxy:package:uninstall";
  else
    notify "skipRoutine" "app:haproxy:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$haproxy_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "app:haproxy:package:install";
    task_app_haproxy_package_install;
    notify "stopRoutine" "app:haproxy:package:install";
  else
    notify "skipRoutine" "app:haproxy:package:install";
  fi;

  # run routine package:test
  if ([ "$haproxy_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "app:haproxy:package:test";
    task_app_haproxy_package_test;
    notify "stopRoutine" "app:haproxy:package:test";
  else
    notify "skipRoutine" "app:haproxy:package:test";
  fi;
}

# declare subtask source
function task_app_haproxy_source() {
  # run routine source:cleanup
  if ([ "$haproxy_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "app:haproxy:source:cleanup";
    task_app_haproxy_source_cleanup;
    notify "stopRoutine" "app:haproxy:source:cleanup";
  else
    notify "skipRoutine" "app:haproxy:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$haproxy_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "app:haproxy:source:download";
    task_app_haproxy_source_download;
    notify "stopRoutine" "app:haproxy:source:download";
  else
    notify "skipRoutine" "app:haproxy:source:download";
  fi;

  # run routine source:make
  if ([ "$haproxy_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "app:haproxy:source:make";
    task_app_haproxy_source_make;
    notify "stopRoutine" "app:haproxy:source:make";
  else
    notify "skipRoutine" "app:haproxy:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$haproxy_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "app:haproxy:source:uninstall";
    task_app_haproxy_source_uninstall;
    notify "stopRoutine" "app:haproxy:source:uninstall";
  else
    notify "skipRoutine" "app:haproxy:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$haproxy_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "stopRoutine" "app:haproxy:source:install";
    task_app_haproxy_source_install;
    notify "stopRoutine" "app:haproxy:source:install";
  else
    notify "skipRoutine" "app:haproxy:source:install";
  fi;

  # run routine source:test
  if ([ "$haproxy_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "app:haproxy:source:test";
    task_app_haproxy_source_test;
    notify "stopRoutine" "app:haproxy:source:test";
  else
    notify "skipRoutine" "app:haproxy:source:test";
  fi;
}

# declare task
function task_app_haproxy() {
  # run subtask package
  if ([ "$haproxy_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "app:haproxy:package";
    task_app_haproxy_package;
    notify "stopSubTask" "app:haproxy:package";
  else
    notify "skipSubTask" "app:haproxy:package";
  fi;

  # run subtask source
  if ([ "$haproxy_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "app:haproxy:source";
    task_app_haproxy_source;
    notify "stopSubTask" "app:haproxy:source";
  else
    notify "skipSubTask" "app:haproxy:source";
  fi;
}
