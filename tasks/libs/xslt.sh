#!/bin/bash
#
# Task: Library: xslt
#

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
    cd $xslt_build_path;
    sudo make clean;
    # download docbook (workaround)
    sudo wget -P $xslt_build_path/doc "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd";
    sudo wget -P $xslt_build_path/doc "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl";
    # configure (workaround) and make
    echo "${xslt_build_cmd_full}";
    sudo bash -c "libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf" && \
    sudo $xslt_build_cmd_full && \
    sudo make;
  fi;
}

# task:lib:xslt:build:install
function task_lib_xslt_build_install() {
  if [ -f "$xslt_build_path/libxslt/.libs/libxslt.so" ]; then
    # uninstall and install
    cd $xslt_build_path;
    sudo make uninstall;
    sudo make install;
    # copy missing binaries to system
    sudo cp "${xslt_build_path}/xsltproc/.libs/xsltproc" "${global_build_usrprefix}/bin/xsltproc";
    sudo cp "${xslt_build_path}/xslt-config" "${global_build_usrprefix}/bin/xslt-config";
    sudo chmod +x "${global_build_usrprefix}/bin/xslt-config";
    # find binary
    echo "system library: $(whereis libxslt.so)";
    echo "built library: ${global_build_usrprefix}/lib/libxslt.so";
    # check ldconfig
    xslt_ldconfig_test_cmd="ldconfig -p | grep libxslt.so; ldconfig -v | grep libxslt.so";
    echo "list libraries: ${xslt_ldconfig_test_cmd}"; ${xslt_ldconfig_test_cmd};
  fi;
}

# task:lib:xslt:build:test
function task_lib_xslt_build_test() {
  if [ -f "${global_build_usrprefix}/bin/xslt-config" ]; then
    # test binary
    xslt_binary_test_cmd1="xslt-config --libs --cflags";
    xslt_binary_test_cmd2="xslt-config --plugins";
    xslt_binary_test_cmd3="xslt-config --version";
    echo "test system binary #1: /usr/bin/${xslt_binary_test_cmd1}" && /usr/bin/${xslt_binary_test_cmd1};
    echo "test system binary #2: /usr/bin/${xslt_binary_test_cmd2}" && /usr/bin/${xslt_binary_test_cmd2};
    echo "test system binary #3: /usr/bin/${xslt_binary_test_cmd3}" && /usr/bin/${xslt_binary_test_cmd3};
    echo "test built binary #1: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd1}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd1};
    echo "test built binary #2: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd2}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd2};
    echo "test built binary #3: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd3}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd3};
  fi;
}

function task_lib_xslt() {

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
