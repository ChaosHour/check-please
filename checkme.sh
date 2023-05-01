#! /usr/bin/env zsh
#
#set -xv
#set -o errexit
#set -o nounset
set -o pipefail
###############################################################################################
# Purpose: This script is used to check for rootkits and other malware plus viruses.
# Created by: Kurt Larsen
# Date: 2023-04-26
# Version: 1.0
#
# Usage: ./checkme.sh or ./checkme.sh -h for homedir or ./checkme.sh -s for full system scan
#
###############################################################################################



# Set constants - Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"


# You must use sudo to run this script
#if [ $EUID -ne 0 ]; then
#    echo -e "$COL_YELLOW Use sudo to run this script $COL_RED [-] $COL_RESET"
#    exit 1
#fi

# Variables

# get the homedir path for the sudo user running the script
#homedir=$(eval echo ~$SUDO_USER)

# get the homedir path for the user running the script
homedir=$(eval echo ~$USER)

# test if tmp directory exists
if [ ! -d "${homedir}/tmp" ]; then
    # create tmp directory if it does not exist and let the user know
    echo -e "$COL_YELLOW Creating tmp directory -> ${homedir}/tmp $COL_GREEN [+] $COL_RESET"
       mkdir "${homedir}/tmp"
fi

# add a variable SUSPSCAN_TEMP to export
export SUSPSCAN_TEMP=${homedir}/tmp


# Functions
# Check for rootkits
fCheck()  {
    if sudo find /lib* -type f -name libkeyutils.so* -exec ls -lrtha {} \;
    then
        echo -e "$COL_YELLOW Result filesize should be less then 15KB $COL_RED [-] $COL_RESET"
    else
        echo -e "$COL_YELLOW Result filesize is less then 15KB $COL_GREEN  [+] $COL_RESET"
    fi

    if sudo find /lib* -type f -name libproc.so* -exec ls -lrtha {} \;
    then
        echo -e "$COL_YELLOW Result filesize should be less then 15KB $COL_RED [-] $COL_RESET"
    else
        echo -e "$COL_YELLOW Result filesize is less then 15KB $COL_GREEN [+] $COL_RESET"
    fi
    
}
# Check for rootkits
fCheck2() {
    if sudo find /lib* -type f -name libns2.so
    then
        echo -e "$COL_YELLOW Result should return null $COL_RED [-] $COL_RESET"
    else
        echo -e "$COL_YELLOW Result should return null $COL_GREEN [+] $COL_RESET"
    fi

    if sudo netstat -nap | grep "@/proc/udevd"
    then
        echo -e "$COL_YELLOW Result should return null $COL_RED [-] $COL_RESET"
    else
        echo -e "$COL_YELLOW Result should return null $COL_GREEN [+] $COL_RESET"
    fi
}

# Check for compromised sshd
sCheck() {
echo -e "$COL_YELLOW Checking for compromised sshd $COL_GREEN [+] $COL_RESET"
   ssh -H 2>&1 | grep -e illegal -e unknown > /dev/null && echo "System clean" || echo "System infected"

echo -e "$COL_YELLOW Checking hash on /usr/sbin/tcpd $COL_GREEN [+] $COL_RESET"
   sudo find / -name tcpd -ls 2>&1 | grep -iv 'Permission denied'

   sudo echo "cd9cfc19df7f0e4b7f9adfa4fe8c5d74caa53d86 /usr/sbin/tcpd" | shasum -a 1 -

}

# Check for rootkits
rKits() {
echo -e "$COL_YELLOW Running chkrootkit$COL_GREEN [+] $COL_RESET"
   sudo chkrootkit -x 2>&1 | grep -Ei 'infected|not infected' | grep -v grep

echo -e "$COL_YELLOW Running rkhunter $COL_GREEN [+] $COL_RESET"
   sudo su - root -c '/usr/local/bin/rkhunter --update'
   sudo su - root -c '/usr/local/bin/rkhunter --propupd'
   sudo su - root -c '/usr/local/bin/rkhunter -c --enable all --disable none --rwo'
}
# Check for rootkits
dChecks() {
echo -e "$COL_YELLOW Running unhide $COL_GREEN [+] $COL_RESET"
   sudo unhide -f sys -r
   sudo unhide-tcp
   sudo unhide brute

echo -e "$COL_YELLOW Verifying installed packages using debsums $COL_GREEN [+] $COL_RESET"
   sudo dpkg-query -S $(sudo debsums -c 2>&1 | sed -e "s/.*file \(.*\) (.*/\1/g") | cut -d: -f1 | sort -u
}

