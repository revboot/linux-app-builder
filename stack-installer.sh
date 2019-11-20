#!/bin/bash
#title        :stack-installer.sh
#description  :Stack Installer: Installs applications from packages or source.
#author       :lpalgarvio <"lp.algarvio@gmail.com">
#date         :20191117
#version      :0.x
#usage        :bash stack-installer.sh [options]
#notes        :Setup configuration with config/config.local.sh based on config.sample.sh.
#bash_version :4.2
#
# https://www.nginx.com/resources/wiki/start/topics/tutorials/installoptions/
# https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#sources
# https://www.vultr.com/docs/how-to-compile-nginx-from-source-on-ubuntu-16-04
# https://github.com/dimitrijp/Organizr-Nginx/wiki/Build-Nginx-from-source-with-GeoIP-module
# https://gist.github.com/rjeczalik/7057434
# https://gist.github.com/sergeifilippov/ef6c5ad43b3a2167211acd0cf3176fd5
# https://gist.github.com/pothi/a95ed8b1d089e5d87268
#
# https://wiki.openssl.org/index.php/Compilation_and_Installation
# https://geeksww.com/tutorials/libraries/libxslt/installation/installing_libxslt_on_ubuntu_linux.php
# https://dev.maxmind.com/geoip/geoip2/geolite2/
# https://stackoverflow.com/questions/54097838/geoip-dat-gz-and-geolitecity-dat-gz-not-longer-available-getting-404-trying-to
#
# https://stackoverflow.com/questions/11824772/compile-nginx-with-existing-pcre
# https://stackoverflow.com/questions/8835108/how-to-specify-non-default-shared-library-path-in-gcc-linux-getting-error-whil
# https://superuser.com/questions/690306/find-out-library-version
# https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc/
# http://www.linuxfromscratch.org/hints/downloads/files/ssp.txt
# https://stackoverflow.com/questions/8692128/static-option-for-gcc
# https://www.akkadia.org/drepper/dsohowto.pdf
# https://bytefreaks.net/gnulinux/bash/bash-get-script-file-name-and-location
# https://stackoverflow.com/questions/7868818/in-bash-is-there-an-equivalent-of-die-error-msg
# https://stackoverflow.com/questions/16203088/bash-if-statement-with-multiple-conditions-throws-an-error
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# https://bash.cyberciti.biz/guide/The_case_statement
#

#
## Auxiliary functions
#

# Interrupts script execution
die() {
  exit $1;
}

# Prints error and die()
error() {
  echo "$SCRIPT_NAME($1):" "error: $2" >&2;
  die $1;
}

# Prints warning
warn() {
  echo "$SCRIPT_NAME($1):" "warning: $2" >&2;
}

# Prints message
notify() {
  if [ $1 == "startTask" ]; then
    printf "\nStarting task:$2\n";
  elif [ $1 == "stopTask" ]; then
    printf "\nFinishing task:$2\n\n";
  elif [ $1 == "skipTask" ]; then
    printf "\nSkipping task:$2\n\n";
  elif [ $1 == "startSubTask" ]; then
    printf "\n- Starting subtask:$2\n";
  elif [ $1 == "stopSubTask" ]; then
    printf "\n- Finishing subtask:$2\n";
  elif [ $1 == "skipSubTask" ]; then
    printf "\n- Skipping subtask:$2\n";
  elif [ $1 == "startRoutine" ]; then
    printf "\n-- Starting routine:$2\n\n";
  elif [ $1 == "stopRoutine" ]; then
    printf "\n-- Finishing routine:$2\n";
  elif [ $1 == "skipRoutine" ]; then
    printf "\n-- Skipping routine:$2\n";
  elif [ $1 == "warnRoutine" ]; then
    printf "\n-- Warning on routine:$2\n";
  elif [ $1 == "errorRoutine" ]; then
    printf "\n-- Error on routine:$2\n";
    die 1;
  fi;
}

