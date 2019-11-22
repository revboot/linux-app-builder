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
  ldconfig_lookup="libgd.so";
  if [ -f "${global_package_path_usr_lib}/${ldconfig_lookup}" ] || [ -f "${global_package_path_usr_lib64}/${ldconfig_lookup}" ]; then
    # check ldconfig paths
    ldconfig_cmd1="ldconfig -p | grep ${global_package_path_usr_lib} | grep ${ldconfig_lookup}";
    echo "find package libraries #1: sudo bash -c \"${ldconfig_cmd1}\"";
    sudo bash -c "${ldconfig_cmd1}";
    # check ldconfig versions
    ldconfig_cmd2="ldconfig -v | grep ${ldconfig_lookup}";
    echo "find package libraries #2: sudo bash -c \"${ldconfig_cmd2}\"";
    sudo bash -c "${ldconfig_cmd2}";
  else
    notify "errorRoutine" "lib:gd2:package:test";
  fi;
  # libconfig tests
  libconfig_cmd="${global_package_path_usr_bin}/gdlib-config";
  if [ -f "$libconfig_cmd" ]; then
    # check libconfig info
    libconfig_cmd="${libconfig_cmd} --version --libs --cflags --ldflags --features";
    echo "check libconfig info: ${libconfig_cmd}";
    $libconfig_cmd;
  else
    notify "errorRoutine" "lib:gd2:package:test";
  fi;
}

# declare routine source:cleanup
function task_lib_gd2_source_cleanup() {
  # remove source files
  if [ -d "$gd2_source_path" ]; then
    sudo rm -Rf "${gd2_source_path}";
  else
    notify "warnRoutine" "lib:gd2:source:cleanup";
  fi;
  # remove source tar
  if [ -f "$gd2_source_tar" ]; then
    sudo rm -f "${gd2_source_tar}";
  else
    notify "warnRoutine" "lib:gd2:source:cleanup";
  fi;
}

# declare routine source:download
function task_lib_gd2_source_download() {
  if [ ! -d "$gd2_source_path" ]; then
    # download and extract source files from tar
    if [ ! -f "$gd2_source_tar" ]; then
      sudo bash -c "cd \"${global_source_path_usr_src}\" && wget \"${gd2_source_url}\" -O \"${gd2_source_tar}\" && tar -xzf \"${gd2_source_tar}\"";
    # extract source files from tar
    else
      sudo bash -c "cd \"${global_source_path_usr_src}\" && tar -xzf \"${gd2_source_tar}\"";
    fi;
  else
    notify "warnRoutine" "lib:gd2:source:download";
  fi;
}

