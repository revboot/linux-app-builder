#!/bin/bash
#
# Default configuration
#

# - global
global_task="yes";
global_package_flag="yes";
global_package_install="yes";
global_package_pkgs="both"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04"|"18.04")
  global_package_pkgs_bin="sed grep wget";
  global_package_pkgs_dev="build-essential gcc g++ autoconf automake make m4 bison gawk";
  ;;
esac;
global_package_prefix_usr="/usr";
global_package_path_usr_bin="${global_package_prefix_usr}/bin";
global_package_path_usr_sbin="${global_package_prefix_usr}/sbin";
global_package_path_usr_lib="${global_package_prefix_usr}/lib";
global_package_path_usr_lib64="${global_package_prefix_usr}/lib/x86_64-linux-gnu";
global_package_path_usr_etc="/etc";
global_package_prefix_var="/var";
global_source_flag="yes";
global_source_cleanup="no";
global_source_make_cores="$(nproc)";
global_source_prefix_usr="/usr/local";
global_source_path_usr_bin="${global_source_prefix_usr}/bin";
global_source_path_usr_sbin="${global_source_prefix_usr}/sbin";
global_source_path_usr_lib="${global_source_prefix_usr}/lib";
global_source_path_usr_etc="${global_source_prefix_usr}/etc";
global_source_path_usr_share="${global_source_prefix_usr}/share";
global_source_path_usr_inc="${global_source_prefix_usr}/include";
global_source_path_usr_src="${global_source_prefix_usr}/src";
global_source_prefix_var="/var/local";
global_source_path_var_lib="${global_source_prefix_var}/lib";
global_source_path_var_log="${global_source_prefix_var}/log";
global_source_path_var_run="${global_source_prefix_var}/run";
global_source_path_var_lock="${global_source_prefix_var}/lock";

# - zlib (version 1.1.3 — 1.2.x)
zlib_task="yes";
zlib_package_flag="yes";
zlib_package_uninstall="no"; #careful!!!
zlib_package_install="yes";
zlib_package_test="yes";
zlib_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04"|"18.04")
  zlib_package_pkgs_bin="zlib1g";
  zlib_package_pkgs_dev="zlib1g-dev";
  ;;
esac;
zlib_source_flag="yes";
zlib_source_cleanup="no";
zlib_source_download="yes";
zlib_source_make="yes";
zlib_source_uninstall="no";
zlib_source_install="yes";
zlib_source_test="yes";
zlib_source_version="1.2.11";
zlib_source_url="https://github.com/madler/zlib/archive/v${zlib_source_version}.tar.gz";
zlib_source_tar="${global_source_path_usr_src}/zlib-${zlib_source_version}.tar.gz";
zlib_source_path="${global_source_path_usr_src}/zlib-${zlib_source_version}";
#zlib_source_arg_arch="-arch x86_64"; #-arch x86_64,-arch i386
zlib_source_arg_arch="";
zlib_source_arg_prefix_usr="${global_source_prefix_usr}";
zlib_source_arg_options="";

# - pcre (version 4.4 — 8.x)
pcre_task="yes";
pcre_package_flag="yes";
pcre_package_uninstall="no"; #careful!!!
pcre_package_install="yes";
pcre_package_test="yes";
pcre_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04")
  pcre_package_pkgs_bin="libpcre3     libpcrecpp0   libbz2-1.0 libreadline5"; #libedit2,libeditline0, depends on zlib
  pcre_package_pkgs_dev="libpcre3-dev libpcre++-dev libbz2-dev libreadline-dev"; #libedit-dev,libeditline-dev, depends on zlib
  ;;
"14.04"|"16.04"|"18.04")
  pcre_package_pkgs_bin="libpcre3     libpcrecpp0v5 libbz2-1.0 libreadline5"; #libedit2,libeditline0, depends on zlib
  pcre_package_pkgs_dev="libpcre3-dev libpcre++-dev libbz2-dev libreadline-dev"; #libedit-dev,libeditline-dev, depends on zlib
  ;;
