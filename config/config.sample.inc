#!/bin/bash
#
# Sample configuration
#

# - global
global_apt_flag="yes";
global_build_flag="yes";
global_build_cleanup="no";
global_build_usrprefix="/usr/local";
global_build_varprefix="/var/local";

# - development tools
dev_apt_flag="yes";

# - zlib (version 1.1.3 — 1.2.x)
zlib_apt_flag="yes";
zlib_build_flag="yes";
zlib_build_cleanup="no";
zlib_build_make="yes";
zlib_build_install="yes";
zlib_build_test="yes";
zlib_build_version="1.2.11";
#zlib_build_arg_arch="-arch x86_64"; #-arch x86_64,-arch i386
zlib_build_arg_arch="";
zlib_build_arg_options="";

# - pcre (version 4.4 — 8.x)
pcre_apt_flag="yes";
pcre_build_flag="yes";
pcre_build_cleanup="no";
pcre_build_make="yes";
pcre_build_install="yes";
pcre_build_test="yes";
pcre_build_version="8.43";
pcre_build_arg_arch="x86_64";
pcre_build_arg_options="";
pcre_build_arg_main_pcre8="yes";
pcre_build_arg_main_pcre16="yes";
pcre_build_arg_main_pcre32="yes";
pcre_build_arg_main_jit="yes";
pcre_build_arg_main_utf8="yes";
pcre_build_arg_main_unicode="yes";
pcre_build_arg_tool_pcregreplib="libz";
pcre_build_arg_tool_pcretestlib="libreadline";

# - openssl (version 1.0.2 - 1.1.x)
openssl_apt_flag="yes";
openssl_build_flag="yes";
openssl_build_cleanup="no";
openssl_build_make="yes";
openssl_build_install="yes";
openssl_build_test="yes";
openssl_build_version="1.1.1d";
openssl_build_arg_arch="linux-x86_64";
openssl_build_arg_libraries_zlib="custom"; #system,custom,no
openssl_build_arg_options="";
openssl_build_arg_main_threads="yes";
openssl_build_arg_main_zlib="yes";
openssl_build_arg_main_nistp="yes";
openssl_build_arg_proto_tls1_3="yes";
openssl_build_arg_proto_tls1_2="yes";
openssl_build_arg_proto_tls1_1="yes";
openssl_build_arg_proto_tls1_0="yes";
openssl_build_arg_proto_ssl3="no";
openssl_build_arg_proto_ssl2="no";
openssl_build_arg_proto_dtls1_2="yes";
openssl_build_arg_proto_dtls1_0="yes";
openssl_build_arg_proto_npn="no";
openssl_build_arg_cypher_idea="yes";
openssl_build_arg_cypher_weak="no";

# - gd2 (version 1.11.6 - 2.2.x)
gd2_apt_flag="yes";
gd2_build_flag="yes";
gd2_build_cleanup="no";
gd2_build_make="yes";
gd2_build_install="yes";
gd2_build_test="yes";
gd2_build_version="2.2.5";
gd2_build_arg_arch="linux-x86_64";
gd2_build_arg_libraries_zlib="custom"; #system,custom,no
gd2_build_arg_libraries_png="system"; #system,custom,no
gd2_build_arg_libraries_jpeg="system"; #system,custom,no
gd2_build_arg_libraries_webp="system"; #system,custom,no
gd2_build_arg_libraries_tiff="system"; #system,custom,no
gd2_build_arg_libraries_xpm="system"; #system,custom,no
gd2_build_arg_libraries_liq="no"; #system,custom,no
gd2_build_arg_libraries_freetype="system"; #system,custom,no
gd2_build_arg_libraries_fontconfig="system"; #system,custom,no
gd2_build_arg_options="";

# - xml2 (version 2.6.27 - 2.9.x)
xml2_apt_flag="yes";
xml2_build_flag="yes";
xml2_build_cleanup="no";
xml2_build_make="yes";
xml2_build_install="yes";
xml2_build_test="yes";
xml2_build_version="2.9.9";
xml2_build_arg_arch="linux-x86_64";
xml2_build_arg_libraries_zlib="custom"; #system,custom,no
xml2_build_arg_libraries_lzma="system"; #system,custom,no
xml2_build_arg_libraries_readline="system"; #system,custom,no
xml2_build_arg_libraries_iconv="system"; #system,custom,no
xml2_build_arg_libraries_python="system"; #system,custom,no
xml2_build_arg_options="";
xml2_build_arg_main_threads="yes";
xml2_build_arg_main_threadalloc="yes";
xml2_build_arg_main_ipv6="yes";
xml2_build_arg_main_regexps="yes";
xml2_build_arg_main_dso="yes";
xml2_build_arg_encoding_iso8859x="yes";
xml2_build_arg_encoding_unicode="yes";
xml2_build_arg_xml_canonical="yes";
xml2_build_arg_xml_catalog="yes";
xml2_build_arg_xml_schemas="yes";
xml2_build_arg_xml_schematron="yes";
xml2_build_arg_sgml_docbook="yes";
xml2_build_arg_sgml_html="yes";
xml2_build_arg_sgml_treedom="yes";
xml2_build_arg_parser_pattern="yes";
xml2_build_arg_parser_push="yes";
xml2_build_arg_parser_reader="yes";
xml2_build_arg_parser_sax1="yes";
xml2_build_arg_api_legacy="yes";
xml2_build_arg_api_outputserial="yes";
xml2_build_arg_api_validdtd="yes";
xml2_build_arg_api_writer="yes";
xml2_build_arg_api_xinclude="yes";
xml2_build_arg_api_xpath="yes";
xml2_build_arg_api_xpointer="yes";
xml2_build_arg_proto_ftp="yes";
xml2_build_arg_proto_http="yes";
xml2_build_arg_tool_history="yes";

