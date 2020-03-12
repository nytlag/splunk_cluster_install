#!/bin/bash
shopt -s expand_aliases


. ~/mylibs/myinstalls/mylibrary1.sh
#. /opt/mylibrary1.sh
#. /root/mylibs/myinstalls/cluster.sh
. ~/mylibs/myinstalls/cluster.sh

#enable_debugging

#======================= declare section ============

#------
IDX_SECRET="idxcluster"
MASTER_URI="https://host_server01.xxxxx:8089"
MASTER="host_server01.xxxxx"

IDX_REPLICATION_PORT="9100"
SHC_REPLICATION_PORT="8100"
IDX_REPLICATION_FACTOR="2"
IDX_SEARCH_FACTOR="2"

#-------- IMPORTANT- 7.1.x has special password restriction -----
ADMIN_USER="admin"
ADMIN_PSWD="admin"  # this can be used for any pre 7.1.x installs
#ADMIN_PSWD="administrator" # set this for 7.1.x installs

DEPLOYER="https://host_server07.xxxxx:8089"
CAPTAIN="host_server06.xxxxx"
OS_user="root"

# declare search cluster members
declare -a arr_SHC_members=(
"host_server04.xxxxx"
"host_server05.xxxxx"
"host_server06.xxxxx"

)

# declare cluster members
declare -a arr_CLUSTER_members=(
"host_server02.xxxxx"
"host_server03.xxxxx"

)

config_master_mode


splunk_restart_ssh "$MASTER"

for i in "${arr_CLUSTER_members[@]}"
        do
          config_indexer_peer_ssh "$i"
          splunk_restart_ssh "$i"
        done



echo " --- adding SH to indexer clustering"

echo "starting SHC setup, please wait    ...."
# using syntax
#ssh root@host_server04.xxxxx "/opt/splunk/bin/splunk edit cluster-config -mode searchhead -master_uri https://host_server01.xxxxx:8089 -secret idxcluster -auth "$ADMIN_USER":"$ADMIN_PSWD"

 for i in "${arr_SHC_members[@]}"
        do
		config_SHC_member_ssh "$i"
		splunk_restart_ssh "$i"
 done


 echo "------- initializing SHC members"


 for i in "${arr_SHC_members[@]}"
	do
		init_SHC_members "$i"
		splunk_restart_ssh "$i"

	# increase port number by 100 for each SHC member e.g. 8100+100, ......
	#(( SHC_REPLICATION_PORT = SHC_REPLICATION_PORT+100))

	done


echo "----------- bootstrap SHC ----"

# get length of an array
tLen=${#arr_SHC_members[@]}
newlist=""

# use for loop read all nameservers
for (( i=0; i<${tLen}; i++ ));

do
  echo "element value = $i"
  echo ${arr_SHC_members[$i]}

  if ((  i==${tLen}-1 ))
        then
        newlist="$newlist"https://${arr_SHC_members[$i]}:8089
	bootstrap_SHC $newlist
  else
        newlist="$newlist"https://${arr_SHC_members[$i]}:8089,
        echo $newlist
	ssh "$OS_user"@"$CAPTAIN" "/opt/splunk/bin/splunk rolling-restart shcluster-members -auth $ADMIN_USER:$ADMIN_PSWD"
	ssh "$OS_user"@"$CAPTAIN" "/opt/splunk/bin/splunk show shcluster-status"
fi
done


echo "clustering enviornment setup complete ...."

#disable_debugging