# Loads source file
loadSource() {
  if [ -f "$SCRIPT_DIR/$1" ]; then
    source "$SCRIPT_DIR/$1";
  else
    msg="could not find source ${SCRIPT_DIR}/$1";
    if [ "$2" = false ]; then warn 0 "$msg"; else error 1 "$msg"; fi;
  fi;
}

#
# Initialization
#

# Get paths
SCRIPT_NAME=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
SCRIPT_DIR=$(cd $(dirname "$0") && pwd);

# Set environment
#LD_LIBRARY_PATH=/usr/local/lib;
#export LD_LIBRARY_PATH;

# Retrieve operating system info from lsb
if [ -f /etc/lsb-release ] ; then
  source /etc/lsb-release;
fi;

# Validate operating system
case "$DISTRIB_RELEASE" in
  "12.04"|"14.04"|"16.04"|"18.04")
    echo -e "$DISTRIB_DESCRIPTION ($DISTRIB_CODENAME) is a supported operating system.";
    ;;
  *)
    error 1 "Unsupported operating system";
    ;;
esac;

# Get CLI arguments
declare -g opts='';
opts=`getopt --options "u,h" --longoptions "usage,help,task:,subtask:,routine:" -- "$@"`;

# Validate CLI arguments
[ $? -eq 0 ] || {
  error 1 "Incorrect options provided";
}

# Store CLI arguments
eval set -- "$opts";
while true; do
  case "$1" in
    # Option `usage`
    -u|--usage )
      echo -e "Usage: `basename $0` [options]";
      exit 1;
      ;;
    # Option `help`
    -h|--help )
      echo -e "Usage: `basename $0` [options]";
      echo -e "";
      echo -e "Options:";
      echo -e "  -u, --usage                 show the quick usage message";
      echo -e "  -h, --help                  show this long help message";
      echo -e "  --task={task}               selects the task for operations (defaults to config)";
      echo -e "  --subtask={subtask}         selects the subtask for operations (defaults to config)";
      echo -e "  --routine={routine}         selects the routine for operations (defaults to config)";
      echo -e "";
      echo -e "Tasks:";
      echo -e "  - config                    selects configured tasks (default)";
      echo -e "  - all                       selects all tasks";
      echo -e "  Misc";
      echo -e "   - global                   selects the global misc script";
      echo -e "  Library";
      echo -e "   - zlib                     selects the Zlib/libz library";
      echo -e "   - pcre                     selects the PCRE/libpcre library";
      echo -e "   - openssl                  selects the OpenSSL/libssl library";
      echo -e "   - gd2                      selects the GD2/libgd2 library";
      echo -e "   - xml2                     selects the XML2/libxml2 library";
      echo -e "   - xslt                     selects the XSLT/libxslt library";
      echo -e "   - geoip                    selects the GeoIP/libgeoip library";
      echo -e "  Application";
      echo -e "   - nginx                    selects the Nginx application";
      echo -e "";
      echo -e "Subtasks:";
      echo -e "  - config                    selects configured subtasks (default)";
      echo -e "  - all                       selects all subtasks";
      echo -e "  - package                   selects the package subtask";
      echo -e "  - source                    selects the source subtask";
      echo -e "";
      echo -e "Routines:";
      echo -e "  - config                    selects configured routines (default)";
      echo -e "  - all                       selects all routines";
      echo -e "  - cleanup                   selects the cleanup routine";
      echo -e "  - download                  selects the download routine";
      echo -e "  - make                      selects the make routine";
      echo -e "  - install                   selects the install routine";
      echo -e "  - etc                       selects the etc routine";
      echo -e "  - test                      selects the test routine";
      exit 1;
      ;;
    # Option `task`
    --task )
      shift; # The arg is next in position args
      args_task=$1
      [[ ! $args_task =~ config|all|global|zlib|pcre|openssl|gd2|xml2|xslt|geoip|nginx ]] && {
        error 1 "Incorrect task options provided";
      }
      ;;
    # Option `subtask`
    --subtask )
      shift; # The arg is next in position args
      args_subtask=$1
      [[ ! $args_subtask =~ config|all|package|source ]] && {
        error 1 "Incorrect subtask options provided";
      }
      ;;
    # Option `routine`
    --routine )
      shift; # The arg is next in position args
      args_routine=$1
      [[ ! $args_routine =~ config|all|cleanup|download|make|install|etc|test ]] && {
        error 1 "Incorrect routine options provided";
      }
      ;;
    --)
      shift;
      break;
      ;;
  esac;
  shift;
