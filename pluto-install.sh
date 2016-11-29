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

# Check if wget is available
if [ ! -e '/usr/bin/wget' ]; then
    apt-get -y install wget
    if [ $? -eq 0 ]; then
        echo "Installed wget"
    else
        echo "[ERROR] Error installing wget"
    fi
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
    wget http://plutocp.xyz/install/plto-install-$type.tar.gz -O pluto-install-$type.sh
    if [ "$?" -eq '0' ]; then #if exit code equal to 0, execute
        bash vst-install-$type.sh $*
        exit
    else
        echo "[Error] pluto-install-$type.tar.gz download failure"
        exit 1
    fi
fi

tar xvzf pluto-install-$type.tar.gz

cd pluto-install-$type && exec /bin/bash install-$typr.sh

exit