esac;
pcre_source_flag="yes";
pcre_source_cleanup="no";
pcre_source_download="yes";
pcre_source_make="yes";
pcre_source_uninstall="no";
pcre_source_install="yes";
pcre_source_test="yes";
pcre_source_version="8.43";
pcre_source_url="https://ftp.pcre.org/pub/pcre/pcre-${pcre_source_version}.tar.gz";
pcre_source_tar="${global_source_path_usr_src}/pcre-${pcre_source_version}.tar.gz";
pcre_source_path="${global_source_path_usr_src}/pcre-${pcre_source_version}";
pcre_source_arg_arch="x86_64";
pcre_source_arg_prefix_usr="${global_source_prefix_usr}";
pcre_source_arg_options="";
pcre_source_arg_main_pcre8="yes";
pcre_source_arg_main_pcre16="yes";
pcre_source_arg_main_pcre32="yes";
pcre_source_arg_main_jit="yes";
pcre_source_arg_main_utf8="yes";
pcre_source_arg_main_unicode="yes";
pcre_source_arg_tool_pcregreplib="libz";
pcre_source_arg_tool_pcretestlib="libreadline";

# - openssl (version 1.0.2 - 1.1.x)
openssl_task="yes";
openssl_package_flag="yes";
openssl_package_uninstall="no"; #careful!!!
openssl_package_install="yes";
openssl_package_test="yes";
openssl_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04")
  openssl_package_pkgs_bin="libssl1.0.0"; #depends on zlib
  openssl_package_pkgs_dev="libssl-dev"; #depends on zlib
  ;;
"18.04")
  openssl_package_pkgs_bin="libssl1.1"; #depends on zlib
  openssl_package_pkgs_dev="libssl-dev"; #depends on zlib
  ;;
esac;
openssl_source_flag="yes";
openssl_source_cleanup="no";
openssl_source_download="yes";
openssl_source_make="yes";
openssl_source_uninstall="no";
openssl_source_install="yes";
openssl_source_test="yes";
openssl_source_version="1.1.1d";
openssl_source_url="https://www.openssl.org/source/openssl-${openssl_source_version}.tar.gz";
openssl_source_tar="${global_source_path_usr_src}/openssl-${openssl_source_version}.tar.gz";
openssl_source_path="${global_source_path_usr_src}/openssl-${openssl_source_version}";
openssl_source_arg_arch="linux-x86_64";
openssl_source_arg_prefix_usr="${global_source_prefix_usr}";
openssl_source_arg_libraries_zlib="source"; #package,source,no
openssl_source_arg_options="";
openssl_source_arg_main_threads="yes";
openssl_source_arg_main_zlib="yes";
openssl_source_arg_main_nistp="yes";
openssl_source_arg_proto_tls1_3="yes";
openssl_source_arg_proto_tls1_2="yes";
openssl_source_arg_proto_tls1_1="yes";
openssl_source_arg_proto_tls1_0="yes";
openssl_source_arg_proto_ssl3="no";
openssl_source_arg_proto_ssl2="no";
openssl_source_arg_proto_dtls1_2="yes";
openssl_source_arg_proto_dtls1_0="yes";
openssl_source_arg_proto_npn="no";
openssl_source_arg_cypher_idea="yes";
openssl_source_arg_cypher_weak="no";

# - gd2 (version 1.11.6 - 2.2.x)
gd2_task="yes";
gd2_package_flag="yes";
gd2_package_uninstall="no"; #careful!!!
gd2_package_install="yes";
gd2_package_test="yes";
gd2_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04")
  gd2_package_pkgs_bin="libgd2-xpm     libpng12-0  libjpeg8    libwebp2    libtiff4    libxpm4    libfreetype6     libfontconfig1"; #depends on zlib
  gd2_package_pkgs_dev="libgd2-xpm-dev libpng-dev  libjpeg-dev libwebp-dev libtiff-dev libxpm-dev libfreetype6-dev libfontconfig1-dev"; #depends on zlib
  ;;
