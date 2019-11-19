#!/bin/bash
#
# Task: Library: xslt
#

# declare routine package:uninstall
function task_lib_xslt_package_uninstall() {
  # uninstall binary packages
  if [ "$xslt_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $xslt_package_pkgs_bin;
  # uninstall development packages
  elif [ "$xslt_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $xslt_package_pkgs_dev;
  # uninstall both packages
  elif [ "$xslt_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $xslt_package_pkgs_bin $xslt_package_pkgs_dev;
  fi;
}

# declare routine package:install
function task_lib_xslt_package_install() {
  # install binary packages
  if [ "$xslt_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $xslt_package_pkgs_bin;
  # install development packages
  elif [ "$xslt_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $xslt_package_pkgs_dev;
  # install both packages
  elif [ "$xslt_package_pkgs" == "both" ]; then
    sudo apt-get install -y $xslt_package_pkgs_bin $xslt_package_pkgs_dev;
  fi;
  # whereis library
  echo "whereis system library: $(whereis libxslt.so)";
}

# declare routine package:test
function task_lib_xslt_package_test() {
  # ldconfig tests
  xslt_ldconfig_test_cmd="/usr/lib/x86_64-linux-gnu/libxslt.so";
  if [ -f "$xslt_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    xslt_ldconfig_test_cmd1="ldconfig -p | grep ${xslt_ldconfig_test_cmd}";
    echo "find system libraries #1: sudo bash -c \"${xslt_ldconfig_test_cmd1}\"";
    sudo bash -c "${xslt_ldconfig_test_cmd1}";
    # check ldconfig versions
    xslt_ldconfig_test_cmd2="ldconfig -v | grep libxslt.so";
    echo "find system libraries #2: sudo bash -c \"${xslt_ldconfig_test_cmd2}\"";
    sudo bash -c "${xslt_ldconfig_test_cmd2}";
  fi;
  # binary tests
  xslt_binary_test_cmd="/usr/bin/xslt-config";
  if [ -f "$xslt_binary_test_cmd" ]; then
    # test binary #1,#2,#3
    xslt_binary_test_cmd1="${xslt_binary_test_cmd} --libs --cflags";
    echo "test system binary #1: ${xslt_binary_test_cmd1}";
    $xslt_binary_test_cmd1;
    xslt_binary_test_cmd2="${xslt_binary_test_cmd} --plugins";
    echo "test system binary #2: ${xslt_binary_test_cmd2}";
    $xslt_binary_test_cmd2;
    xslt_binary_test_cmd3="${xslt_binary_test_cmd} --version";
    echo "test system binary #3: ${xslt_binary_test_cmd3}";
    $xslt_binary_test_cmd3;
  fi;
}

# declare routine source:cleanup
function task_lib_xslt_source_cleanup() {
  # remove source files
  if [ -d "$xslt_source_path" ]; then
    sudo rm -Rf "${xslt_source_path}"*;
  fi;
  # remove source tar
  if [ -f "$xslt_source_tar" ]; then
    sudo rm -f "${xslt_source_tar}"*;
  fi;
}

# declare routine source:download
function task_lib_xslt_source_download() {
  if [ ! -d "$xslt_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$xslt_source_tar" ]; then
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && wget \"${xslt_source_url}\" -O \"${xslt_source_tar}\" && tar -xzf \"${xslt_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && tar -xzf \"${xslt_source_tar}\"";
    fi;
  fi;
}

# declare routine source:make
function task_lib_xslt_source_make() {
  if [ -d "$xslt_source_path" ]; then
    # command - add configuration tool
    xslt_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$xslt_source_arg_arch" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --target=${xslt_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$xslt_source_arg_usrprefix" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --prefix=${xslt_source_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$xslt_source_arg_libraries" ]; then
    #  xslt_source_cmd_full="${xslt_source_cmd_full} ${xslt_source_arg_libraries}";
    #fi;

    # command - add libraries: xml2
    if [ "$xslt_source_arg_libraries_xml2" == "system" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --with-libxml-prefix";
    elif [ "$xslt_source_arg_libraries_xml2" == "custom" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --with-libxml-prefix=${global_source_usrprefix}";
    fi;

    # command - add libraries: python
    if [ "$xslt_source_arg_libraries_python" == "system" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --with-python";
    elif [ "$xslt_source_arg_libraries_python" == "custom" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --with-python=${python_source_path}";
    fi;

    # command - add options
    if [ -n "$xslt_source_arg_options" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} ${xslt_source_arg_options}";
    fi;

    # command - add main: crypto
    if [ "$xslt_source_arg_main_crypto" == "yes" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --with-crypto";
    fi;

    # command - add main: plugins
    if [ "$xslt_source_arg_main_plugins" == "yes" ]; then
      xslt_source_cmd_full="${xslt_source_cmd_full} --with-plugins";
    fi;

    # clean
    sudo bash -c "cd \"${xslt_source_path}\" && make clean";
    # download docbook (workaround)
    sudo wget -P $xslt_source_path/doc "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd";
    sudo wget -P $xslt_source_path/doc "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl";
    # configure (workaround) and make
    echo "configure arguments: ${xslt_source_cmd_full}";
    sudo bash -c "cd \"${xslt_source_path}\" && libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf && eval ${xslt_source_cmd_full} && make";
  fi;
}

# declare routine source:uninstall
function task_lib_xslt_source_uninstall() {
  if [ -f "${global_source_usrprefix}/lib/libxslt.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${xslt_source_path}\" && make uninstall";
  fi;
}

# declare routine source:install
function task_lib_xslt_source_install() {
  if [ -f "$xslt_source_path/libxslt/.libs/libxslt.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${xslt_source_path}\" && make install";
    # copy missing binaries to system
    sudo cp "${xslt_source_path}/xsltproc/.libs/xsltproc" "${global_source_usrprefix}/bin/xsltproc";
    sudo cp "${xslt_source_path}/xslt-config" "${global_source_usrprefix}/bin/xslt-config";
    sudo chmod +x "${global_source_usrprefix}/bin/xslt-config";
    # whereis library
    echo "whereis built library: ${global_source_usrprefix}/lib/libxslt.so";
  fi;
}

# declare routine source:test
function task_lib_xslt_source_test() {
  # ldconfig tests
  xslt_ldconfig_test_cmd="${global_source_usrprefix}/lib/libxslt.so";
  if [ -f "$xslt_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    xslt_ldconfig_test_cmd1="ldconfig -p | grep ${xslt_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${xslt_ldconfig_test_cmd1}\"";
    sudo bash -c "${xslt_ldconfig_test_cmd1}";
    # check ldconfig versions
    xslt_ldconfig_test_cmd2="ldconfig -v | grep libxslt.so";
    echo "find built libraries #2: sudo bash -c \"${xslt_ldconfig_test_cmd2}\"";
    sudo bash -c "${xslt_ldconfig_test_cmd2}";
  fi;
  # binary tests
  xslt_binary_test_cmd="${global_source_usrprefix}/bin/xslt-config";
  if [ -f "$xslt_binary_test_cmd" ]; then
    # test binary #1,#2,#3
    xslt_binary_test_cmd1="${xslt_binary_test_cmd} --libs --cflags";
    echo "test built binary #1: ${xslt_binary_test_cmd1}";
    $xslt_binary_test_cmd1;
    xslt_binary_test_cmd2="${xslt_binary_test_cmd} --plugins";
    echo "test built binary #2: ${xslt_binary_test_cmd2}";
    $xslt_binary_test_cmd2;
    xslt_binary_test_cmd3="${xslt_binary_test_cmd} --version";
    echo "test built binary #3: ${xslt_binary_test_cmd3}";
    $xslt_binary_test_cmd3;
  fi;
}

# declare subtask package
function task_lib_xslt_package() {
  # run routine package:uninstall
  if ([ "$xslt_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:xslt:package:uninstall";
    task_lib_xslt_package_uninstall;
    notify "stopRoutine" "lib:xslt:package:uninstall";
  else
    notify "skipRoutine" "lib:xslt:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$xslt_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:xslt:package:install";
    task_lib_xslt_package_install;
    notify "stopRoutine" "lib:xslt:package:install";
  else
    notify "skipRoutine" "lib:xslt:package:install";
  fi;

  # run routine package:test
  if ([ "$xslt_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:xslt:package:test";
    task_lib_xslt_package_test;
    notify "stopRoutine" "lib:xslt:package:test";
  else
    notify "skipRoutine" "lib:xslt:package:test";
  fi;
}

# declare subtask source
function task_lib_xslt_source() {
  # run routine source:cleanup
  if ([ "$xslt_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:xslt:source:cleanup";
    task_lib_xslt_source_cleanup;
    notify "stopRoutine" "lib:xslt:source:cleanup";
  else
    notify "skipRoutine" "lib:xslt:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$xslt_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "lib:xslt:source:download";
    task_lib_xslt_source_download;
    notify "stopRoutine" "lib:xslt:source:download";
  else
    notify "skipRoutine" "lib:xslt:source:download";
  fi;

  # run routine source:make
  if ([ "$xslt_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "lib:xslt:source:make";
    task_lib_xslt_source_make;
    notify "stopRoutine" "lib:xslt:source:make";
  else
    notify "skipRoutine" "lib:xslt:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$xslt_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:xslt:source:uninstall";
    task_lib_xslt_source_uninstall;
    notify "stopRoutine" "lib:xslt:source:uninstall";
  else
    notify "skipRoutine" "lib:xslt:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$xslt_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:xslt:source:install";
    task_lib_xslt_source_install;
    notify "stopRoutine" "lib:xslt:source:install";
  else
    notify "skipRoutine" "lib:xslt:source:install";
  fi;

  # run routine source:test
  if ([ "$xslt_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:xslt:source:test";
    task_lib_xslt_source_test;
    notify "stopRoutine" "lib:xslt:source:test";
  else
    notify "skipRoutine" "lib:xslt:source:test";
  fi;
}

# declare task
function task_lib_xslt() {
  # run subtask package
  if ([ "$xslt_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:xslt:package";
    task_lib_xslt_package;
    notify "stopSubTask" "lib:xslt:package";
  else
    notify "skipSubTask" "lib:xslt:package";
  fi;

  # run subtask source
  if ([ "$xslt_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:xslt:source";
    task_lib_xslt_source;
    notify "stopSubTask" "lib:xslt:source";
  else
    notify "skipSubTask" "lib:xslt:source";
  fi;
}