done;

# Set sane defaults if CLI arguments missing
if [ -z "$args_task" ]; then
  args_task="config";
fi;
if [ -z "$args_subtask" ]; then
  args_subtask="config";
fi;
if [ -z "$args_routine" ]; then
  args_routine="config";
fi;

#
# Load configuration
#

# Load default config
loadSource "config/config.default.inc" true;
# Load local config
loadSource "config/config.local.inc" false;

#
# Load tasks
#

# task: misc: global
loadSource "tasks/misc/global.sh" true;
# task: library: zlib
loadSource "tasks/libs/zlib.sh" true;
# task: library: pcre
loadSource "tasks/libs/pcre.sh" true;
# task: library: openssl
loadSource "tasks/libs/openssl.sh" true;
# task: library: gd2
loadSource "tasks/libs/gd2.sh" true;
# task: library: xml2
loadSource "tasks/libs/xml2.sh" true;
# task: library: xslt
loadSource "tasks/libs/xslt.sh" true;
# task: library: geoip
loadSource "tasks/libs/geoip.sh" true;
# task: application: nginx
loadSource "tasks/apps/nginx.sh" true;

#
# Main program
#

# Build dependencies
if [ "$global_source_flag" == "yes" ]; then

  # task: misc: global
  if ([ "$global_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "global" ]; then
    notify "startTask" "misc:global";
    task_misc_global;
    notify "stopTask" "misc:global";
  else
    notify "skipTask" "misc:global";
  fi;

  # task: library: zlib
  if ([ "$zlib_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "zlib" ]; then
    notify "startTask" "lib:zlib";
    task_lib_zlib;
    notify "stopTask" "lib:zlib";
  else
    notify "skipTask" "lib:zlib";
  fi;

  # task: library: pcre
  if ([ "$pcre_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "pcre" ]; then
    notify "startTask" "lib:pcre";
    task_lib_pcre;
    notify "stopTask" "lib:pcre";
  else
    notify "skipTask" "lib:pcre";
  fi;

  # task: library: openssl
  if ([ "$openssl_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "openssl" ]; then
    notify "startTask" "lib:openssl";
    task_lib_openssl;
    notify "stopTask" "lib:openssl";
  else
    notify "skipTask" "lib:openssl";
  fi;

  # task: library: gd2
  if ([ "$gd2_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "gd2" ]; then
    notify "startTask" "lib:gd2";
    task_lib_gd2;
    notify "stopTask" "lib:gd2";
  else
    notify "skipTask" "lib:gd2";
  fi;

  # task: library: xml2
  if ([ "$xml2_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "xml2" ]; then
    notify "startTask" "lib:xml2";
    task_lib_xml2;
    notify "stopTask" "lib:xml2";
  else
    notify "skipTask" "lib:xml2";
  fi;

  # task: library: xslt
  if ([ "$xslt_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "xslt" ]; then
    notify "startTask" "lib:xslt";
    task_lib_xslt;
    notify "stopTask" "lib:xslt";
  else
    notify "skipTask" "lib:xslt";
  fi;

  # task: library: geoip
  if ([ "$geoip_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "geoip" ]; then
    notify "startTask" "lib:geoip";
    task_lib_geoip;
    notify "stopTask" "lib:geoip";
  else
    notify "skipTask" "lib:geoip";
  fi;

  # task: application: nginx
  if ([ "$nginx_task" == "yes" ] && [ "$args_task" == "config" ]) || [ "$args_task" == "all" ] || [ "$args_task" == "nginx" ]; then
    notify "startTask" "app:nginx";
    task_app_nginx;
    notify "stopTask" "app:nginx";
  else
    notify "skipTask" "app:nginx";
  fi;

fi;

# Terminate script
notify "Terminating...";
die 0;
