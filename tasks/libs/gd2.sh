#!/bin/bash
#
# Task: Library: gd2
#

# declare routine package:uninstall
function task_lib_gd2_package_uninstall() {
  # uninstall binary packages
  if [ "$gd2_package_pkgs" == "bin" ]; then
    sudo apt-get remove --purge $gd2_package_pkgs_bin;
  # uninstall development packages
  elif [ "$gd2_package_pkgs" == "dev" ]; then
    sudo apt-get remove --purge $gd2_package_pkgs_dev;
  # uninstall both packages
  elif [ "$gd2_package_pkgs" == "both" ]; then
    sudo apt-get remove --purge $gd2_package_pkgs_bin $gd2_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:gd2:package:uninstall";
  fi;
}

# declare routine package:install
function task_lib_gd2_package_install() {
  # install binary packages
  if [ "$gd2_package_pkgs" == "bin" ]; then
    sudo apt-get install -y $gd2_package_pkgs_bin;
  # install development packages
  elif [ "$gd2_package_pkgs" == "dev" ]; then
    sudo apt-get install -y $gd2_package_pkgs_dev;
  # install both packages
  elif [ "$gd2_package_pkgs" == "both" ]; then
    sudo apt-get install -y $gd2_package_pkgs_bin $gd2_package_pkgs_dev;
  else
    notify "errorRoutine" "lib:gd2:package:install";
  fi;
  # whereis library
  echo "whereis package library: $(whereis libgd.so)";
}

# declare routine package:test
function task_lib_gd2_package_test() {
  # ldconfig tests
  gd2_ldconfig_test_cmd="/usr/lib/x86_64-linux-gnu/libgd.so";
  if [ -f "$gd2_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    gd2_ldconfig_test_cmd1="ldconfig -p | grep ${gd2_ldconfig_test_cmd}";
    echo "find package libraries #1: sudo bash -c \"${gd2_ldconfig_test_cmd1}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd1}";
    # check ldconfig versions
    gd2_ldconfig_test_cmd2="ldconfig -v | grep libgd.so";
    echo "find package libraries #2: sudo bash -c \"${gd2_ldconfig_test_cmd2}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:gd2:package:test";
  fi;
  # binary tests
  gd2_binary_test_cmd="/usr/bin/gdlib-config";
  if [ -f "$gd2_binary_test_cmd" ]; then
    # test binary
    gd2_binary_test_cmd="${gd2_binary_test_cmd} --version --libs --cflags --ldflags --features";
    echo "test package binary: ${gd2_binary_test_cmd}";
    $gd2_binary_test_cmd;
  else
    notify "errorRoutine" "lib:gd2:package:test";
  fi;
}

# declare routine source:cleanup
function task_lib_gd2_source_cleanup() {
  # remove source files
  if [ -d "$gd2_source_path" ]; then
    sudo rm -Rf "${gd2_source_path}"*;
  else
    notify "warnRoutine" "lib:gd2:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$gd2_source_tar" ]; then
    sudo rm -f "${gd2_source_tar}"*;
  else
    notify "warnRoutine" "lib:gd2:source:cleanup";
  fi;
}

# declare routine source:download
function task_lib_gd2_source_download() {
  if [ ! -d "$gd2_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$gd2_source_tar" ]; then
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && wget \"${gd2_source_url}\" -O \"${gd2_source_tar}\" && tar -xzf \"${gd2_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_usrprefix}/src\" && tar -xzf \"${gd2_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "lib:gd2:source:download";
  fi;
}

