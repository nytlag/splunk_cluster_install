#!/bin/bash

# VERSION 102
# 1/17/18
# 3/22/2018 -- added arr_hosts array

# copies these files onto remote hosts
# 1.  mylibrary1.sh - this will have the libraries and functions
# 2.  tinist.sh   ---> this file will do the splunk installation
# 3.  license_file
# 4.  *.tar install file
#
# runs test.sh script. It will cretae myinstall directory.
# It will scp copy 2 sh files and tar file into this directory
# mylibrary1.sh, tinist.sh
#

#======================= declare section ============
# declare all hosts in the enviornment
declare -a arr_hosts=(
"host_server01.xxxxx"
"host_server02.xxxxx"
"host_server03.xxxxx"
"host_server04.xxxxx"
"host_server05.xxxxx"
"host_server06.xxxxx"

)

install_file="splunk-7.0.3-fa31da744b51-Linux-x86_64.tgz"
#install_file="splunk-7.1.1-8f0ead9ec3db-Linux-x86_64.tgz"
license_file="Splunk_Enterprise_NFR_Q2FY19.lic"

DEST_DIR="/opt"
OS_user="root"
#-----------------------------------------------
#================================================
. ~/mylibs/libinst.sh

#enable_debugging

#declare_hosts_arr function will copy files onto /opt/* directory and remove 
#existing splunk installation if any at the destination host

declare_hosts_arr "${arr_hosts[@]}"

#disable_debugging
