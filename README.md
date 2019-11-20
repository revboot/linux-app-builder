# Stack Installer
Installs web applications and libraries from either packages or sources, with flexible usage of cleanup, download, make, install, config and test routines, command line arguments and customizable configuration.

[![Build Status](https://travis-ci.com/revboot/stack-installer.svg?branch=master)](https://travis-ci.com/revboot/stack-installer)

## Supported Applications and Libraries
The following applications and libraries can be installed via packages or sources:
- Applications:
  - [Nginx](https://nginx.org), sources: [www.nginx.org](https://www.nginx.org/en/download.html)*, [trac.nginx.org](http://trac.nginx.org/nginx/browser), [github.com](https://github.com/nginx/nginx)
- Libraries:
  - [Zlib/libz](https://www.zlib.net), sources: [www.zlib.net/tarball](https://www.zlib.net/zlib-1.2.11.tar.gz), [github.com](https://github.com/madler/zlib)*
  - [PCRE/libpcre](https://www.pcre.org), sources: [ftp.pcre.org](https://ftp.pcre.org/pub/pcre)*, [vcs.pcre.org](https://vcs.pcre.org/pcre2)
  - [OpenSSL/libssl](https://www.openssl.org), sources: [www.openssl.org](https://www.openssl.org/source)*, [git.openssl.org](https://git.openssl.org/?p=openssl.git), [github.com](https://github.com/openssl/openssl)
  - [GD2/libgd2](https://libgd.github.io), sources: [libgd.github.io](https://libgd.github.io/pages/downloads.html), [github.com](https://github.com/libgd/libgd)*
  - [XML2/libxml2](http://xmlsoft.org), sources: [www.xmlsoft.org](http://www.xmlsoft.org/downloads.html), [gitlab.gnome.org](https://gitlab.gnome.org/GNOME/libxml2)*, [github.com](https://github.com/GNOME/libxml2)
  - [XSLT/libxslt](http://xmlsoft.org/XSLT), sources: [www.xmlsoft.org](http://www.xmlsoft.org/XSLT/downloads.html), [gitlab.gnome.org](https://gitlab.gnome.org/GNOME/libxslt)*, [github.com](https://github.com/GNOME/libxslt)
  - [GeoIP/libgeoip](https://dev.maxmind.com/geoip/legacy), sources: [dev.maxmind.com](https://dev.maxmind.com/geoip/legacy/downloadable), [github.com](https://github.com/maxmind/geoip-api-c)*

## Supported Operating Systems
The following operating systems are supported:
- Ubuntu LTS family
  - Ubuntu [18.04 (bionic)](http://releases.ubuntu.com/18.04)
  - Ubuntu [16.04 (xenial)](http://releases.ubuntu.com/16.04)
  - Ubuntu [14.04 (trusty)](http://releases.ubuntu.com/14.04)
  - Ubuntu [12.04 (precise)](http://releases.ubuntu.com/12.04)

## Usage

### Command options

```
Usage: stack-installer.sh [options]

Options:
  -u, --usage                 show the quick usage message
  -h, --help                  show this long help message
  --task={task}               selects the task for operations (defaults to config)
  --subtask={subtask}         selects the subtask for operations (defaults to config)
  --routine={routine}         selects the routine for operations (defaults to config)

Tasks:
  - config                    selects configured tasks (default)
  - all                       selects all tasks
  Misc
   - global                   selects the global misc script
  Library
   - zlib                     selects the Zlib/libz library
   - pcre                     selects the PCRE/libpcre library
   - openssl                  selects the OpenSSL/libssl library
   - gd2                      selects the GD2/libgd2 library
   - xml2                     selects the XML2/libxml2 library
   - xslt                     selects the XSLT/libxslt library
   - geoip                    selects the GeoIP/libgeoip library
  Application
   - nginx                    selects the Nginx application

Subtasks:
  - config                    selects configured subtasks (default)
  - all                       selects all subtasks
  - package                   selects the package subtask
  - source                    selects the source subtask

Routines:
  - config                    selects configured routines (default)
  - all                       selects all routines
  - cleanup                   selects the cleanup routine
  - download                  selects the download routine
  - make                      selects the make routine
  - install                   selects the install routine
  - uninstall                 selects the uninstall routine (never runs with all)
  - etc                       selects the etc routine
  - test                      selects the test routine
```

If not specified, the script will select `config` for task, subtask and routine, therefore using configuration files.  
Local configuration (`./config/config.local.inc`) file overrides Default configuration (`./config/config.default.inc`) file.  
Use Sample configuration (`./config/config.sample.inc`) file to create a Local configuration file.

If `all` is specified for task, subtask and routine, then all corresponding items will be selected when running the script.

### Examples

1. Run the configured operations for the configured applications and libraries  
`./stack-installer.sh`  
or  
`./stack-installer.sh --task=config --subtask=config --routine=config`

2. Run all operations for all applications and libraries  
`./stack-installer.sh --task=all --subtask=all --routine=all`

3. Run all operations for all applications and libraries, but use packages  
`./stack-installer.sh --task=all --subtask=package --routine=all`

4. Run all operations for all applications and libraries, but use sources  
`./stack-installer.sh --task=all --subtask=source --routine=all`

5. Test all applications and libraries, with packages and sources  
`./stack-installer.sh --task=all --subtask=all --routine=test`

6. Run all operations for nginx, with sources, in one statement  
`./stack-installer.sh --task=nginx --subtask=source --routine=all`

7. Run all operations for nginx, with sources, separately  
```
./stack-installer.sh --task=nginx --subtask=source --routine=cleanup
./stack-installer.sh --task=nginx --subtask=source --routine=download
./stack-installer.sh --task=nginx --subtask=source --routine=make
./stack-installer.sh --task=nginx --subtask=source --routine=install
./stack-installer.sh --task=nginx --subtask=source --routine=test
```

8. Run uninstall operation for nginx, with sources  
`./stack-installer.sh --task=nginx --subtask=source --routine=uninstall`

9. Cleanup all applications and libraries, but only remove source and tarballs  
`./stack-installer.sh --task=all --subtask=source --routine=cleanup`

10. Cleanup all applications and libraries, including source, tarballs and installed binaries  
`./stack-installer.sh --task=misc --subtask=global --routine=cleanup`

## Credits
Stack Installer  
Copyright (C) 2019 Revboot - Tecnologias de Informação e Comunicação, Lda.  
Luís Pedro Algarvio  

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
