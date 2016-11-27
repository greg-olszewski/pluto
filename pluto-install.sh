#!/bin/bash
# Pluto Contol Panel installation script
# website: http://plutocp.xyz
#
# Currently Supported Operating Systems:
#   * Debian 7
#   * Ubuntu LTS, Ubuntu 13.04, Ubuntu 13.10
#

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

distro=head -n 1 /etc/issue | cut -f 1 -d ' ';

# OS detection
case $distro in
    Debian)     type="debian" ;;
    Ubuntu)     type="ubuntu" ;;
    *)          type="rhel" ;;
esac

# Download
if [ -e '/usr/bin/wget' ]; then
    wget http://plutocp.xyz/install/plto-install-$type.sh -O pluto-install-$type.sh
    if [ "$?" -eq '0' ]; then #if exit code equal to 0, execute
        bash vst-install-$type.sh $*
        exit
    else
        echo "[Error] pluto-install-$type.sh download failure"
        exit 1
    fi
fi

exit