"14.04"|"16.04")
  gd2_package_pkgs_bin="libgd3         libpng12-0  libjpeg8    libwebp5    libtiff5    libxpm4    libfreetype6     libfontconfig1"; #depends on zlib
  gd2_package_pkgs_dev="libgd-dev      libpng-dev  libjpeg-dev libwebp-dev libtiff-dev libxpm-dev libfreetype6-dev libfontconfig1-dev"; #depends on zlib
  ;;
"18.04")
  gd2_package_pkgs_bin="libgd3         libpng16-16 libjpeg8    libwebp6    libtiff5    libxpm4    libfreetype6     libfontconfig1"; #depends on zlib
  gd2_package_pkgs_dev="libgd-dev      libpng-dev  libjpeg-dev libwebp-dev libtiff-dev libxpm-dev libfreetype6-dev libfontconfig1-dev"; #depends on zlib
  ;;
esac;
gd2_source_flag="yes";
gd2_source_cleanup="no";
gd2_source_download="yes";
gd2_source_make="yes";
gd2_source_uninstall="no";
gd2_source_install="yes";
gd2_source_test="yes";
gd2_source_version="2.2.5";
gd2_source_url="https://github.com/libgd/libgd/releases/download/gd-${gd2_source_version}/libgd-${gd2_source_version}.tar.gz";
gd2_source_tar="${global_source_path_usr_src}/libgd-${gd2_source_version}.tar.gz";
gd2_source_path="${global_source_path_usr_src}/libgd-${gd2_source_version}";
gd2_source_arg_arch="linux-x86_64";
gd2_source_arg_prefix_usr="${global_source_prefix_usr}";
gd2_source_arg_libraries_zlib="source"; #package,source,no
gd2_source_arg_libraries_png="package"; #package,source,no
gd2_source_arg_libraries_jpeg="package"; #package,source,no
gd2_source_arg_libraries_webp="package"; #package,source,no
gd2_source_arg_libraries_tiff="package"; #package,source,no
gd2_source_arg_libraries_xpm="package"; #package,source,no
gd2_source_arg_libraries_liq="no"; #package,source,no
gd2_source_arg_libraries_freetype="package"; #package,source,no
gd2_source_arg_libraries_fontconfig="package"; #package,source,no
gd2_source_arg_options="";

# - xml2 (version 2.6.27 - 2.9.x)
xml2_task="yes";
xml2_package_flag="yes";
xml2_package_uninstall="no"; #careful!!!
xml2_package_install="yes";
xml2_package_test="yes";
xml2_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04")
  xml2_package_pkgs_bin="libxml2     liblzma5    libreadline5    libicu48   python"; #depends on zlib
  xml2_package_pkgs_dev="libxml2-dev liblzma-dev libreadline-dev libicu-dev python-dev"; #depends on zlib
  ;;
"14.04")
  xml2_package_pkgs_bin="libxml2     liblzma5    libreadline5    libicu52   python"; #depends on zlib
  xml2_package_pkgs_dev="libxml2-dev liblzma-dev libreadline-dev libicu-dev python-dev"; #depends on zlib
  ;;
"16.04")
  xml2_package_pkgs_bin="libxml2     liblzma5    libreadline5    libicu55   python"; #depends on zlib
  xml2_package_pkgs_dev="libxml2-dev liblzma-dev libreadline-dev libicu-dev python-dev"; #depends on zlib
  ;;
"18.04")
  xml2_package_pkgs_bin="libxml2     liblzma5    libreadline5    libicu60   python"; #depends on zlib
  xml2_package_pkgs_dev="libxml2-dev liblzma-dev libreadline-dev libicu-dev python-dev"; #depends on zlib
  ;;
