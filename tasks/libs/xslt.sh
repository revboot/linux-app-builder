#!/bin/bash
#
# Task: Library: xslt
#

# task:lib:xslt:apt:install
function task_lib_xslt_apt_install() {
  # install packages
  sudo apt-get install -y $xslt_apt_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libxslt.so)";
}

# task:lib:xslt:apt:test
function task_lib_xslt_apt_test() {
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

# task:lib:xslt:build:cleanup
function task_lib_xslt_build_cleanup() {
  # remove source files
  if [ -d "$xslt_build_path" ]; then
    sudo rm -Rf "${xslt_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$xslt_build_tar" ]; then
    sudo rm -f "${xslt_build_tar}"*;
  fi;
}

# task:lib:xslt:build:download
function task_lib_xslt_build_download() {
  if [ ! -d "$xslt_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$xslt_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${xslt_build_url}\" && tar xzf \"${xslt_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${xslt_build_tar}\"";
    fi;
  fi;
}

# task:lib:xslt:build:make
function task_lib_xslt_build_make() {
  if [ -d "$xslt_build_path" ]; then
    # command - add configuration tool
    xslt_build_cmd_full="./configure";

    # command - add arch
    if [ -n "$xslt_build_arg_arch" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --target=${xslt_build_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$xslt_build_arg_usrprefix" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --prefix=${xslt_build_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$xslt_build_arg_libraries" ]; then
    #  xslt_build_cmd_full="${xslt_build_cmd_full} ${xslt_build_arg_libraries}";
    #fi;

    # command - add libraries: xml2
    if [ "$xslt_build_arg_libraries_xml2" == "system" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --with-libxml-prefix";
    elif [ "$xslt_build_arg_libraries_xml2" == "custom" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --with-libxml-prefix=${global_build_usrprefix}";
    fi;

    # command - add libraries: python
    if [ "$xslt_build_arg_libraries_python" == "system" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --with-python";
    elif [ "$xslt_build_arg_libraries_python" == "custom" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --with-python=${python_build_path}";
    fi;

    # command - add options
    if [ -n "$xslt_build_arg_options" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} ${xslt_build_arg_options}";
    fi;

    # command - add main: crypto
    if [ "$xslt_build_arg_main_crypto" == "yes" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --with-crypto";
    fi;

    # command - add main: plugins
    if [ "$xslt_build_arg_main_plugins" == "yes" ]; then
      xslt_build_cmd_full="${xslt_build_cmd_full} --with-plugins";
    fi;

    # clean
    sudo bash -c "cd \"${xslt_build_path}\" && make clean";
    # download docbook (workaround)
    sudo wget -P $xslt_build_path/doc "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd";
    sudo wget -P $xslt_build_path/doc "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl";
    # configure (workaround) and make
    echo "configure arguments: ${xslt_build_cmd_full}";
    sudo bash -c "cd \"${xslt_build_path}\" && libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf && eval ${xslt_build_cmd_full} && make";
  fi;
}

# task:lib:xslt:build:install
function task_lib_xslt_build_install() {
  if [ -f "$xslt_build_path/libxslt/.libs/libxslt.so" ]; then
    # uninstall and install
    sudo bash -c "cd \"${xslt_build_path}\" && make uninstall";
    sudo bash -c "cd \"${xslt_build_path}\" && make install";
    # copy missing binaries to system
    sudo cp "${xslt_build_path}/xsltproc/.libs/xsltproc" "${global_build_usrprefix}/bin/xsltproc";
    sudo cp "${xslt_build_path}/xslt-config" "${global_build_usrprefix}/bin/xslt-config";
    sudo chmod +x "${global_build_usrprefix}/bin/xslt-config";
    # whereis library
    echo "whereis built library: ${global_build_usrprefix}/lib/libxslt.so";
  fi;
}

# task:lib:xslt:build:test
function task_lib_xslt_build_test() {
  # ldconfig tests
  xslt_ldconfig_test_cmd="${global_build_usrprefix}/lib/libxslt.so";
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
  xslt_binary_test_cmd="${global_build_usrprefix}/bin/xslt-config";
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

function task_lib_xslt() {

  # apt subtask
  if [ "$xslt_apt_flag" == "yes" ]; then
    notify "startSubTask" "lib:xslt:apt";

    # run task:lib:xslt:apt:install
    if [ "$xslt_apt_install" == "yes" ]; then
      notify "startRoutine" "lib:xslt:apt:install";
      task_lib_xslt_apt_install;
      notify "stopRoutine" "lib:xslt:apt:install";
    else
      notify "skipRoutine" "lib:xslt:apt:install";
    fi;

    # run task:lib:xslt:apt:test
    if [ "$xslt_apt_test" == "yes" ]; then
      notify "startRoutine" "lib:xslt:apt:test";
      task_lib_xslt_apt_test;
      notify "stopRoutine" "lib:xslt:apt:test";
    else
      notify "skipRoutine" "lib:xslt:apt:test";
    fi;

    notify "stopSubTask" "lib:xslt:apt";
  else
    notify "skipSubTask" "lib:xslt:apt";
  fi;

  # build subtask
  if [ "$xslt_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:xslt:build";

    # run task:lib:xslt:build:cleanup
    if [ "$xslt_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:xslt:build:cleanup";
      task_lib_xslt_build_cleanup;
      notify "stopRoutine" "lib:xslt:build:cleanup";
    else
      notify "skipRoutine" "lib:xslt:build:cleanup";
    fi;

    # run task:lib:xslt:build:download
    if [ ! -d "$xslt_build_path" ]; then
      notify "startRoutine" "lib:xslt:build:download";
      task_lib_xslt_build_download;
      notify "stopRoutine" "lib:xslt:build:download";
    else
      notify "skipRoutine" "lib:xslt:build:download";
    fi;

    # run task:lib:xslt:build:make
    if [ "$xslt_build_make" == "yes" ]; then
      notify "startRoutine" "lib:xslt:build:make";
      task_lib_xslt_build_make;
      notify "stopRoutine" "lib:xslt:build:make";
    else
      notify "skipRoutine" "lib:xslt:build:make";
    fi;

    # run task:lib:xslt:build:install
    if [ "$xslt_build_install" == "yes" ]; then
      notify "startRoutine" "lib:xslt:build:install";
      task_lib_xslt_build_install;
      notify "stopRoutine" "lib:xslt:build:install";
    else
      notify "skipRoutine" "lib:xslt:build:install";
    fi;

    # run task:lib:xslt:build:test
    if [ "$xslt_build_test" == "yes" ]; then
      notify "startRoutine" "lib:xslt:build:test";
      task_lib_xslt_build_test;
      notify "stopRoutine" "lib:xslt:build:test";
    else
      notify "skipRoutine" "lib:xslt:build:test";
    fi;

    notify "stopSubTask" "lib:xslt:build";
  else
    notify "skipSubTask" "lib:xslt:build";
  fi;

}