# declare routine source:make
function task_lib_gd2_source_make() {
  if [ -d "$gd2_source_path" ]; then
    # config command - add configuration tool
    config_cmd="./configure";

    # config command - add arch
    if [ -n "$gd2_source_arg_arch" ]; then
      config_cmd="${config_cmd} --target=${gd2_source_arg_arch}";
    fi;

    # config command - add prefix (usr)
    if [ -n "$gd2_source_arg_prefix_usr" ]; then
      config_cmd="${config_cmd} --prefix=${gd2_source_arg_prefix_usr}";
    fi;

    # config command - add libraries: zlib
    if [ "$gd2_source_arg_libraries_zlib" == "package" ]; then
      config_cmd="${config_cmd} --with-zlib";
    elif [ "$gd2_source_arg_libraries_zlib" == "source" ]; then
      config_cmd="${config_cmd} --with-zlib=${zlib_source_path}";
    fi;

    # config command - add libraries: png
    if [ "$gd2_source_arg_libraries_png" == "package" ]; then
      config_cmd="${config_cmd} --with-png";
    elif [ "$gd2_source_arg_libraries_png" == "source" ]; then
      config_cmd="${config_cmd} --with-png=${png_source_path}";
    fi;

    # config command - add libraries: jpeg
    if [ "$gd2_source_arg_libraries_jpeg" == "package" ]; then
      config_cmd="${config_cmd} --with-jpeg";
    elif [ "$gd2_source_arg_libraries_jpeg" == "source" ]; then
      config_cmd="${config_cmd} --with-jpeg=${jpeg_source_path}";
    fi;

    # config command - add libraries: webp
    if [ "$gd2_source_arg_libraries_webp" == "package" ]; then
      config_cmd="${config_cmd} --with-webp";
    elif [ "$gd2_source_arg_libraries_webp" == "source" ]; then
      config_cmd="${config_cmd} --with-webp=${webp_source_path}";
    fi;

    # config command - add libraries: tiff
    if [ "$gd2_source_arg_libraries_tiff" == "package" ]; then
      config_cmd="${config_cmd} --with-tiff";
    elif [ "$gd2_source_arg_libraries_tiff" == "source" ]; then
      config_cmd="${config_cmd} --with-tiff=${tiff_source_path}";
    fi;

    # config command - add libraries: xpm
    if [ "$gd2_source_arg_libraries_xpm" == "package" ]; then
      config_cmd="${config_cmd} --with-xpm";
    elif [ "$gd2_source_arg_libraries_xpm" == "source" ]; then
      config_cmd="${config_cmd} --with-xpm=${xpm_source_path}";
    fi;

    # config command - add libraries: liq
    if [ "$gd2_source_arg_libraries_liq" == "package" ]; then
      config_cmd="${config_cmd} --with-liq";
    elif [ "$gd2_source_arg_libraries_liq" == "source" ]; then
      config_cmd="${config_cmd} --with-liq=${liq_source_path}";
    fi;

    # config command - add libraries: freetype
    if [ "$gd2_source_arg_libraries_freetype" == "package" ]; then
      config_cmd="${config_cmd} --with-freetype";
    elif [ "$gd2_source_arg_libraries_freetype" == "source" ]; then
      config_cmd="${config_cmd} --with-freetype=${freetype_source_path}";
    fi;

    # config command - add libraries: fontconfig
    if [ "$gd2_source_arg_libraries_fontconfig" == "package" ]; then
      config_cmd="${config_cmd} --with-fontconfig";
    elif [ "$gd2_source_arg_libraries_fontconfig" == "source" ]; then
      config_cmd="${config_cmd} --with-fontconfig=${fontconfig_source_path}";
    fi;

    # config command - add options
    if [ -n "$gd2_source_arg_options" ]; then
      config_cmd="${config_cmd} ${gd2_source_arg_options}";
    fi;

    # make command - add make tool
    make_cmd="make -j${global_source_make_cores}";

    # clean, configure and make
    sudo bash -c "cd \"${gd2_source_path}\" && make clean";
    echo "config arguments: ${config_cmd}";
    echo "make arguments: ${make_cmd}";
    sudo bash -c "cd \"${gd2_source_path}\" && eval ${config_cmd} && eval ${make_cmd}";
  else
    notify "errorRoutine" "lib:gd2:source:make";
  fi;
}

# declare routine source:uninstall
function task_lib_gd2_source_uninstall() {
  if [ -f "${global_source_path_usr_lib}/libgd.so" ]; then
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
    echo "whereis source library: ${global_source_path_usr_lib}/libgd.so";
  else
    notify "errorRoutine" "lib:gd2:source:install";
  fi;
}

# declare routine source:test
function task_lib_gd2_source_test() {
  # ldconfig tests
  ldconfig_lookup="libgd.so";
  if [ -f "${global_source_path_usr_lib}/${ldconfig_lookup}" ]; then
    # check ldconfig paths
    ldconfig_cmd1="ldconfig -p | grep ${global_source_path_usr_lib} | grep ${ldconfig_lookup}";
    echo "find source libraries #1: sudo bash -c \"${ldconfig_cmd1}\"";
    sudo bash -c "${ldconfig_cmd1}";
    # check ldconfig versions
    ldconfig_cmd2="ldconfig -v | grep ${ldconfig_lookup}";
    echo "find source libraries #2: sudo bash -c \"${ldconfig_cmd2}\"";
    sudo bash -c "${ldconfig_cmd2}";
  else
    notify "errorRoutine" "lib:gd2:source:test";
  fi;
  # libconfig tests
  libconfig_cmd="${global_source_path_usr_bin}/gdlib-config";
  if [ -f "$libconfig_cmd" ]; then
    # check libconfig info
    libconfig_cmd="${libconfig_cmd} --version --libs --cflags --ldflags --features";
    echo "check libconfig info: ${libconfig_cmd}";
    $libconfig_cmd;
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
