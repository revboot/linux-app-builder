#!/bin/bash
#
# Task: Application: nginx
#

function task_app_nginx() {

  # build subtask
  if [ "$nginx_build_flag" == "yes" ]; then
    notify "startSubTask" "app:nginx:build";

    # cleanup code and tar
    if [ "$nginx_build_cleanup" == "yes" ]; then
      notify "startRoutine" "app:nginx:build:cleanup";
      sudo rm -Rf ${nginx_build_path}*;
      notify "stopRoutine" "app:nginx:build:cleanup";
    else
      notify "skipRoutine" "app:nginx:build:cleanup";
    fi;

    # extract code from tar
    if [ ! -d "$nginx_build_path" ]; then
      notify "startRoutine" "app:nginx:build:download";
      if [ ! -f "${nginx_build_tar}" ]; then
        sudo bash -c "cd ${global_build_usrprefix}/src && wget ${nginx_build_url} && tar xzf ${nginx_build_tar}";
      else
        sudo bash -c "cd ${global_build_usrprefix}/src && tar xzf ${nginx_build_tar}";
      fi;
      notify "stopRoutine" "app:nginx:build:download";
    else
      notify "skipRoutine" "app:nginx:build:download";
    fi;

    cd $nginx_build_path;

    # compile binaries
    if [ "$nginx_build_make" == "yes" ]; then
      notify "startRoutine" "app:nginx:build:make";
      # command - add configuration tool
      nginx_build_cmd_full="./configure";

      # command - add compiler
      if [ "$nginx_build_arg_compiler_flag" == "yes" ]; then
        # command - add compiler: li
        if [ "$nginx_build_arg_compiler_L_I" == "custom" ]; then
          nginx_build_arg_compiler_cc="${nginx_build_arg_compiler_cc} -I ${global_build_usrprefix}/include";
          nginx_build_arg_compiler_ld="${nginx_build_arg_compiler_ld} -L ${global_build_usrprefix}/lib";
        fi;

        # command - add compiler: cc
        if [ -n "$nginx_build_arg_compiler_cc" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-cc-opt=\'${nginx_build_arg_compiler_cc}\'";
        fi;

        # command - add compiler: ld
        if [ -n "$nginx_build_arg_compiler_ld" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-ld-opt=\'${nginx_build_arg_compiler_ld}\'";
        fi;
      fi;

      # command - add arch
      if [ -n "$nginx_build_arg_arch" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-cpu-opt=${nginx_build_arg_arch}";
      fi;

      # command - add prefix (usr)
      if [ -n "$nginx_build_arg_usrprefix" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --prefix=${nginx_build_arg_usrprefix}/share/nginx";
        nginx_build_cmd_full="${nginx_build_cmd_full} --sbin-path=${nginx_build_arg_usrprefix}/sbin/nginx";
        nginx_build_cmd_full="${nginx_build_cmd_full} --modules-path=${nginx_build_arg_usrprefix}/lib/nginx/modules";
      fi;
      # command - add prefix (var)
      if [ -n "$nginx_build_arg_varprefix" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-client-body-temp-path=${nginx_build_arg_varprefix}/lib/nginx/body";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-proxy-temp-path=${nginx_build_arg_varprefix}/lib/nginx/proxy";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-fastcgi-temp-path=${nginx_build_arg_varprefix}/lib/nginx/fastcgi";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-scgi-temp-path=${nginx_build_arg_varprefix}/lib/nginx/scgi";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-uwsgi-temp-path=${nginx_build_arg_varprefix}/lib/nginx/uwsgi";
        nginx_build_cmd_full="${nginx_build_cmd_full} --pid-path=${nginx_build_arg_varprefix}/run/nginx.pid";
        nginx_build_cmd_full="${nginx_build_cmd_full} --lock-path=${nginx_build_arg_varprefix}/lock/nginx.lock";
        nginx_build_cmd_full="${nginx_build_cmd_full} --error-log-path=${nginx_build_arg_varprefix}/log/nginx/error.log";
        nginx_build_cmd_full="${nginx_build_cmd_full} --http-log-path=${nginx_build_arg_varprefix}/log/nginx/access.log";
        nginx_build_cmd_full="${nginx_build_cmd_full} --conf-path=${nginx_build_arg_varprefix}/etc/nginx/nginx.conf";
      fi;

      # command - add libraries: zlib
      if [ "$nginx_build_arg_libraries_zlib" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_zlib" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-zlib=${zlib_build_path}";
      fi;

      # command - add libraries: pcre
      if [ "$nginx_build_arg_libraries_pcre" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_pcre" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-pcre=${pcre_build_path} --with-pcre-jit";
      elif [ "$nginx_build_arg_libraries_pcre" == "no" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --without-pcre";
      fi;

      # command - add libraries: openssl
      if [ "$nginx_build_arg_libraries_openssl" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_openssl" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl=${openssl_build_path}";
      fi;
      if [ "$nginx_build_arg_libraries_openssl" == "system" ] || [ "$nginx_build_arg_libraries_openssl" == "custom" ]; then
        # command - add openssl arch
        if [ -n "$openssl_build_arg_arch" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=${openssl_build_arg_arch}";
        fi;

        # command - add openssl options
        if [ -n "$openssl_build_arg_options" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=${openssl_build_arg_options}";
        fi;

        # command - add openssl main: threads
        if [ "$openssl_build_arg_main_threads" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=threads";
        elif [ "$openssl_build_arg_main_threads" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-threads";
        fi;

        # command - add openssl main: zlib
        if [ "$openssl_build_arg_main_zlib" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=zlib";
        fi;

        # command - add openssl main: nistp gcc
        if [ "$openssl_build_arg_main_nistp" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=enable-ec_nistp_64_gcc_128";
        fi;

        # command - add openssl proto: tls 1.3
        if [ "$openssl_build_arg_proto_tls1_3" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1_3";
        fi;

        # command - add openssl proto: tls 1.2
        if [ "$openssl_build_arg_proto_tls1_2" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1_2";
        fi;

        # command - add openssl proto: tls 1.1
        if [ "$openssl_build_arg_proto_tls1_1" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1_1";
        fi;

        # command - add openssl proto: tls 1.0
        if [ "$openssl_build_arg_proto_tls1_0" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-tls1";
        fi;

        # command - add openssl proto: ssl 3
        if [ "$openssl_build_arg_proto_ssl3" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-ssl3";
        fi;

        # command - add openssl proto: ssl 2
        if [ "$openssl_build_arg_proto_ssl2" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-ssl2";
        fi;

        # command - add openssl proto: dtls 1.2
        if [ "$openssl_build_arg_proto_dtls1_2" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-dtls1_2";
        fi;

        # command - add openssl proto: dtls 1.0
        if [ "$openssl_build_arg_proto_dtls1_0" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-dtls1";
        fi;

        # command - add openssl proto: next proto negotiation
        if [ "$openssl_build_arg_proto_npn" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-nextprotoneg";
        fi;

        # command - add openssl cypher: idea
        if [ "$openssl_build_arg_cypher_idea" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-idea";
        fi;

        # command - add openssl cypher: weak ciphers
        if [ "$openssl_build_arg_cypher_weak" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-openssl-opt=no-weak-ssl-ciphers";
        fi;
      fi;

      # command - add libraries: libatomic
      if [ "$nginx_build_arg_libraries_libatomic" == "system" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full}";
      elif [ "$nginx_build_arg_libraries_libatomic" == "custom" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-libatomic=${libatomic_build_path}";
      fi;

      # command - add options
      if [ -n "$nginx_build_arg_options" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} ${nginx_build_arg_options}";
      fi;

      # command - add main: distro
      if [ -n "$nginx_build_arg_main_distro" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --build=${nginx_build_arg_main_distro}";
      fi;

      # command - add main: user
      if [ -n "$nginx_build_arg_main_user" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --user=${nginx_build_arg_main_user}";
      fi;

      # command - add main: group
      if [ -n "$nginx_build_arg_main_group" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --group=${nginx_build_arg_main_group}";
      fi;

      # command - add main: debug
      if [ "$nginx_build_arg_main_debug_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-debug";
      fi;

      # command - add main: threads
      if [ "$nginx_build_arg_main_threads_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-threads";
      fi;

      # command - add main: asynchronous io
      if [ "$nginx_build_arg_main_fileaio_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-file-aio";
      fi;

      # command - add main: ipv6
      if [ "$nginx_build_arg_main_ipv6_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-ipv6";
      fi;

      # command - add main: (dynamic module) compat(ibility)
      if [ "$nginx_build_arg_main_compat_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-compat";
      fi;

      # command - add connection modules: poll
      if [ "$nginx_build_arg_module_poll_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-poll_module";
      elif [ "$nginx_build_arg_module_poll_flag" == "no" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --without-poll_module";
      fi;

      # command - add connection modules: select
      if [ "$nginx_build_arg_module_select_flag" == "yes" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --with-select_module";
      elif [ "$nginx_build_arg_module_select_flag" == "no" ]; then
        nginx_build_cmd_full="${nginx_build_cmd_full} --without-select_module";
      fi;

      if [ "$nginx_build_arg_modules_http_flag" == "yes" ]; then
        # command - add http modules: protocol: (http)v2
        if [ "$nginx_build_arg_modules_http_http2_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_v2_module";
        fi;

        # command - add http modules: protocol: spdy
        if [ "$nginx_build_arg_modules_http_spdy_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_spdy_module";
        fi;

        # command - add http modules: protocol: ssl
        if [ "$nginx_build_arg_modules_http_ssl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_ssl_module";
        fi;

       # command - add http modules: protocol: dav
        if [ "$nginx_build_arg_modules_http_webdav_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_dav_module";
        fi;

        # command - add http modules: core: rewrite
        if [ "$nginx_build_arg_modules_http_rewrite_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_rewrite_module";
        fi;

        # command - add http modules: core: map
        if [ "$nginx_build_arg_modules_http_map_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_map_module";
        fi;

        # command - add http modules: core: browser
        if [ "$nginx_build_arg_modules_http_browser_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_browser_module";
        fi;

        # command - add http modules: core: userid
        if [ "$nginx_build_arg_modules_http_userid_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_userid_module";
        fi;

        # command - add http modules: index: auto_index
        if [ "$nginx_build_arg_modules_http_autoindex_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_autoindex_module";
        fi;

        # command - add http modules: index: random_index
        if [ "$nginx_build_arg_modules_http_randomindex_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_random_index_module";
        fi;

        # command - add http modules: access/limit: access
        if [ "$nginx_build_arg_modules_http_access_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_access_module";
        fi;

        # command - add http modules: access/limit: limit_conn
        if [ "$nginx_build_arg_modules_http_limitconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_limit_conn_module";
        fi;

        # command - add http modules: access/limit: limit_req
        if [ "$nginx_build_arg_modules_http_limitreq_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_limit_req_module";
        fi;

        # command - add http modules: auth: auth_basic
        if [ "$nginx_build_arg_modules_http_authbasic_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_auth_basic_module";
        fi;

        # command - add http modules: auth: auth_(sub)request
        if [ "$nginx_build_arg_modules_http_authrequest_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_auth_request_module";
        fi;

        # command - add http modules: security: referer
        if [ "$nginx_build_arg_modules_http_referer_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_referer_module";
        fi;

        # command - add http modules: security: secure_link
        if [ "$nginx_build_arg_modules_http_securelink_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_secure_link_module";
        fi;

        # command - add http modules: location: realip
        if [ "$nginx_build_arg_modules_http_realip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_realip_module";
        fi;

        # command - add http modules: location: geo
        if [ "$nginx_build_arg_modules_http_geo_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_geo_module";
        fi;

        # command - add http modules: location: geoip --static
        if [ "$nginx_build_arg_modules_http_geoip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_geoip_module";
        fi;

        # command - add http modules: location: geoip --dso
        if [ "$nginx_build_arg_modules_http_geoip_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_geoip_module=dynamic";
        fi;

        # command - add http modules: encoding: gzip_static/gzip
        if [ "$nginx_build_arg_modules_http_gzip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_gzip_static_module";
        elif [ "$nginx_build_arg_modules_http_gzip_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_gzip_module";
        fi;

        # command - add http modules: encoding: gunzip
        if [ "$nginx_build_arg_modules_http_gunzip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_gunzip_module";
        fi;

        # command - add http modules: encoding: charset
        if [ "$nginx_build_arg_modules_http_charset_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_charset_module";
        fi;

        # command - add http modules: filter: empty_gif
        if [ "$nginx_build_arg_modules_http_emptygif_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_empty_gif_module";
        fi;

        # command - add http modules: filter: image_filter --static
        if [ "$nginx_build_arg_modules_http_imagefilter_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_image_filter_module";
        fi;

        # command - add http modules: filter: image_filter --dso
        if [ "$nginx_build_arg_modules_http_imagefilter_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_image_filter_module=dynamic";
        fi;

        # command - add http modules: filter: xslt --static
        if [ "$nginx_build_arg_modules_http_xslt_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_xslt_module";
        fi;

        # command - add http modules: filter: xslt --dso
        if [ "$nginx_build_arg_modules_http_xslt_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_xslt_module=dynamic";
        fi;

        # command - add http modules: filter: sub(stitute)
        if [ "$nginx_build_arg_modules_http_sub_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_sub_module";
        fi;

        # command - add http modules: filter: addition
        if [ "$nginx_build_arg_modules_http_addition_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_addition_module";
        fi;

        # command - add http modules: filter: slice
        if [ "$nginx_build_arg_modules_http_slice_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_slice_module";
        fi;

        # command - add http modules: pseudo-stream: mp4
        if [ "$nginx_build_arg_modules_http_mp4_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_mp4_module";
        fi;

        # command - add http modules: pseudo-stream: flv
        if [ "$nginx_build_arg_modules_http_flv_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_flv_module";
        fi;

        # command - add http modules: upstream: upstream_keepalive
        if [ "$nginx_build_arg_modules_http_upstream_keepalive_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_keepalive_module";
        fi;

        # command - add http modules: upstream: upstream_least_conn
        if [ "$nginx_build_arg_modules_http_upstream_leastconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_least_conn_module";
        fi;

        # command - add http modules: upstream: upstream_random
        if [ "$nginx_build_arg_modules_http_upstream_random_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_random_module";
        fi;

        # command - add http modules: upstream: upstream_hash
        if [ "$nginx_build_arg_modules_http_upstream_hash_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_hash_module";
        fi;

        # command - add http modules: upstream: upstream_ip_hash
        if [ "$nginx_build_arg_modules_http_upstream_iphash_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_ip_hash_module";
        fi;

        # command - add http modules: upstream: upstream_zone
        if [ "$nginx_build_arg_modules_http_upstream_zone_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_upstream_zone_module";
        fi;

        # command - add http modules: proxy/cgi: proxy
        if [ "$nginx_build_arg_modules_http_proxy_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_proxy_module";
        fi;

        # command - add http modules: proxy/cgi: fastcgi
        if [ "$nginx_build_arg_modules_http_fastcgi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_fastcgi_module";
        fi;

        # command - add http modules: proxy/cgi: scgi
        if [ "$nginx_build_arg_modules_http_scgi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_scgi_module";
        fi;

        # command - add http modules: proxy/cgi: uwsgi
        if [ "$nginx_build_arg_modules_http_uwsgi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_uwsgi_module";
        fi;

        # command - add http modules: proxy/cgi: grpc
        if [ "$nginx_build_arg_modules_http_grpc_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_grpc_module";
        fi;

        # command - add http modules: script: ssi
        if [ "$nginx_build_arg_modules_http_ssi_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_ssi_module";
        fi;

        # command - add http modules: script: perl --static
        if [ "$nginx_build_arg_modules_http_perl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_perl_module";
        fi;

        # command - add http modules: script: perl --dso
        if [ "$nginx_build_arg_modules_http_perl_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_perl_module=dynamic";
        fi;

        # command - add http modules: cache
        if [ "$nginx_build_arg_modules_http_cache_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http-cache";
        fi;

        # command - add http modules: cache: memcached
        if [ "$nginx_build_arg_modules_http_memcached_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_memcached_module";
        fi;

        # command - add http modules: other: mirror
        if [ "$nginx_build_arg_modules_http_mirror_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_mirror_module";
        fi;

        # command - add http modules: other: split_clients
        if [ "$nginx_build_arg_modules_http_splitclients_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-http_split_clients_module";
        fi;

        # command - add http modules: other: stub_status:
        if [ "$nginx_build_arg_modules_http_stub_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-http_stub_status_module";
        fi;
      fi;

      # command - add stream modules
      if [ "$nginx_build_arg_modules_stream_flag" == "yes" ] || [ "$nginx_build_arg_modules_stream_flag" == "dso" ]; then
        # command - add stream modules: --static
        if [ "$nginx_build_arg_modules_stream_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream";
        fi;

        # command - add stream modules: --dso
        if [ "$nginx_build_arg_modules_stream_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream=dynamic";
        fi;

        # command - add stream modules: protocol: ssl
        if [ "$nginx_build_arg_modules_stream_ssl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_ssl_module";
        fi;

        # command - add stream modules: protocol: ssl_preread
        if [ "$nginx_build_arg_modules_stream_ssl_preread_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_ssl_preread_module";
        fi;

        # command - add stream modules: core: map
        if [ "$nginx_build_arg_modules_stream_map_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_map_module";
        fi;

        # command - add stream modules: access/limit: limit_conn
        if [ "$nginx_build_arg_modules_stream_limitconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_limit_conn_module";
        fi;

        # command - add stream modules: access/limit: access
        if [ "$nginx_build_arg_modules_stream_access_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_access_module";
        fi;

        # command - add stream modules: location: realip
        if [ "$nginx_build_arg_modules_stream_realip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_realip_module";
        fi;

        # command - add stream modules: location: geo
        if [ "$nginx_build_arg_modules_stream_geo_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_geo_module";
        fi;

        # command - add stream modules: location: geoip: --static
        if [ "$nginx_build_arg_modules_stream_geoip_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_geoip_module";
        # command - add stream modules: location: geoip: --dso
        elif [ "$nginx_build_arg_modules_stream_geoip_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-stream_geoip_module=dynamic";
        fi;

        # command - add stream modules: upstream: upstream_least_conn
        if [ "$nginx_build_arg_modules_stream_upstream_leastconn_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_least_conn_module";
        fi;

        # command - add stream modules: upstream: upstream_random
        if [ "$nginx_build_arg_modules_stream_upstream_random_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_random_module";
        fi;

        # command - add stream modules: upstream: upstream_hash
        if [ "$nginx_build_arg_modules_stream_upstream_hash_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_hash_module";
        fi;

        # command - add stream modules: upstream: upstream_zone
        if [ "$nginx_build_arg_modules_stream_upstream_zone_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_upstream_zone_module";
        fi;

        # command - add stream modules: other: return
        if [ "$nginx_build_arg_modules_stream_return_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_return_module";
        fi;

        # command - add stream modules: other: split_clients
        if [ "$nginx_build_arg_modules_stream_splitclients_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-stream_split_clients_module";
        fi;
      fi;

      # command - add mail modules
      if [ "$nginx_build_arg_modules_mail_flag" == "yes" ] || [ "$nginx_build_arg_modules_mail_flag" == "dso" ]; then
        # command - add mail modules: --static
        if [ "$nginx_build_arg_modules_mail_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-mail";
        # command - add mail modules: --dso
        elif [ "$nginx_build_arg_modules_mail_flag" == "dso" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-mail=dynamic";
        fi;

        # command - add mail modules: protocol: ssl
        if [ "$nginx_build_arg_modules_mail_ssl_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-mail_ssl_module";
        fi;

        # command - add mail modules: protocol: smtp
        if [ "$nginx_build_arg_modules_mail_smtp_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-mail_smtp_module";
        fi;

        # command - add mail modules: protocol: pop3
        if [ "$nginx_build_arg_modules_mail_pop3_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-mail_pop3_module";
        fi;

        # command - add mail modules: protocol: imap
        if [ "$nginx_build_arg_modules_mail_imap_flag" == "no" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --without-mail_imap_module";
        fi;

      fi;

      # command - add other modules
      if [ "$nginx_build_arg_modules_other_flag" == "yes" ]; then
        # command - add other modules: cpp_test
        if [ "$nginx_build_arg_modules_other_cpptest_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-cpp_test_module";
        fi;

        # command - add other modules: google_perftools
        if [ "$nginx_build_arg_modules_other_googleperftools_flag" == "yes" ]; then
          nginx_build_cmd_full="${nginx_build_cmd_full} --with-google_perftools_module";
        fi;
      fi;

      # clean, configure and make
      sudo make clean;
      echo "${nginx_build_cmd_full}";
      sudo bash -c "eval $nginx_build_cmd_full" && sudo make -j1;
      echo "system library: ldd /usr/sbin/nginx"; ldd /usr/sbin/nginx;
      echo "system library: ldd ${nginx_build_path}/objs/nginx"; ldd ${nginx_build_path}/objs/nginx;
      echo "env LD_DEBUG=statistics /usr/sbin/nginx -v"; env LD_DEBUG=statistics /usr/sbin/nginx -v;
      echo "env LD_DEBUG=statistics ${nginx_build_path}/objs/nginx -v"; env LD_DEBUG=statistics ${nginx_build_path}/objs/nginx -v;
      notify "stopRoutine" "app:nginx:build:make";
    else
      notify "skipRoutine" "app:nginx:build:make";
    fi;

    # install binaries
    if [ "$nginx_build_install" == "yes" ] && [ -f "${nginx_build_path}/objs/nginx" ]; then
      notify "stopRoutine" "app:nginx:build:install";
      sudo make uninstall; sudo make install;
      sudo mkdir -p "${global_build_varprefix}/lib/nginx";
      echo "system binary: $(whereis nginx)";
      echo "built binary: ${global_build_usrprefix}/sbin/nginx";
      notify "stopRoutine" "app:nginx:build:install";
    else
      notify "skipRoutine" "app:nginx:build:install";
    fi;

    # install config
    if [ ! "$nginx_build_install_etc" == "no" ]; then
      notify "startRoutine" "app:nginx:build:install_etc";
      if [ "$nginx_build_install_etc" == "system" ]; then
        if [ -d "${global_build_varprefix}/etc/nginx" ]; then
          sudo rm -Rf "${global_build_varprefix}/etc/nginx";
        elif [ -L "${global_build_varprefix}/etc/nginx" ]; then
          sudo rm -f "${global_build_varprefix}/etc/nginx";
        fi;
        sudo ln -s "/etc/nginx" "${global_build_varprefix}/etc/nginx";
        sudo rm -f "${global_build_varprefix}/etc/nginx/*.default";
      elif [ "$nginx_build_install_etc" == "build" ]; then
        sudo cp "${global_build_varprefix}/etc/nginx/*" "/etc/nginx";
      fi;
      notify "stopRoutine" "app:nginx:build:install_etc";
    else
      notify "skipRoutine" "app:nginx:build:install_etc";
    fi;

    # test binaries
    if [ "$nginx_build_test" == "yes" ] && [ -f "${global_build_usrprefix}/sbin/nginx" ]; then
      notify "startRoutine" "app:nginx:build:test";
      nginx_test_cmd="nginx -v -V -t";
      echo "test system binary: sudo /usr/sbin/${nginx_test_cmd}"; sudo /usr/sbin/${nginx_test_cmd};
      echo "test built binary: sudo ${global_build_usrprefix}/sbin/${nginx_test_cmd}"; sudo ${global_build_usrprefix}/sbin/${nginx_test_cmd};
      notify "stopRoutine" "app:nginx:build:test";
    else
      notify "skipRoutine" "app:nginx:build:test";
    fi;

    notify "stopSubTask" "app:nginx:build";
  else
    notify "skipSubTask" "app:nginx:build";
  fi;

}
