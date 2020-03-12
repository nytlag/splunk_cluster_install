#!/bin/bash

# VERSION 102
# 1/17/18
#
# this file as functions related to remote install/ssh


function enable_debugging()
{
	echo "enable debug function called"
	set -xv			# activate debugging from here
	echo "code debugging has been enabled"
	> out.txt 2>error.txt 5>debug.txt
	echo

}

# function disable debugging
function disable_debugging()
{
	set +x			# stop debugging from here
	echo "debugging has been disabled"
	echo
}

# it will ssh into destination host

remote_install ()
{
	#local srvr_name=$SPLUNK_INST
	#ssh "$srvr_name" '/opt/tinist.sh'
	#ssh "$srvr_name" 'hostname'
	echo "=========================="
	echo "begin installation on $i host"
	echo "=========================="

	local srvr_name=$i
	ssh "$srvr_name" '/opt/tinist.sh'

}
# this one for single server install
remote_install_1srvr ()
{
        local srvr_name=$SPLUNK_INST
        # test.sh file will create /opt/license dir
	ssh "$srvr_name" '/opt/test.sh'

}

<<COMMENT1
function remote_inst_splunk ()
{
	ssh "$SPLUNK_INST" '/opt/tinist.sh'
}
COMMENT1

function remote_inst_splunk ()
{
   ssh "$i" '/opt/tinist.sh'
}


# this declare_hosts function will declare all splunk instances
<<COMMENT1
function declare_hosts()
{
	declare -a arr=("host_server02.xxxxx"  "host_server03.xxxxx"  "host_server04.xxxxx"  "host_server05.xxxxx"  "host_server06.xxxxx"  "host_server07.xxxxx"  "host_server08.xxxxx")

for i in "${arr[@]}"
do
   #echo "$i"
   # or do whatever with individual element of the array
        remote_install "$i"
done
}

COMMENT1

function declare_hosts()
{
        declare -a arr=("host_server01.xxxxx" "host_server02.xxxxx" "host_server03.xxxxx" "host_server04.xxxxx" "host_server06.xxxxx" )

for i in "${arr[@]}"
do
   #echo "$i"
   # or do whatever with individual element of the array
	copy_init_file "$i"
	remote_install "$i"
done
}

function declare_hosts_arr()
{

	for i in "${arr_hosts[@]}"
	do
        	copy_init_file "$i"
        	remote_install "$i"
	done
}



# this will copy initial file that will create a prep folder
#1. mylibrary1.sh,
#2. tininst.sh,
#3. licence file,
#4. tar install file

function copy_init_file ()
{
	local srvr_name=$i
#	scp test1.txt root@"$srvr_name":/opt/

#       scp test.sh root@"$srvr_name":/opt/
#       scp test.sh root@${SPLUNK_INST}:/opt/

        scp ~/mylibs/myinstalls/mylibrary1.sh "$OS_user"@"$srvr_name":/opt/
        scp ~/mylibs/myinstalls/tinist.sh "$OS_user"@"$srvr_name":/opt/
	scp ~/mylibs/myinstalls/"$license_file" "$OS_user"@"$srvr_name":/opt/
	scp ~/mylibs/myinstalls/"$install_file" "$OS_user"@"$srvr_name":/opt/
}


<<COMMENT1
function copy_init_file ()
{
	scp test.sh root@host_server05.xxxxx:/opt/
#	scp test.sh root@${SPLUNK_INST}:/opt/
	remote_install_1srvr

#---- copy tar and install files
	scp /root/mylibs/myinstalls/mylibrary1.sh root@host_server05.xxxxx:/opt/
	scp /root/mylibs/myinstalls/tinist.sh root@host_server05.xxxxx:/opt
	scp /root/mylibs/myinstalls/Splunk_Enterprise_NFR_Q4FY18.lic root@host_server05.xxxxx:/opt/license

#	scp ./myinstalls/mylibrary1.sh  ./myinstalls/splunk-6.6.3-e21ee54bc796-Linux-x86_64.tgz  ./myinstalls/tinist.sh root@host_server05.xxxxx:/root/myinstalls/
	#scp ./myinstalls/mylibrary1.sh root@host_server05.xxxxx:/root/myinstalls/
}
COMMENT1
