# Developed by Rousdem Djoraev
# 02/02/2018
# This file will do stand alone Splunk installation
# set login name to admin/admin
# set the license
#
# before starting instalation, set the following:
# 1. Copy tinst.sh and mylibrary1.sh files into /opt/ directory
# 2. set license path in tinst.sh file
# LICENSEPATH="/opt/license/Splunk_Enterprise_NFR_Q1FY19.lic"
# 3. copy installation *.tar file onto /opt/ directory.
# and then set fname=<tar file name>
# if you don't have *.tar file, then you can use curl command:
# e.g.  curl -O http://download.splunk.com/products/splunk/releases/<build number>/splunk/linux/<tar file name>
#  curl -O http://download.splunk.com/products/splunk/releases/6.6.3/splunk/linux/splunk-6.6.3-e21ee54bc796-Linux-x86_64.tgz
#
#!/bin/bash

shopt -s expand_aliases

cd /opt

#. ./mylibrary1.sh
. /opt/mylibrary1.sh

trap trap_ctrlc SIGINT

VERSION=101
LICENSEPATH="/opt/Splunk_Enterprise_NFR_Q2FY19.lic"
SPL_DIR="splunk"
DEST_DIR="/opt/splunk"
#---- splunk admin password
ADMIN_USER="admin"
ADMIN_PSWD="admin"
#ADMIN_PSWD="administrator" # use this for 7.1.x installs. it has password requirments

fname="splunk-7.0.3-fa31da744b51-Linux-x86_64.tgz"
#fname="splunk-7.1.1-8f0ead9ec3db-Linux-x86_64.tgz"


#curl -O http://download.splunk.com/products/splunk/releases/7.0.3/splunk/linux/splunk-7.0.3-fa31da744b51-Linux-x86_64.tgz

if [ -e "$SPL_DIR" ]
then
	  echo "this  $SPL_DIR is directory"
	  remove_splunk
          file_untar $fname
else
          check_process
          file_untar $fname
fi

# sets environment variable to SPLUNK_HOME=/opt/splunk
#echo " set environment variables "

envariables


########
        file_name=$fname
        test2="splunk-7.1"
        file_name=${file_name:0:10}

        if ([ "$file_name" = "$test2" ])
                then
                 #### changed in 7.1.1., ne password administrator
                 ####--seed-passwd
                #(FOR START ONLY) Set an admin password during installation. This will be ignored if an etc/passwd or user-
                ## seed.conf is detected.

                        /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd "$ADMIN_PSWD"

                        #splunk add licenses "$LICENSEPATH" -auth admin:administrator
                        /opt/splunk/bin/splunk add licenses "$LICENSEPATH" -auth "$ADMIN_USER":"$ADMIN_PSWD"
                        splunk restart -f
                        echo "basic setup is complete"
			exit
	else

		splunk start --accept-license

		echo "change admin password"
		set_admin_paswd
		splunk add licenses "$LICENSEPATH" -auth "$ADMIN_USER":"$ADMIN_PSWD"
		#splunk add licenses /opt/license/Splunk_Enterprise_NFR_Q4FY18.lic
		splunk restart -f
		echo "basic setup is complete"
		exit
	fi
