#!/bin/bash
#
# Task: Library: gd2
#

function task_lib_gd2() {

  # build subtask
  if [ "$gd2_build_flag" == "yes" ]; then
    notify "startSubTask" "lib:gd2:build";

    # cleanup code and tar
    if [ "$gd2_build_cleanup" == "yes" ]; then
      notify "startRoutine" "lib:gd2:build:cleanup";
      sudo rm -Rf ${gd2_build_path}*;
      notify "stopRoutine" "lib:gd2:build:cleanup";
    else
      notify "skipRoutine" "lib:gd2:build:cleanup";
    fi;

    # extract code from tar
    if [ ! -d "$gd2_build_path" ]; then
      notify "startRoutine" "lib:gd2:build:download";
      if [ ! -f "${gd2_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src && wget ${gd2_build_url} && tar xzf ${gd2_build_tar}";
      else
        sudo bash -c "cd ${global_build_usrprefix}/src && tar xzf ${gd2_build_tar}";
      fi;
      notify "stopRoutine" "lib:gd2:build:download";
    else
      notify "skipRoutine" "lib:gd2:build:download";
    fi;

    cd $gd2_build_path;

    # compile binaries
    if [ "$gd2_build_make" == "yes" ]; then
      notify "startRoutine" "lib:gd2:build:make";
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
      sudo make clean;
      echo "${gd2_build_cmd_full}";
      sudo $gd2_build_cmd_full && sudo make;
      notify "stopRoutine" "lib:gd2:build:make";
    else
      notify "skipRoutine" "lib:gd2:build:make";
    fi;

    # install binaries
    if [ "$gd2_build_install" == "yes" ] && [ -f "${gd2_build_path}/src/.libs/libgd.so" ]; then
      notify "startRoutine" "lib:gd2:build:install";
      sudo make uninstall; sudo make install;
      echo "system library: $(whereis libgd.so)";
      echo "built library: ${global_build_usrprefix}/lib/libgd.so";
      gd2_ldconfig_test_cmd="ldconfig -p | grep libgd.so; ldconfig -v | grep libgd.so";
      echo "list libraries: ${gd2_ldconfig_test_cmd}"; ${gd2_ldconfig_test_cmd};
      notify "stopRoutine" "lib:gd2:build:install";
    else
      notify "skipRoutine" "lib:gd2:build:install";
    fi;

    # test binaries
    if [ "$gd2_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/bin/gdlib-config" ]; then
      notify "startRoutine" "lib:gd2:build:test";
      gd2_binary_test_cmd="gdlib-config --version --libs --cflags --ldflags --features";
      echo "test system binary: /usr/bin/${gd2_binary_test_cmd}"; /usr/bin/${gd2_binary_test_cmd};
      echo "test built binary: ${global_build_usrprefix}/bin/${gd2_binary_test_cmd}"; ${global_build_usrprefix}/bin/${gd2_binary_test_cmd};
      notify "stopRoutine" "lib:gd2:build:test";
    else
      notify "skipRoutine" "lib:gd2:build:test";
    fi;

    notify "stopSubTask" "lib:gd2:build";
  else
    notify "skipSubTask" "lib:gd2:build";
  fi;

}