# declare routine source:make
function task_lib_gd2_source_make() {
  if [ -d "$gd2_source_path" ]; then
    # command - add configuration tool
    gd2_source_cmd_full="./configure";

    # command - add arch
    if [ -n "$gd2_source_arg_arch" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --target=${gd2_source_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$gd2_source_arg_usrprefix" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --prefix=${gd2_source_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$gd2_source_arg_libraries" ]; then
    #  gd2_source_cmd_full="${gd2_source_cmd_full} --libraries=${gd2_source_arg_libraries}";
    #fi;

    # command - add libraries: zlib
    if [ "$gd2_source_arg_libraries_zlib" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-zlib";
    elif [ "$gd2_source_arg_libraries_zlib" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-zlib=${zlib_source_path}";
    fi;

    # command - add libraries: png
    if [ "$gd2_source_arg_libraries_png" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-png";
    elif [ "$gd2_source_arg_libraries_png" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-png=${png_source_path}";
    fi;

    # command - add libraries: jpeg
    if [ "$gd2_source_arg_libraries_jpeg" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-jpeg";
    elif [ "$gd2_source_arg_libraries_jpeg" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-jpeg=${jpeg_source_path}";
    fi;

    # command - add libraries: webp
    if [ "$gd2_source_arg_libraries_webp" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-webp";
    elif [ "$gd2_source_arg_libraries_webp" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-webp=${webp_source_path}";
    fi;

    # command - add libraries: tiff
    if [ "$gd2_source_arg_libraries_tiff" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-tiff";
    elif [ "$gd2_source_arg_libraries_tiff" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-tiff=${tiff_source_path}";
    fi;

    # command - add libraries: xpm
    if [ "$gd2_source_arg_libraries_xpm" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-xpm";
    elif [ "$gd2_source_arg_libraries_xpm" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-xpm=${xpm_source_path}";
    fi;

    # command - add libraries: liq
    if [ "$gd2_source_arg_libraries_liq" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-liq";
    elif [ "$gd2_source_arg_libraries_liq" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-liq=${liq_source_path}";
    fi;

    # command - add libraries: freetype
    if [ "$gd2_source_arg_libraries_freetype" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-freetype";
    elif [ "$gd2_source_arg_libraries_freetype" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-freetype=${freetype_source_path}";
    fi;

    # command - add libraries: fontconfig
    if [ "$gd2_source_arg_libraries_fontconfig" == "package" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-fontconfig";
    elif [ "$gd2_source_arg_libraries_fontconfig" == "source" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} --with-fontconfig=${fontconfig_source_path}";
    fi;

    # command - add options
    if [ -n "$gd2_source_arg_options" ]; then
      gd2_source_cmd_full="${gd2_source_cmd_full} ${gd2_source_arg_options}";
    fi;

    # clean, configure and make
    sudo bash -c "cd \"${gd2_source_path}\" && make clean";
    echo "configure arguments: ${gd2_source_cmd_full}";
    sudo bash -c "cd \"${gd2_source_path}\" && eval ${gd2_source_cmd_full} && make";
  else
    notify "errorRoutine" "lib:gd2:source:make";
  fi;
}

# declare routine source:uninstall
function task_lib_gd2_source_uninstall() {
  if [ -f "${global_source_usrprefix}/lib/libgd.so" ]; then
    # uninstall binaries from source
    sudo bash -c "cd \"${gd2_source_path}\" && make uninstall";
  else
    notify "errorRoutine" "lib:gd2:source:uninstall";
  fi;
}

# declare routine source:install
function task_lib_gd2_source_install() {
  if [ -f "$gd2_source_path/src/.libs/libgd.so" ]; then
    # install binaries from source
    sudo bash -c "cd \"${gd2_source_path}\" && make install";
    # whereis library
    echo "whereis source library: ${global_source_usrprefix}/lib/libgd.so";
  else
    notify "errorRoutine" "lib:gd2:source:install";
  fi;
}

# declare routine source:test
function task_lib_gd2_source_test() {
  # ldconfig tests
  gd2_ldconfig_test_cmd="${global_source_usrprefix}/lib/libgd.so";
  if [ -f "$gd2_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    gd2_ldconfig_test_cmd1="ldconfig -p | grep ${gd2_ldconfig_test_cmd}";
    echo "find source libraries #1: sudo bash -c \"${gd2_ldconfig_test_cmd1}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd1}";
    # check ldconfig versions
    gd2_ldconfig_test_cmd2="ldconfig -v | grep libgd.so";
    echo "find source libraries #2: sudo bash -c \"${gd2_ldconfig_test_cmd2}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd2}";
  else
    notify "errorRoutine" "lib:gd2:source:test";
  fi;
  # binary tests
  gd2_binary_test_cmd="${global_source_usrprefix}/bin/gdlib-config";
  if [ -f "$gd2_binary_test_cmd" ]; then
    # test binary
    gd2_binary_test_cmd="${gd2_binary_test_cmd} --version --libs --cflags --ldflags --features";
    echo "test source binary: ${gd2_binary_test_cmd}";
    $gd2_binary_test_cmd;
  else
    notify "errorRoutine" "lib:gd2:source:test";
  fi;
}

# declare subtask package
function task_lib_gd2_package() {
  # run routine package:uninstall
  if ([ "$gd2_package_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:gd2:package:uninstall";
    task_lib_gd2_package_uninstall;
    notify "stopRoutine" "lib:gd2:package:uninstall";
  else
    notify "skipRoutine" "lib:gd2:package:uninstall";
  fi;

  # run routine package:install
  if ([ "$gd2_package_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:gd2:package:install";
    task_lib_gd2_package_install;
    notify "stopRoutine" "lib:gd2:package:install";
  else
    notify "skipRoutine" "lib:gd2:package:install";
  fi;

  # run routine package:test
  if ([ "$gd2_package_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:gd2:package:test";
    task_lib_gd2_package_test;
    notify "stopRoutine" "lib:gd2:package:test";
  else
    notify "skipRoutine" "lib:gd2:package:test";
  fi;
}

# declare subtask source
function task_lib_gd2_source() {
  # run routine source:cleanup
  if ([ "$gd2_source_cleanup" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "cleanup" ]; then
    notify "startRoutine" "lib:gd2:source:cleanup";
    task_lib_gd2_source_cleanup;
    notify "stopRoutine" "lib:gd2:source:cleanup";
  else
    notify "skipRoutine" "lib:gd2:source:cleanup";
  fi;

  # run routine source:download
  if ([ "$gd2_source_download" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "download" ]; then
    notify "startRoutine" "lib:gd2:source:download";
    task_lib_gd2_source_download;
    notify "stopRoutine" "lib:gd2:source:download";
  else
    notify "skipRoutine" "lib:gd2:source:download";
  fi;

  # run routine source:make
  if ([ "$gd2_source_make" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "make" ]; then
    notify "startRoutine" "lib:gd2:source:make";
    task_lib_gd2_source_make;
    notify "stopRoutine" "lib:gd2:source:make";
  else
    notify "skipRoutine" "lib:gd2:source:make";
  fi;

  # run routine source:uninstall
  if ([ "$gd2_source_uninstall" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "uninstall" ]; then
    notify "startRoutine" "lib:gd2:source:uninstall";
    task_lib_gd2_source_uninstall;
    notify "stopRoutine" "lib:gd2:source:uninstall";
  else
    notify "skipRoutine" "lib:gd2:source:uninstall";
  fi;

  # run routine source:install
  if ([ "$gd2_source_install" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "install" ]; then
    notify "startRoutine" "lib:gd2:source:install";
    task_lib_gd2_source_install;
    notify "stopRoutine" "lib:gd2:source:install";
  else
    notify "skipRoutine" "lib:gd2:source:install";
  fi;

  # run routine source:test
  if ([ "$gd2_source_test" == "yes" ] && [ "$args_routine" == "config" ]) || [ "$args_routine" == "all" ] || [ "$args_routine" == "test" ]; then
    notify "startRoutine" "lib:gd2:source:test";
    task_lib_gd2_source_test;
    notify "stopRoutine" "lib:gd2:source:test";
  else
    notify "skipRoutine" "lib:gd2:source:test";
  fi;
}

# declare task
function task_lib_gd2() {
  # run subtask package
  if ([ "$gd2_package_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "package" ]; then
    notify "startSubTask" "lib:gd2:package";
    task_lib_gd2_package;
    notify "stopSubTask" "lib:gd2:package";
  else
    notify "skipSubTask" "lib:gd2:package";
  fi;

  # run subtask source
  if ([ "$gd2_source_flag" == "yes" ] && [ "$args_subtask" == "config" ]) || [ "$args_subtask" == "all" ] || [ "$args_subtask" == "source" ]; then
    notify "startSubTask" "lib:gd2:source";
    task_lib_gd2_source;
    notify "stopSubTask" "lib:gd2:source";
  else
    notify "skipSubTask" "lib:gd2:source";
  fi;
}