# Run Lynis scan on MacOs
lCheck() {
echo -e "$COL_YELLOW Running a lynis audit scan $COL_GREEN [+] $COL_RESET"
   lynis audit system --quick | grep -iE 'malware|clamav|rootkit|chkrootkit|rkhunter'
}

# Run Lynis scan on Ubuntu
lCheck2() {
echo -e "$COL_YELLOW Running a lynis audit scan $COL_GREEN [+] $COL_RESET"
  sudo lynis audit system --quick | grep -iE 'malware|clamav|rootkit|chkrootkit|rkhunter|unhide|debsums'
}



# Define the function to scan the system for MacOS:
scan_system () {
  # Code to scan the entire system
  echo -e "$COL_YELLOW updating clamav virus defs $COL_GREEN [+] $COL_RESET"
           freshclam -v
  echo -e "$COL_YELLOW Running full system scan with clamav $COL_GREEN [+] $COL_RESET"
           clamscan -i -r --recursive=yes --scan-mail=yes --scan-pdf=yes --scan-html=yes --scan-archive=yes --phishing-scan-urls=yes --exclude-dir=infected --move="${homedir}/infected" /
       
}

# Define the function to scan the homedir for MacOS:
scan_homedir () {
  # Code to scan only the homedir
  echo -e "$COL_YELLOW updating clamav virus defs $COL_GREEN [+] $COL_RESET"
           freshclam -v
  echo -e "$COL_YELLOW Running clamscan on homedir $COL_GREEN [+] $COL_RESET"
           clamscan -i -r --recursive=yes --scan-mail=yes --scan-pdf=yes --scan-html=yes --scan-archive=yes --phishing-scan-urls=yes --exclude-dir=infected --move="${homedir}/infected" ${homedir}
  
}


# Define the function to scan the system for Linux:
scan_system2 () {
  # Code to scan the entire system
  echo -e "$COL_YELLOW updating clamav virus defs $COL_GREEN [+] $COL_RESET"
           sudo freshclam -v
  echo -e "$COL_YELLOW Running full system scan with clamav $COL_GREEN [+] $COL_RESET"
           sudo clamscan -i -r --recursive=yes --scan-mail=yes --scan-pdf=yes --scan-html=yes --scan-archive=yes --phishing-scan-urls=yes --exclude-dir=infected --move="${homedir}/infected" /
       
}

# Define the function to scan the homedir for Linux:
scan_homedir2 () {
  # Code to scan only the homedir
  echo -e "$COL_YELLOW updating clamav virus defs $COL_GREEN [+] $COL_RESET"
          sudo  freshclam -v
  echo -e "$COL_YELLOW Running clamscan on homedir $COL_GREEN [+] $COL_RESET"
           sudo clamscan -i -r --recursive=yes --scan-mail=yes --scan-pdf=yes --scan-html=yes --scan-archive=yes --phishing-scan-urls=yes --exclude-dir=infected --move="${homedir}/infected" ${homedir}
  
}


# Check for OS type
if [[ "$OSTYPE" == darwin* ]]; then
  # code for MacOs
  #fCheck
  rKits
  lCheck
else
  if [[ "$OSTYPE" == linux-gnu ]]; then
    # code for Debian
    fCheck
    fCheck2
    sCheck
    rKits
    dChecks
    lCheck2     
  fi
fi



# Create the case switch based on the command line arguments
case $1 in
    -s)
        if [[ "$OSTYPE" == linux-gnu ]]; then
           scan_system2
        elif [[ "$OSTYPE" == darwin* ]]; then
           scan_system
        else
           echo -e "$COL_RED "Unsupported OS: $os" $COL_RESET"
        fi
        ;;
     -h)
        if [[ "$OSTYPE" == linux-gnu ]]; then
           scan_homedir2
        elif [[ "$OSTYPE" == darwin* ]]; then
           scan_homedir
        else
           echo -e "$COL_RED "Unsupported OS: $os" $COL_RESET"
        fi
        ;;
      *)
           echo -e "$COL_YELLOW Usage: $0 -h for homedir clamscan or $0 -s for full system clamscan $COL_RESET"
        ;;
esac

exit 1