esac;
xml2_source_flag="yes";
xml2_source_cleanup="no";
xml2_source_download="yes";
xml2_source_make="yes";
xml2_source_uninstall="no";
xml2_source_install="yes";
xml2_source_test="yes";
xml2_source_version="2.9.9";
xml2_source_url="https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${xml2_source_version}/libxml2-v${xml2_source_version}.tar.gz";
xml2_source_tar="${global_source_path_usr_src}/libxml2-v${xml2_source_version}.tar.gz";
xml2_source_path="${global_source_path_usr_src}/libxml2-v${xml2_source_version}";
xml2_source_arg_arch="linux-x86_64";
xml2_source_arg_prefix_usr="${global_source_prefix_usr}";
xml2_source_arg_libraries_zlib="source"; #package,source,no
xml2_source_arg_libraries_lzma="package"; #package,source,no
xml2_source_arg_libraries_readline="package"; #package,source,no
xml2_source_arg_libraries_iconv="package"; #package,source,no
xml2_source_arg_libraries_python="package"; #package,source,no
xml2_source_arg_options="";
xml2_source_arg_main_threads="yes";
xml2_source_arg_main_threadalloc="yes";
xml2_source_arg_main_ipv6="yes";
xml2_source_arg_main_regexps="yes";
xml2_source_arg_main_dso="yes";
xml2_source_arg_encoding_iso8859x="yes";
xml2_source_arg_encoding_unicode="yes";
xml2_source_arg_xml_canonical="yes";
xml2_source_arg_xml_catalog="yes";
xml2_source_arg_xml_schemas="yes";
xml2_source_arg_xml_schematron="yes";
xml2_source_arg_sgml_docbook="yes";
xml2_source_arg_sgml_html="yes";
xml2_source_arg_sgml_treedom="yes";
xml2_source_arg_parser_pattern="yes";
xml2_source_arg_parser_push="yes";
xml2_source_arg_parser_reader="yes";
xml2_source_arg_parser_sax1="yes";
xml2_source_arg_api_legacy="yes";
xml2_source_arg_api_outputserial="yes";
xml2_source_arg_api_validdtd="yes";
xml2_source_arg_api_writer="yes";
xml2_source_arg_api_xinclude="yes";
xml2_source_arg_api_xpath="yes";
xml2_source_arg_api_xpointer="yes";
xml2_source_arg_proto_ftp="yes";
xml2_source_arg_proto_http="yes";
xml2_source_arg_tool_history="yes";

# - xslt (version 1.0.0 - 1.1.x)
xslt_task="yes";
xslt_package_flag="yes";
xslt_package_uninstall="no"; #careful!!!
xslt_package_install="yes";
xslt_package_test="yes";
xslt_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04"|"18.04")
  xslt_package_pkgs_bin="libxslt1.1   python-dev";
  xslt_package_pkgs_dev="libxslt1-dev python-dev";
  ;;
esac;
xslt_source_flag="yes";
xslt_source_cleanup="yes"; #force clean to avoid docbook issue
xslt_source_download="yes";
xslt_source_make="yes";
xslt_source_uninstall="no";
xslt_source_install="yes";
xslt_source_test="yes";
xslt_source_version="1.1.33";
xslt_source_url="https://gitlab.gnome.org/GNOME/libxslt/-/archive/v${xslt_source_version}/libxslt-v${xslt_source_version}.tar.gz";
xslt_source_tar="${global_source_path_usr_src}/libxslt-v${xslt_source_version}.tar.gz";
xslt_source_path="${global_source_path_usr_src}/libxslt-v${xslt_source_version}";
xslt_source_arg_arch="linux-x86_64";
xslt_source_arg_prefix_usr="${global_source_prefix_usr}";
xslt_source_arg_libraries_xml2="source"; #package,source,no
xslt_source_arg_libraries_python="package"; #package,source,no
xslt_source_arg_options="";
xslt_source_arg_main_crypto="yes";
xslt_source_arg_main_plugins="yes";

