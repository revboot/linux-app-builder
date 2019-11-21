#!/bin/bash
#
# Task: Library: xml2
#

# declare routine package:uninstall
function task_lib_xml2_package_uninstall() {
  # uninstall binary packages
  if [ "$xml2_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $xml2_package_pkgs_bin;
  # uninstall development packages
  elif [ "$xml2_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $xml2_package_pkgs_dev;
  # uninstall both packages
  elif [ "$xml2_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $xml2_package_pkgs_bin $xml2_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:xml2:package:uninstall";
  fi;
}

# declare routine package:install
function task_lib_xml2_package_install() {
  # install binary packages
  if [ "$xml2_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $xml2_package_pkgs_bin;
  # install development packages
  elif [ "$xml2_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $xml2_package_pkgs_dev;
  # install both packages
  elif [ "$xml2_package_pkgs" == "both" ]; then
    sudo apt-get install -y $xml2_package_pkgs_bin $xml2_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:xml2:package:install";
  fi;
  # whereis library
  echo "whereis package library: $(whereis libxml2.so)";
}

# declare routine package:test
function task_lib_xml2_package_test() {
  # ldconfig tests
  xml2_ldconfig_test_file="libxml2.so";
  if [ -f "${global_package_path_usr_lib}/${xml2_ldconfig_test_file}" ] || [ -f "${global_package_path_usr_lib64}/${xml2_ldconfig_test_file}" ]; then
    # check ldconfig paths
    xml2_ldconfig_test_cmd1="ldconfig -p | grep ${global_package_path_usr_lib} | grep ${xml2_ldconfig_test_file}";
    echo "find package libraries #1: sudo bash -c \"${xml2_ldconfig_test_cmd1}\"";
    sudo bash -c "${xml2_ldconfig_test_cmd1}";
    # check ldconfig versions
    xml2_ldconfig_test_cmd2="ldconfig -v | grep ${xml2_ldconfig_test_file}";
    echo "find package libraries #2: sudo bash -c \"${xml2_ldconfig_test_cmd2}\"";
    sudo bash -c "${xml2_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:xml2:package:test";
  fi;
  # binary tests
  xml2_binary_test_cmd="${global_package_path_usr_bin}/xml2-config";
  if [ -f "$xml2_binary_test_cmd" ]; then
    # test binary
    xml2_binary_test_cmd="${xml2_binary_test_cmd} --libs --cflags --modules --version";
    echo "test package binary: ${xml2_binary_test_cmd}";
    $xml2_binary_test_cmd;
  else
    notify "errorRoutine" "lib:xml2:package:test";
  fi;
}

# declare routine source:cleanup
function task_lib_xml2_source_cleanup() {
  # remove source files
  if [ -d "$xml2_source_path" ]; then
    sudo rm -Rf "${xml2_source_path}"*;
  else
    notify "warnRoutine" "lib:xml2:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$xml2_source_tar" ]; then
    sudo rm -f "${xml2_source_tar}"*;
  else
    notify "warnRoutine" "lib:xml2:source:cleanup";
  fi;
}

# declare routine source:download
function task_lib_xml2_source_download() {
  if [ ! -d "$xml2_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$xml2_source_tar" ]; then
      sudo bash -c "cd \"${global_source_path_usr_src}\" && wget \"${xml2_source_url}\" -O \"${xml2_source_tar}\" && tar -xzf \"${xml2_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_path_usr_src}\" && tar -xzf \"${xml2_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "lib:xml2:source:download";
  fi;
}

# declare routine source:make
function task_lib_xml2_source_make() {
  if [ -d "$xml2_source_path" ]; then
    # command - add configuration tool
    xml2_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$xml2_source_arg_arch" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --target=${xml2_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$xml2_source_arg_prefix_usr" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --prefix=${xml2_source_arg_prefix_usr}";
    fi;

    # command - add libraries: zlib
    if [ "$xml2_source_arg_libraries_zlib" == "package" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-zlib";
    elif [ "$xml2_source_arg_libraries_zlib" == "source" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-zlib=${zlib_source_path}";
    fi;

    # command - add libraries: lzma
    if [ "$xml2_source_arg_libraries_lzma" == "package" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-lzma";
    elif [ "$xml2_source_arg_libraries_lzma" == "source" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-lzma=${lzma_source_path}";
    fi;

    # command - add libraries: readline
    if [ "$xml2_source_arg_libraries_readline" == "package" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-readline";
    elif [ "$xml2_source_arg_libraries_readline" == "source" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-readline=${readline_source_path}";
    fi;

    # command - add libraries: iconv
    if [ "$xml2_source_arg_libraries_iconv" == "package" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-iconv";
    elif [ "$xml2_source_arg_libraries_iconv" == "source" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-iconv=${iconv_source_path}";
    fi;

    # command - add libraries: python
    if [ "$xml2_source_arg_libraries_python" == "package" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-python";
    elif [ "$xml2_source_arg_libraries_python" == "source" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-python=${python_source_path}";
    fi;

    # command - add options
    if [ -n "$xml2_source_arg_options" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} ${xml2_source_arg_options}";
    fi;

    # command - add main: threads
    if [ "$xml2_source_arg_main_threads" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-threads";
    fi;

    # command - add main: thread alloc
    if [ "$xml2_source_arg_main_threadalloc" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-thread-alloc";
    fi;

    # command - add main: ipv6
    if [ "$xml2_source_arg_main_ipv6" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --enable-ipv6";
    fi;

    # command - add main: regular expressions
    if [ "$xml2_source_arg_main_regexps" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-regexps";
    fi;

    # command - add main: dso
    if [ "$xml2_source_arg_main_dso" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-modules";
    fi;

    # command - add encoding: iso8859x
    if [ "$xml2_source_arg_encoding_iso8859x" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-iso8859x";
    fi;

    # command - add encoding: unicode
    if [ "$xml2_source_arg_encoding_unicode" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-icu";
    fi;

    # command - add xml: canonicalization
    if [ "$xml2_source_arg_xml_canonical" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-c14n";
    fi;

    # command - add xml: catalog
    if [ "$xml2_source_arg_xml_catalog" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-catalog";
    fi;

    # command - add xml: schemas
    if [ "$xml2_source_arg_xml_schemas" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-schemas";
    fi;

    # command - add xml: schematron
    if [ "$xml2_source_arg_xml_schematron" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-schematron";
    fi;

    # command - add sgml: docbook
    if [ "$xml2_source_arg_sgml_docbook" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-docbook";
    fi;

    # command - add sgml: html
    if [ "$xml2_source_arg_sgml_html" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-html";
    fi;

    # command - add sgml: tree dom
    if [ "$xml2_source_arg_sgml_treedom" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-tree";
    fi;

    # command - add parser: pattern
    if [ "$xml2_source_arg_parser_pattern" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-pattern";
    fi;

    # command - add parser: push
    if [ "$xml2_source_arg_parser_push" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-push";
    fi;

    # command - add parser: reader
    if [ "$xml2_source_arg_parser_reader" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-reader";
    fi;

    # command - add parser: sax 1
    if [ "$xml2_source_arg_parser_sax1" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-sax1";
    fi;

    # command - add api: legacy
    if [ "$xml2_source_arg_api_legacy" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-legacy";
    fi;

    # command - add api: output serial
    if [ "$xml2_source_arg_api_outputserial" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-output";
    fi;

    # command - add api: valid dtd
    if [ "$xml2_source_arg_api_validdtd" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-valid";
    fi;

    # command - add api: writer
    if [ "$xml2_source_arg_api_writer" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-writer";
    fi;

    # command - add api: xinclude
    if [ "$xml2_source_arg_api_xinclude" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-xinclude";
    fi;

    # command - add api: xpath
    if [ "$xml2_source_arg_api_xpath" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-xpath";
    fi;

    # command - add api: pointer
    if [ "$xml2_source_arg_api_xpointer" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-xptr";
    fi;

    # command - add proto: ftp
    if [ "$xml2_source_arg_proto_ftp" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-ftp";
    fi;

    # command - add proto: http
    if [ "$xml2_source_arg_proto_http" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-http";
    fi;

    # command - add tool: history
    if [ "$xml2_source_arg_tool_history" == "yes" ]; then
      xml2_source_cmd_full="${xml2_source_cmd_full} --with-history";
    fi;

    # clean, configure (workaround) and make
    sudo bash -c "cd \"${xml2_source_path}\" && make clean";
    echo "configure arguments: ${xml2_source_cmd_full}";
    sudo bash -c "cd \"${xml2_source_path}\" && libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf && eval ${xml2_source_cmd_full} && make";
  else
    notify "errorRoutine" "lib:xml2:source:make";
  fi;
}

# declare routine source:uninstall
function task_lib_xml2_source_uninstall() {
  if [ -f "${global_source_path_usr_lib}/libxml2.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${xml2_source_path}\" && make uninstall";
  else
    notify "errorRoutine" "lib:xml2:source:uninstall";
  fi;
}

# declare routine source:install
function task_lib_xml2_source_install() {
  if [ -f "$xml2_source_path/.libs/libxml2.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${xml2_source_path}\" && make install";
    # whereis library
    echo "whereis source library: ${global_source_path_usr_lib}/libxml2.so";
  else
    notify "errorRoutine" "lib:xml2:source:install";
  fi;
}

# declare routine source:test
function task_lib_xml2_source_test() {
  # ldconfig tests
  xml2_ldconfig_test_file="libxml2.so";
  if [ -f "${global_source_path_usr_lib}/${xml2_ldconfig_test_file}" ]; then
    # check ldconfig paths
    xml2_ldconfig_test_cmd1="ldconfig -p | grep ${global_source_path_usr_lib} | grep ${xml2_ldconfig_test_file}";
    echo "find source libraries #1: sudo bash -c \"${xml2_ldconfig_test_cmd1}\"";
    sudo bash -c "${xml2_ldconfig_test_cmd1}";
    # check ldconfig versions
    xml2_ldconfig_test_cmd2="ldconfig -v | grep ${xml2_ldconfig_test_file}";
    echo "find source libraries #2: sudo bash -c \"${xml2_ldconfig_test_cmd2}\"";
    sudo bash -c "${xml2_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:xml2:source:test";
  fi;
  # binary tests
  xml2_binary_test_cmd="${global_source_path_usr_bin}/xml2-config";
  if [ -f "$xml2_binary_test_cmd" ]; then
    # test binary
    xml2_binary_test_cmd="${xml2_binary_test_cmd} --libs --cflags --modules --version";
    echo "test source binary: ${xml2_binary_test_cmd}";
    $xml2_binary_test_cmd;
  else
    notify "errorRoutine" "lib:xml2:source:test";
  fi;
}

# declare subtask package
function task_lib_xml2_package() {
  # run routine package:uninstall
  if ([ "$xml2_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:xml2:package:uninstall";
    task_lib_xml2_package_uninstall;
    notify "stopRoutine" "lib:xml2:package:uninstall";
  else
    notify "skipRoutine" "lib:xml2:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$xml2_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:xml2:package:install";
    task_lib_xml2_package_install;
    notify "stopRoutine" "lib:xml2:package:install";
  else
    notify "skipRoutine" "lib:xml2:package:install";
  fi;

  # run routine package:test
  if ([ "$xml2_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:xml2:package:test";
    task_lib_xml2_package_test;
    notify "stopRoutine" "lib:xml2:package:test";
  else
    notify "skipRoutine" "lib:xml2:package:test";
  fi;
}

# declare subtask source
function task_lib_xml2_source() {
  # run routine source:cleanup
  if ([ "$xml2_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:xml2:source:cleanup";
    task_lib_xml2_source_cleanup;
    notify "stopRoutine" "lib:xml2:source:cleanup";
  else
    notify "skipRoutine" "lib:xml2:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$xml2_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "lib:xml2:source:download";
    task_lib_xml2_source_download;
    notify "stopRoutine" "lib:xml2:source:download";
  else
    notify "skipRoutine" "lib:xml2:source:download";
  fi;

  # run routine source:make
  if ([ "$xml2_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "lib:xml2:source:make";
    task_lib_xml2_source_make;
    notify "stopRoutine" "lib:xml2:source:make";
  else
    notify "skipRoutine" "lib:xml2:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$xml2_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:xml2:source:uninstall";
    task_lib_xml2_source_uninstall;
    notify "stopRoutine" "lib:xml2:source:uninstall";
  else
    notify "skipRoutine" "lib:xml2:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$xml2_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:xml2:source:install";
    task_lib_xml2_source_install;
    notify "stopRoutine" "lib:xml2:source:install";
  else
    notify "skipRoutine" "lib:xml2:source:install";
  fi;

  # run routine source:test
  if ([ "$xml2_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:xml2:source:test";
    task_lib_xml2_source_test;
    notify "stopRoutine" "lib:xml2:source:test";
  else
    notify "skipRoutine" "lib:xml2:source:test";
  fi;
}

# declare task
function task_lib_xml2() {
  # run subtask package
  if ([ "$xml2_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:xml2:package";
    task_lib_xml2_package;
    notify "stopSubTask" "lib:xml2:package";
  else
    notify "skipSubTask" "lib:xml2:package";
  fi;

  # run subtask source
  if ([ "$xml2_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:xml2:source";
    task_lib_xml2_source;
    notify "stopSubTask" "lib:xml2:source";
  else
    notify "skipSubTask" "lib:xml2:source";
  fi;
}