# - xslt (version 1.0.0 - 1.1.x)
xslt_apt_flag="yes";
xslt_build_flag="yes";
xslt_build_cleanup="no";
xslt_build_make="yes";
xslt_build_install="yes";
xslt_build_test="yes";
xslt_build_version="1.1.33";
xslt_build_arg_arch="linux-x86_64";
xslt_build_arg_libraries_xml2="custom"; #system,custom,no
xslt_build_arg_libraries_python="system"; #system,custom,no
xslt_build_arg_options="";
xslt_build_arg_main_crypto="yes";
xslt_build_arg_main_plugins="yes";

# - geoip (version 1.0.0 - 1.6.x)
geoip_apt_flag="yes";
geoip_build_flag="yes";
geoip_build_cleanup="no";
geoip_build_make="yes";
geoip_build_install="yes";
geoip_build_test="yes";
geoip_build_version="1.6.12";
geoip_build_arg_arch="linux-x86_64";
geoip_build_arg_options="";

# - nginx (version 1.4.7, 1.6.3, 1.8.1, 1.10.3, 1.12.2, 1.14.2, 1.16.1 (stable), 1.17.4)
nginx_build_flag="yes";
nginx_build_cleanup="no";
nginx_build_make="yes";
nginx_build_install="yes";
nginx_build_install_etc="system"; #system,build,no
nginx_build_test="yes";
nginx_build_version="1.16.1";
nginx_build_arg_arch="linux-x86_64";
nginx_build_arg_libraries_zlib="system"; #system,custom (set to custom with gcc -static or when recompiling via nginx makefile)
nginx_build_arg_libraries_pcre="system"; #system,custom (set to custom with gcc -static or when recompiling via nginx makefile)
nginx_build_arg_libraries_openssl="system"; #system,custom (set to custom with gcc -static or when recompiling via nginx makefile)
nginx_build_arg_libraries_libatomic="system"; #system,custom (set to custom with gcc -static or when recompiling via nginx makefile)
nginx_build_arg_options="";
# - nginx - compiler
nginx_build_arg_compiler_flag="yes";
nginx_build_arg_compiler_L_I="custom"; #custom,no
nginx_build_arg_compiler_cc="-Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS -fexceptions -fasynchronous-unwind-tables -D FD_SETSIZE=8192 -O2"; #-Wdate-time -fPIE -fstack-protector-strong -static -static-libgcc
nginx_build_arg_compiler_ld="-Wl,--as-needed -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now"; #-fPIE -pie -static
# - nginx - main config
nginx_build_arg_main_debug_flag="no";
nginx_build_arg_main_threads_flag="yes";
nginx_build_arg_main_fileaio_flag="yes";
nginx_build_arg_main_compat_flag="yes";
nginx_build_arg_main_ipv6_flag="no"; #deprecated since 1.11.5
nginx_build_arg_main_distro="Ubuntu";
nginx_build_arg_main_user="www-data";
nginx_build_arg_main_group="www-data";
# - nginx - modules - connection
nginx_build_arg_module_poll_flag="auto"; #auto,yes,no
nginx_build_arg_module_select_flag="auto"; #auto,yes,no
# - nginx - modules - http
nginx_build_arg_modules_http_flag="yes";
# - nginx - modules - http - protocol
nginx_build_arg_modules_http_http2_flag="yes";
nginx_build_arg_modules_http_spdy_flag="no"; #deprecated since 1.9.5
nginx_build_arg_modules_http_ssl_flag="yes";
nginx_build_arg_modules_http_webdav_flag="yes";
# - nginx - modules - http - core
nginx_build_arg_modules_http_rewrite_flag="yes";
nginx_build_arg_modules_http_map_flag="yes";
nginx_build_arg_modules_http_browser_flag="yes";
nginx_build_arg_modules_http_userid_flag="yes";
# - nginx - modules - http - index
nginx_build_arg_modules_http_autoindex_flag="yes";
nginx_build_arg_modules_http_randomindex_flag="yes";
# - nginx - modules - http - access/limit
nginx_build_arg_modules_http_access_flag="yes";
nginx_build_arg_modules_http_limitconn_flag="yes";
nginx_build_arg_modules_http_limitreq_flag="yes";
# - nginx - modules - http - auth
nginx_build_arg_modules_http_authbasic_flag="yes";
nginx_build_arg_modules_http_authrequest_flag="yes";
# - nginx - modules - http - security
nginx_build_arg_modules_http_referer_flag="yes";
nginx_build_arg_modules_http_securelink_flag="yes";
# - nginx - modules - http - location
nginx_build_arg_modules_http_realip_flag="yes";
nginx_build_arg_modules_http_geo_flag="yes";
nginx_build_arg_modules_http_geoip_flag="yes"; #yes,dso,no
# - nginx - modules - http - encoding
nginx_build_arg_modules_http_gzip_flag="yes";
nginx_build_arg_modules_http_gunzip_flag="yes";
nginx_build_arg_modules_http_charset_flag="yes";
# - nginx - modules - http - filter
nginx_build_arg_modules_http_emptygif_flag="yes";
nginx_build_arg_modules_http_imagefilter_flag="yes"; #yes,dso,no (disable with -static)
nginx_build_arg_modules_http_xslt_flag="yes"; #yes,dso,no (disable with -static)
nginx_build_arg_modules_http_sub_flag="yes";
nginx_build_arg_modules_http_addition_flag="yes";
nginx_build_arg_modules_http_slice_flag="yes";
# - nginx - modules - http - stream
nginx_build_arg_modules_http_mp4_flag="yes";
nginx_build_arg_modules_http_flv_flag="yes";
# - nginx - modules - http - upstream
nginx_build_arg_modules_http_upstream_keepalive_flag="yes";
nginx_build_arg_modules_http_upstream_leastconn_flag="yes";
nginx_build_arg_modules_http_upstream_random_flag="yes";
nginx_build_arg_modules_http_upstream_hash_flag="yes";
nginx_build_arg_modules_http_upstream_iphash_flag="yes";
nginx_build_arg_modules_http_upstream_zone_flag="yes";
# - nginx - modules - http - proxy/cgi
nginx_build_arg_modules_http_proxy_flag="yes";
nginx_build_arg_modules_http_fastcgi_flag="yes";
nginx_build_arg_modules_http_scgi_flag="yes";
nginx_build_arg_modules_http_uwsgi_flag="yes";
nginx_build_arg_modules_http_grpc_flag="yes";
# - nginx - modules - http - script
nginx_build_arg_modules_http_ssi_flag="yes";
nginx_build_arg_modules_http_perl_flag="no"; #yes,dso,no
# - nginx - modules - http - cache
nginx_build_arg_modules_http_cache_flag="yes";
nginx_build_arg_modules_http_memcached_flag="yes";
# - nginx - modules - http - other
nginx_build_arg_modules_http_mirror_flag="yes";
nginx_build_arg_modules_http_splitclients_flag="yes";
nginx_build_arg_modules_http_stub_flag="yes";
# - nginx - modules - stream
nginx_build_arg_modules_stream_flag="yes"; #yes,dso,no
# - nginx - modules - stream - protocol
nginx_build_arg_modules_stream_ssl_flag="yes";
nginx_build_arg_modules_stream_ssl_preread_flag="yes";
# - nginx - modules - stream - core
nginx_build_arg_modules_stream_map_flag="yes";
# - nginx - modules - stream - access/limit
nginx_build_arg_modules_stream_access_flag="yes";
nginx_build_arg_modules_stream_limitconn_flag="yes";
# - nginx - modules - steam - location
nginx_build_arg_modules_stream_realip_flag="yes";
nginx_build_arg_modules_stream_geo_flag="yes";
nginx_build_arg_modules_stream_geoip_flag="yes"; #yes,dso,no
# - nginx - modules - stream - upstream
nginx_build_arg_modules_stream_upstream_leastconn_flag="yes";
nginx_build_arg_modules_stream_upstream_random_flag="yes";
nginx_build_arg_modules_stream_upstream_hash_flag="yes";
nginx_build_arg_modules_stream_upstream_zone_flag="yes";
# - nginx - modules - stream - other
nginx_build_arg_modules_stream_return_flag="yes";
nginx_build_arg_modules_stream_splitclients_flag="yes";
# - nginx - modules - mail
nginx_build_arg_modules_mail_flag="yes"; #yes,dso,no
# - nginx - modules - mail - protocol
nginx_build_arg_modules_mail_ssl_flag="yes";
nginx_build_arg_modules_mail_smtp_flag="yes";
nginx_build_arg_modules_mail_pop3_flag="yes";
nginx_build_arg_modules_mail_imap_flag="yes";
# - nginx - modules - other
nginx_build_arg_modules_other_flag="yes";
nginx_build_arg_modules_other_cpptest_flag="no";
nginx_build_arg_modules_other_googleperftools_flag="no";