# - geoip (version 1.0.0 - 1.6.x)
geoip_task="yes";
geoip_package_flag="yes";
geoip_package_uninstall="no"; #careful!!!
geoip_package_install="yes";
geoip_package_test="yes";
geoip_package_pkgs="dev"; #bin,dev,both
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04"|"18.04")
  geoip_package_pkgs_bin="libgeoip1    geoip-database";
  geoip_package_pkgs_dev="libgeoip-dev geoip-database";
  ;;
esac;
geoip_source_flag="yes";
geoip_source_cleanup="no";
geoip_source_download="yes";
geoip_source_make="yes";
geoip_source_uninstall="no";
geoip_source_install="yes";
geoip_source_test="yes";
geoip_source_version="1.6.12";
geoip_source_url="https://github.com/maxmind/geoip-api-c/releases/download/v${geoip_source_version}/GeoIP-${geoip_source_version}.tar.gz";
geoip_source_tar="${global_source_path_usr_src}/GeoIP-${geoip_source_version}.tar.gz";
geoip_source_path="${global_source_path_usr_src}/GeoIP-${geoip_source_version}";
geoip_source_arg_arch="linux-x86_64";
geoip_source_arg_prefix_usr="${global_source_prefix_usr}";
geoip_source_arg_options="";

# - nginx (version 1.4.7, 1.6.3, 1.8.1, 1.10.3, 1.12.2, 1.14.2, 1.16.1 (stable), 1.17.4)
nginx_task="yes";
nginx_package_flag="no";
nginx_package_uninstall="no"; #careful!!!
nginx_package_install="no";
nginx_package_test="no";
nginx_package_pkgs="bin"; #bin
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04"|"18.04")
  nginx_package_pkgs_bin="nginx-full"; #or nginx-light,nginx-extras, depends on zlib,pcre,openssl
  ;;
