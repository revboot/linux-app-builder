#!/bin/bash
#
# Task: Library: xml2
#

# task:lib:xml2:build:cleanup
function task_lib_xml2_build_cleanup() {
  # remove source files
  if [ -d "$xml2_build_path" ]; then
    sudo rm -Rf "${xml2_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$xml2_build_tar" ]; then
    sudo rm -f "${xml2_build_tar}"*;
  fi;
}

# task:lib:xml2:build:download
function task_lib_xml2_build_download() {
  if [ ! -d "$xml2_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$xml2_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${xml2_build_url}\" && tar xzf \"${xml2_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${xml2_build_tar}\"";
    fi;
  fi;
}

# task:lib:xml2:build:make
function task_lib_xml2_build_make() {
  if [ -d "$xml2_build_path" ]; then
    # command - add configuration tool
    xml2_build_cmd_full="./configure";

    # command - add arch
    if [ -n "$xml2_build_arg_arch" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --target=${xml2_build_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$xml2_build_arg_usrprefix" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --prefix=${xml2_build_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$xml2_build_arg_libraries" ]; then
    #  xml2_build_cmd_full="${xml2_build_cmd_full} --libraries=${xml2_build_arg_libraries}";
    #fi;

    # command - add libraries: zlib
    if [ "$xml2_build_arg_libraries_zlib" == "system" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-zlib";
    elif [ "$xml2_build_arg_libraries_zlib" == "custom" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-zlib=${zlib_build_path}";
    fi;

    # command - add libraries: lzma
    if [ "$xml2_build_arg_libraries_lzma" == "system" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-lzma";
    elif [ "$xml2_build_arg_libraries_lzma" == "custom" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-lzma=${lzma_build_path}";
    fi;

    # command - add libraries: readline
    if [ "$xml2_build_arg_libraries_readline" == "system" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-readline";
    elif [ "$xml2_build_arg_libraries_readline" == "custom" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-readline=${readline_build_path}";
    fi;

    # command - add libraries: iconv
    if [ "$xml2_build_arg_libraries_iconv" == "system" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-iconv";
    elif [ "$xml2_build_arg_libraries_iconv" == "custom" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-iconv=${iconv_build_path}";
    fi;

    # command - add libraries: python
    if [ "$xml2_build_arg_libraries_python" == "system" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-python";
    elif [ "$xml2_build_arg_libraries_python" == "custom" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-python=${python_build_path}";
    fi;

    # command - add options
    if [ -n "$xml2_build_arg_options" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} ${xml2_build_arg_options}";
    fi;

    # command - add main: threads
    if [ "$xml2_build_arg_main_threads" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-threads";
    fi;

    # command - add main: thread alloc
    if [ "$xml2_build_arg_main_threadalloc" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-thread-alloc";
    fi;

    # command - add main: ipv6
    if [ "$xml2_build_arg_main_ipv6" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --enable-ipv6";
    fi;

    # command - add main: regular expressions
    if [ "$xml2_build_arg_main_regexps" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-regexps";
    fi;

    # command - add main: dso
    if [ "$xml2_build_arg_main_dso" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-modules";
    fi;

    # command - add encoding: iso8859x
    if [ "$xml2_build_arg_encoding_iso8859x" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-iso8859x";
    fi;

    # command - add encoding: unicode
    if [ "$xml2_build_arg_encoding_unicode" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-icu";
    fi;

    # command - add xml: canonicalization
    if [ "$xml2_build_arg_xml_canonical" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-c14n";
    fi;

    # command - add xml: catalog
    if [ "$xml2_build_arg_xml_catalog" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-catalog";
    fi;

    # command - add xml: schemas
    if [ "$xml2_build_arg_xml_schemas" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-schemas";
    fi;

    # command - add xml: schematron
    if [ "$xml2_build_arg_xml_schematron" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-schematron";
    fi;

    # command - add sgml: docbook
    if [ "$xml2_build_arg_sgml_docbook" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-docbook";
    fi;

    # command - add sgml: html
    if [ "$xml2_build_arg_sgml_html" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-html";
    fi;

    # command - add sgml: tree dom
    if [ "$xml2_build_arg_sgml_treedom" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-tree";
    fi;

    # command - add parser: pattern
    if [ "$xml2_build_arg_parser_pattern" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-pattern";
    fi;

    # command - add parser: push
    if [ "$xml2_build_arg_parser_push" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-push";
    fi;

    # command - add parser: reader
    if [ "$xml2_build_arg_parser_reader" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-reader";
    fi;

    # command - add parser: sax 1
    if [ "$xml2_build_arg_parser_sax1" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-sax1";
    fi;

    # command - add api: legacy
    if [ "$xml2_build_arg_api_legacy" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-legacy";
    fi;

    # command - add api: output serial
    if [ "$xml2_build_arg_api_outputserial" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-output";
    fi;

    # command - add api: valid dtd
    if [ "$xml2_build_arg_api_validdtd" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-valid";
    fi;

    # command - add api: writer
    if [ "$xml2_build_arg_api_writer" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-writer";
    fi;

    # command - add api: xinclude
    if [ "$xml2_build_arg_api_xinclude" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-xinclude";
    fi;

    # command - add api: xpath
    if [ "$xml2_build_arg_api_xpath" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-xpath";
    fi;

    # command - add api: pointer
    if [ "$xml2_build_arg_api_xpointer" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-xptr";
    fi;

    # command - add proto: ftp
    if [ "$xml2_build_arg_proto_ftp" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-ftp";
    fi;

    # command - add proto: http
    if [ "$xml2_build_arg_proto_http" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-http";
    fi;

    # command - add tool: history
    if [ "$xml2_build_arg_tool_history" == "yes" ]; then
      xml2_build_cmd_full="${xml2_build_cmd_full} --with-history";
    fi;

    # clean, configure (workaround) and make
    cd $xml2_build_path;
    sudo make clean;
    echo "${xml2_build_cmd_full}";
    sudo bash -c "libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf" && \
    sudo $xml2_build_cmd_full && \
    sudo make;
  fi;
}

# task:lib:xml2:build:install
function task_lib_xml2_build_install() {
  if [ -f "$xml2_build_path/.libs/libxml2.so" ]; then
    # uninstall and install
    cd $xml2_build_path;
    sudo make uninstall;
    sudo make install;
    # find binary
    echo "system library: $(whereis libxml2.so)";
    echo "built library: ${global_build_usrprefix}/lib/libxml2.so";
    # check ldconfig
    xml2_ldconfig_test_cmd="ldconfig -p | grep libxml2.so; ldconfig -v | grep libxml2.so";
    echo "list libraries: ${xml2_ldconfig_test_cmd}"; ${xml2_ldconfig_test_cmd};
  fi;
}

function task_lib_xml2() {

  # build subtask
  if [ "$xml2_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:xml2:build";

    # run task:lib:xml2:build:cleanup
    if [ "$xml2_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:xml2:build:cleanup";
      task_lib_xml2_build_cleanup;
      notify "stopRoutine" "lib:xml2:build:cleanup";
    else
      notify "skipRoutine" "lib:xml2:build:cleanup";
    fi;

    # run task:lib:xml2:build:download
    if [ ! -d "$xml2_build_path" ]; then
      notify "startRoutine" "lib:xml2:build:download";
      task_lib_xml2_build_download;
      notify "stopRoutine" "lib:xml2:build:download";
    else
      notify "skipRoutine" "lib:xml2:build:download";
    fi;

    # run task:lib:xml2:build:make
    if [ "$xml2_build_make" == "yes" ]; then
      notify "startRoutine" "lib:xml2:build:make";
      task_lib_xml2_build_make;
      notify "stopRoutine" "lib:xml2:build:make";
    else
      notify "skipRoutine" "lib:xml2:build:make";
    fi;

    # run task:lib:xml2:build:install
    if [ "$xml2_build_install" == "yes" ]; then
      notify "startRoutine" "lib:xml2:build:install";
      task_lib_xml2_build_install;
      notify "stopRoutine" "lib:xml2:build:install";
    else
      notify "skipRoutine" "lib:xml2:build:install";
    fi;

    # test binaries
    if [ "$xml2_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/xml2-config" ]; then
      notify "startRoutine" "lib:xml2:build:test";
      xml2_binary_test_cmd="xml2-config --libs --cflags --modules --version";
      echo "test system binary: /usr/bin/${xml2_binary_test_cmd}"; /usr/bin/${xml2_binary_test_cmd};
      echo "test built binary: ${global_build_usrprefix}/bin/${xml2_binary_test_cmd}"; ${global_build_usrprefix}/bin/${xml2_binary_test_cmd};
      notify "stopRoutine" "lib:xml2:build:test";
    else
      notify "skipRoutine" "lib:xml2:build:test";
    fi;

    notify "stopSubTask" "lib:xml2:build";
  else
    notify "skipSubTask" "lib:xml2:build";
  fi;

}
