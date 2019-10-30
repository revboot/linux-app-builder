#!/bin/bash
#
# Task: Library: xslt
#

function task_lib_xslt() {

  # build subtask
  if [ "$xslt_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:xslt:build";

    # cleanup code and tar
    if [ "$xslt_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:xslt:build:cleanup";
      sudo rm -Rf ${xslt_build_path}*;
      notify "stopRoutine" "lib:xslt:build:cleanup";
    else
      notify "skipRoutine" "lib:xslt:build:cleanup";
    fi;

    # extract code from tar
    if [ ! -d "$xslt_build_path" ]; then
      notify "startRoutine" "lib:xslt:build:download";
      if [ ! -f "${xslt_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src && wget ${xslt_build_url} && tar xzf ${xslt_build_tar}";
      else
        sudo bash -c "cd ${global_build_usrprefix}/src && tar xzf ${xslt_build_tar}";
      fi;
      notify "stopRoutine" "lib:xslt:build:download";
    else
      notify "skipRoutine" "lib:xslt:build:download";
    fi;

    cd $xslt_build_path;

    # compile binaries
    if [ "$xslt_build_make" == "yes" ]; then
      notify "startRoutine" "lib:xslt:build:make";
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

      # clean, configure and make
      sudo make clean;
      echo "${xslt_build_cmd_full}";
      sudo wget -P $xslt_build_path/doc "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd";
      sudo wget -P $xslt_build_path/doc "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl";
      sudo bash -c "libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf" && sudo $xslt_build_cmd_full && sudo make;
      notify "stopRoutine" "lib:xslt:build:make";
    else
      notify "skipRoutine" "lib:xslt:build:make";
    fi;

    # install binaries
    if [ "$xslt_build_install" == "yes" ] && [ -f "${xslt_build_path}/libxslt/.libs/libxslt.so" ]; then
      notify "startRoutine" "lib:xslt:build:install";
      sudo make uninstall; sudo make install;
      sudo cp "${xslt_build_path}/xsltproc/.libs/xsltproc" "${global_build_usrprefix}/bin/xsltproc";
      sudo cp "${xslt_build_path}/xslt-config" "${global_build_usrprefix}/bin/xslt-config";
      sudo chmod +x "${global_build_usrprefix}/bin/xslt-config";
      echo "system library: $(whereis libxslt.so)";
      echo "built library: ${global_build_usrprefix}/lib/libxslt.so";
      xslt_ldconfig_test_cmd="ldconfig -p | grep libxslt.so; ldconfig -v | grep libxslt.so";
      echo "list libraries: ${xslt_ldconfig_test_cmd}"; ${xslt_ldconfig_test_cmd};
      notify "stopRoutine" "lib:xslt:build:install";
    else
      notify "skipRoutine" "lib:xslt:build:install";
    fi;

    # test binaries
    if [ "$xslt_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/xslt-config" ]; then
      notify "startRoutine" "lib:xslt:build:test";
      xslt_binary_test_cmd1="xslt-config --libs --cflags";
      xslt_binary_test_cmd2="xslt-config --plugins";
      xslt_binary_test_cmd3="xslt-config --version";
      echo "test system binary #1: /usr/bin/${xslt_binary_test_cmd1}" && /usr/bin/${xslt_binary_test_cmd1};
      echo "test system binary #2: /usr/bin/${xslt_binary_test_cmd2}" && /usr/bin/${xslt_binary_test_cmd2};
      echo "test system binary #3: /usr/bin/${xslt_binary_test_cmd3}" && /usr/bin/${xslt_binary_test_cmd3};
      echo "test built binary #1: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd1}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd1};
      echo "test built binary #2: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd2}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd2};
      echo "test built binary #3: ${global_build_usrprefix}/bin/${xslt_binary_test_cmd3}" && ${global_build_usrprefix}/bin/${xslt_binary_test_cmd3};
      notify "stopRoutine" "lib:xslt:build:test";
    else
      notify "skipRoutine" "lib:xslt:build:test";
    fi;

    notify "stopSubTask" "lib:xslt:build";
  else
    notify "skipSubTask" "lib:xslt:build";
  fi;

}