esac;
nginx_source_flag="yes";
nginx_source_cleanup="no";
nginx_source_download="yes";
nginx_source_make="yes";
nginx_source_uninstall="no";
nginx_source_install="yes";
nginx_source_etc="yes";
nginx_source_etc_mode="package"; #package,source
nginx_source_test="yes";
nginx_source_version="1.16.1";
nginx_source_url="https://nginx.org/download/nginx-${nginx_source_version}.tar.gz";
nginx_source_tar="${global_source_path_usr_src}/nginx-${nginx_source_version}.tar.gz";
nginx_source_path="${global_source_path_usr_src}/nginx-${nginx_source_version}";
nginx_source_arg_arch="linux-x86_64";
nginx_source_arg_prefix_usr="${global_source_prefix_usr}";
nginx_source_arg_prefix_var="${global_source_prefix_var}";
nginx_source_arg_libraries_zlib="package"; #package,source (set to source with gcc -static or when recompiling via nginx makefile)
nginx_source_arg_libraries_pcre="package"; #package,source (set to source with gcc -static or when recompiling via nginx makefile)
nginx_source_arg_libraries_openssl="package"; #package,source (set to source with gcc -static or when recompiling via nginx makefile)
nginx_source_arg_libraries_libatomic="package"; #package,source (set to source with gcc -static or when recompiling via nginx makefile)
nginx_source_arg_options="";
# - nginx - compiler
nginx_source_arg_compiler_flag="yes";
nginx_source_arg_compiler_paths="source"; #package,source
nginx_source_arg_compiler_cc="-Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS -fexceptions -fasynchronous-unwind-tables -D FD_SETSIZE=8192 -O2"; #-Wdate-time -fPIE -fstack-protector-strong -static -static-libgcc
nginx_source_arg_compiler_ld="-Wl,--as-needed -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now"; #-fPIE -pie -static
# - nginx - main config
nginx_source_arg_main_debug_flag="no";
nginx_source_arg_main_threads_flag="yes";
nginx_source_arg_main_fileaio_flag="yes";
nginx_source_arg_main_compat_flag="yes";
nginx_source_arg_main_ipv6_flag="no"; #deprecated since 1.11.5
nginx_source_arg_main_distro="Ubuntu";
nginx_source_arg_main_user="www-data";
nginx_source_arg_main_group="www-data";
# - nginx - modules - connection
nginx_source_arg_module_poll_flag="auto"; #auto,yes,no
nginx_source_arg_module_select_flag="auto"; #auto,yes,no
# - nginx - modules - http
nginx_source_arg_modules_http_flag="yes";
# - nginx - modules - http - protocol
nginx_source_arg_modules_http_http2_flag="yes";
nginx_source_arg_modules_http_spdy_flag="no"; #deprecated since 1.9.5
nginx_source_arg_modules_http_ssl_flag="yes";
nginx_source_arg_modules_http_webdav_flag="yes";
# - nginx - modules - http - core
nginx_source_arg_modules_http_rewrite_flag="yes";
nginx_source_arg_modules_http_map_flag="yes";
nginx_source_arg_modules_http_browser_flag="yes";
nginx_source_arg_modules_http_userid_flag="yes";
# - nginx - modules - http - index
nginx_source_arg_modules_http_autoindex_flag="yes";
nginx_source_arg_modules_http_randomindex_flag="yes";
# - nginx - modules - http - access/limit
nginx_source_arg_modules_http_access_flag="yes";
nginx_source_arg_modules_http_limitconn_flag="yes";
nginx_source_arg_modules_http_limitreq_flag="yes";
# - nginx - modules - http - auth
nginx_source_arg_modules_http_authbasic_flag="yes";
nginx_source_arg_modules_http_authrequest_flag="yes";
# - nginx - modules - http - security
nginx_source_arg_modules_http_referer_flag="yes";
nginx_source_arg_modules_http_securelink_flag="yes";
# - nginx - modules - http - location
nginx_source_arg_modules_http_realip_flag="yes";
nginx_source_arg_modules_http_geo_flag="yes";
nginx_source_arg_modules_http_geoip_flag="yes"; #yes,dso,no
# - nginx - modules - http - encoding
nginx_source_arg_modules_http_gzip_flag="yes";
nginx_source_arg_modules_http_gunzip_flag="yes";
nginx_source_arg_modules_http_charset_flag="yes";
# - nginx - modules - http - filter
nginx_source_arg_modules_http_emptygif_flag="yes";
nginx_source_arg_modules_http_imagefilter_flag="yes"; #yes,dso,no (disable with -static)
nginx_source_arg_modules_http_xslt_flag="yes"; #yes,dso,no (disable with -static)
nginx_source_arg_modules_http_sub_flag="yes";
nginx_source_arg_modules_http_addition_flag="yes";
nginx_source_arg_modules_http_slice_flag="yes";
# - nginx - modules - http - stream
nginx_source_arg_modules_http_mp4_flag="yes";
nginx_source_arg_modules_http_flv_flag="yes";
# - nginx - modules - http - upstream
nginx_source_arg_modules_http_upstream_keepalive_flag="yes";
nginx_source_arg_modules_http_upstream_leastconn_flag="yes";
nginx_source_arg_modules_http_upstream_random_flag="yes";
nginx_source_arg_modules_http_upstream_hash_flag="yes";
nginx_source_arg_modules_http_upstream_iphash_flag="yes";
nginx_source_arg_modules_http_upstream_zone_flag="yes";
# - nginx - modules - http - proxy/cgi
nginx_source_arg_modules_http_proxy_flag="yes";
nginx_source_arg_modules_http_fastcgi_flag="yes";
nginx_source_arg_modules_http_scgi_flag="yes";
nginx_source_arg_modules_http_uwsgi_flag="yes";
nginx_source_arg_modules_http_grpc_flag="yes";
# - nginx - modules - http - script
nginx_source_arg_modules_http_ssi_flag="yes";
nginx_source_arg_modules_http_perl_flag="no"; #yes,dso,no
# - nginx - modules - http - cache
nginx_source_arg_modules_http_cache_flag="yes";
nginx_source_arg_modules_http_memcached_flag="yes";
# - nginx - modules - http - other
nginx_source_arg_modules_http_mirror_flag="yes";
nginx_source_arg_modules_http_splitclients_flag="yes";
nginx_source_arg_modules_http_stub_flag="yes";
# - nginx - modules - stream
nginx_source_arg_modules_stream_flag="yes"; #yes,dso,no
# - nginx - modules - stream - protocol
nginx_source_arg_modules_stream_ssl_flag="yes";
nginx_source_arg_modules_stream_ssl_preread_flag="yes";
# - nginx - modules - stream - core
nginx_source_arg_modules_stream_map_flag="yes";
# - nginx - modules - stream - access/limit
nginx_source_arg_modules_stream_access_flag="yes";
nginx_source_arg_modules_stream_limitconn_flag="yes";
# - nginx - modules - steam - location
nginx_source_arg_modules_stream_realip_flag="yes";
nginx_source_arg_modules_stream_geo_flag="yes";
nginx_source_arg_modules_stream_geoip_flag="yes"; #yes,dso,no
# - nginx - modules - stream - upstream
nginx_source_arg_modules_stream_upstream_leastconn_flag="yes";
nginx_source_arg_modules_stream_upstream_random_flag="yes";
nginx_source_arg_modules_stream_upstream_hash_flag="yes";
nginx_source_arg_modules_stream_upstream_zone_flag="yes";
# - nginx - modules - stream - other
nginx_source_arg_modules_stream_return_flag="yes";
nginx_source_arg_modules_stream_splitclients_flag="yes";
# - nginx - modules - mail
nginx_source_arg_modules_mail_flag="yes"; #yes,dso,no
# - nginx - modules - mail - protocol
nginx_source_arg_modules_mail_ssl_flag="yes";
nginx_source_arg_modules_mail_smtp_flag="yes";
nginx_source_arg_modules_mail_pop3_flag="yes";
nginx_source_arg_modules_mail_imap_flag="yes";
# - nginx - modules - other
nginx_source_arg_modules_other_flag="yes";
nginx_source_arg_modules_other_cpptest_flag="no";
nginx_source_arg_modules_other_googleperftools_flag="no";

