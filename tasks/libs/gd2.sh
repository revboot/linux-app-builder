#!/bin/bash
#
# Task: Library: gd2
#

# task:lib:gd2:apt:install
function task_lib_gd2_apt_install() {
  # install packages
  sudo apt-get install -y $gd2_apt_pkgs;
  # whereis library
  echo "whereis system library: $(whereis libgd.so)";
}

# task:lib:gd2:apt:test
function task_lib_gd2_apt_test() {
  # ldconfig tests
  gd2_ldconfig_test_cmd="/usr/lib/x86_64-linux-gnu/libgd.so";
  if [ -f "$gd2_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    gd2_ldconfig_test_cmd1="ldconfig -p | grep ${gd2_ldconfig_test_cmd}";
    echo "find system libraries #1: sudo bash -c \"${gd2_ldconfig_test_cmd1}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd1}";
    # check ldconfig versions
    gd2_ldconfig_test_cmd2="ldconfig -v | grep libgd.so";
    echo "find system libraries #2: sudo bash -c \"${gd2_ldconfig_test_cmd2}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd2}";
  fi;
  # binary tests
  gd2_binary_test_cmd="/usr/bin/gdlib-config";
  if [ -f "$gd2_binary_test_cmd" ]; then
    # test binary
    gd2_binary_test_cmd="${gd2_binary_test_cmd} --version --libs --cflags --ldflags --features";
    echo "test system binary: ${gd2_binary_test_cmd}";
    $gd2_binary_test_cmd;
  fi;
}

# task:lib:gd2:build:cleanup
function task_lib_gd2_build_cleanup() {
  # remove source files
  if [ -d "$gd2_build_path" ]; then
    sudo rm -Rf "${gd2_build_path}"*;
  fi;
  # remove source tar
  if [ -f "$gd2_build_tar" ]; then
    sudo rm -f "${gd2_build_tar}"*;
  fi;
}

# task:lib:gd2:build:download
function task_lib_gd2_build_download() {
  if [ ! -d "$gd2_build_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$gd2_build_tar" ]; then
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && wget \"${gd2_build_url}\" && tar xzf \"${gd2_build_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_build_usrprefix}/src\" && tar xzf \"${gd2_build_tar}\"";
    fi;
  fi;
}

# task:lib:gd2:build:make
function task_lib_gd2_build_make() {
  if [ -d "$gd2_build_path" ]; then
    # command - add configuration tool
    gd2_build_cmd_full="./configure";

    # command - add arch
    if [ -n "$gd2_build_arg_arch" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --target=${gd2_build_arg_arch}";
    fi;

    # command - add prefix (usr)
    if [ -n "$gd2_build_arg_usrprefix" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --prefix=${gd2_build_arg_usrprefix}";
    fi;

    ## command - add libraries
    #if [ -n "$gd2_build_arg_libraries" ]; then
    #  gd2_build_cmd_full="${gd2_build_cmd_full} --libraries=${gd2_build_arg_libraries}";
    #fi;

    # command - add libraries: zlib
    if [ "$gd2_build_arg_libraries_zlib" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-zlib";
    elif [ "$gd2_build_arg_libraries_zlib" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-zlib=${zlib_build_path}";
    fi;

    # command - add libraries: png
    if [ "$gd2_build_arg_libraries_png" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-png";
    elif [ "$gd2_build_arg_libraries_png" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-png=${png_build_path}";
    fi;

    # command - add libraries: jpeg
    if [ "$gd2_build_arg_libraries_jpeg" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-jpeg";
    elif [ "$gd2_build_arg_libraries_jpeg" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-jpeg=${jpeg_build_path}";
    fi;

    # command - add libraries: webp
    if [ "$gd2_build_arg_libraries_webp" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-webp";
    elif [ "$gd2_build_arg_libraries_webp" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-webp=${webp_build_path}";
    fi;

    # command - add libraries: tiff
    if [ "$gd2_build_arg_libraries_tiff" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-tiff";
    elif [ "$gd2_build_arg_libraries_tiff" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-tiff=${tiff_build_path}";
    fi;

    # command - add libraries: xpm
    if [ "$gd2_build_arg_libraries_xpm" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-xpm";
    elif [ "$gd2_build_arg_libraries_xpm" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-xpm=${xpm_build_path}";
    fi;

    # command - add libraries: liq
    if [ "$gd2_build_arg_libraries_liq" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-liq";
    elif [ "$gd2_build_arg_libraries_liq" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-liq=${liq_build_path}";
    fi;

    # command - add libraries: freetype
    if [ "$gd2_build_arg_libraries_freetype" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-freetype";
    elif [ "$gd2_build_arg_libraries_freetype" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-freetype=${freetype_build_path}";
    fi;

    # command - add libraries: fontconfig
    if [ "$gd2_build_arg_libraries_fontconfig" == "system" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-fontconfig";
    elif [ "$gd2_build_arg_libraries_fontconfig" == "custom" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} --with-fontconfig=${fontconfig_build_path}";
    fi;

    # command - add options
    if [ -n "$gd2_build_arg_options" ]; then
      gd2_build_cmd_full="${gd2_build_cmd_full} ${gd2_build_arg_options}";
    fi;

    # clean, configure and make
    cd $gd2_build_path;
    sudo make clean;
    echo "${gd2_build_cmd_full}";
    sudo $gd2_build_cmd_full && \
    sudo make;
  fi;
}

# task:lib:gd2:build:install
function task_lib_gd2_build_install() {
  if [ -f "$gd2_build_path/src/.libs/libgd.so" ]; then
    # uninstall and install
    cd $gd2_build_path;
    sudo make uninstall;
    sudo make install;
    # whereis library
    echo "whereis built library: ${global_build_usrprefix}/lib/libgd.so";
  fi;
}

# task:lib:gd2:build:test
function task_lib_gd2_build_test() {
  # ldconfig tests
  gd2_ldconfig_test_cmd="${global_build_usrprefix}/lib/libgd.so";
  if [ -f "$gd2_ldconfig_test_cmd" ]; then
    # check ldconfig paths
    gd2_ldconfig_test_cmd1="ldconfig -p | grep ${gd2_ldconfig_test_cmd}";
    echo "find built libraries #1: sudo bash -c \"${gd2_ldconfig_test_cmd1}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd1}";
    # check ldconfig versions
    gd2_ldconfig_test_cmd2="ldconfig -v | grep libgd.so";
    echo "find built libraries #2: sudo bash -c \"${gd2_ldconfig_test_cmd2}\"";
    sudo bash -c "${gd2_ldconfig_test_cmd2}";
  fi;
  # binary tests
  gd2_binary_test_cmd="${global_build_usrprefix}/bin/gdlib-config";
  if [ -f "$gd2_binary_test_cmd" ]; then
    # test binary
    gd2_binary_test_cmd="${gd2_binary_test_cmd} --version --libs --cflags --ldflags --features";
    echo "test built binary: ${gd2_binary_test_cmd}";
    $gd2_binary_test_cmd;
  fi;
}

function task_lib_gd2() {

  # apt subtask
  if [ "$gd2_apt_flag" == "yes" ]; then
    notify "startSubTask" "lib:gd2:apt";

    # run task:lib:gd2:apt:install
    if [ "$gd2_apt_install" == "yes" ]; then
      notify "startRoutine" "lib:gd2:apt:install";
      task_lib_gd2_apt_install;
      notify "stopRoutine" "lib:gd2:apt:install";
    else
      notify "skipRoutine" "lib:gd2:apt:install";
    fi;

    # run task:lib:gd2:apt:test
    if [ "$gd2_apt_test" == "yes" ]; then
      notify "startRoutine" "lib:gd2:apt:test";
      task_lib_gd2_apt_test;
      notify "stopRoutine" "lib:gd2:apt:test";
    else
      notify "skipRoutine" "lib:gd2:apt:test";
    fi;

    notify "stopSubTask" "lib:gd2:apt";
  else
    notify "skipSubTask" "lib:gd2:apt";
  fi;

  # build subtask
  if [ "$gd2_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:gd2:build";

    # run task:lib:gd2:build:cleanup
    if [ "$gd2_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:gd2:build:cleanup";
      task_lib_gd2_build_cleanup;
      notify "stopRoutine" "lib:gd2:build:cleanup";
    else
      notify "skipRoutine" "lib:gd2:build:cleanup";
    fi;

    # run task:lib:gd2:build:download
    if [ ! -d "$gd2_build_path" ]; then
      notify "startRoutine" "lib:gd2:build:download";
      task_lib_gd2_build_download;
      notify "stopRoutine" "lib:gd2:build:download";
    else
      notify "skipRoutine" "lib:gd2:build:download";
    fi;

    # run task:lib:gd2:build:make
    if [ "$gd2_build_make" == "yes" ]; then
      notify "startRoutine" "lib:gd2:build:make";
      task_lib_gd2_build_make;
      notify "stopRoutine" "lib:gd2:build:make";
    else
      notify "skipRoutine" "lib:gd2:build:make";
    fi;

    # run task:lib:gd2:build:install
    if [ "$gd2_build_install" == "yes" ]; then
      notify "startRoutine" "lib:gd2:build:install";
      task_lib_gd2_build_install;
      notify "stopRoutine" "lib:gd2:build:install";
    else
      notify "skipRoutine" "lib:gd2:build:install";
    fi;

    # run task:lib:gd2:build:test
    if [ "$gd2_build_test" == "yes" ]; then
      notify "startRoutine" "lib:gd2:build:test";
      task_lib_gd2_build_test;
      notify "stopRoutine" "lib:gd2:build:test";
    else
      notify "skipRoutine" "lib:gd2:build:test";
    fi;

    notify "stopSubTask" "lib:gd2:build";
  else
    notify "skipSubTask" "lib:gd2:build";
  fi;

}