# - haproxy (version 1.5.19, 1.6.15, 1.7.12, 1.8.22, 1.9.12 (stable), 2.0.9 (stable))
haproxy_task="yes";
haproxy_package_flag="no";
haproxy_package_uninstall="no"; #careful!!!
haproxy_package_install="no";
haproxy_package_test="no";
haproxy_package_pkgs="bin"; #bin
case "$DISTRIB_RELEASE" in
"12.04"|"14.04"|"16.04"|"18.04")
  haproxy_package_pkgs_bin="haproxy"; #depends on zlib,pcre,openssl,libcrypt,lua
  ;;
esac;
haproxy_source_flag="yes";
haproxy_source_cleanup="no";
haproxy_source_download="yes";
haproxy_source_make="yes";
haproxy_source_uninstall="no";
haproxy_source_install="yes";
haproxy_source_test="yes";
haproxy_source_branch="1.9";
haproxy_source_version="1.9.12";
haproxy_source_url="https://www.haproxy.org/download/${haproxy_source_branch}/src/haproxy-${haproxy_source_version}.tar.gz";
haproxy_source_tar="${global_source_path_usr_src}/haproxy-${haproxy_source_version}.tar.gz";
haproxy_source_path="${global_source_path_usr_src}/haproxy-${haproxy_source_version}";
haproxy_source_arg_target="linux2628";
haproxy_source_arg_cpu="generic";
haproxy_source_arg_arch="x86_64";
haproxy_source_arg_prefix_usr="${global_source_prefix_usr}";
haproxy_source_arg_options="";
