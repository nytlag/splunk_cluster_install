#!/bin/bash

. /opt/mylibrary1.sh
. ~/mylibs/libinst.sh  # this will have remote install functions
. ~/mylibs/myinstalls

#IDX_SECRET="idxcluster"
#MASTER_URI="host_server01.xxxxx:8089"
#IDX_REPLICATION_PORT="9100"
#MASTER="host_server01.xxxxx"
#IDX_PEER1="host_server02.xxxxx"
#IDX_PEER2="host_server03.xxxxx"


# 1 ----------- Configure Cluster Master -----------

function config_master_mode ()
{
#        splunk edit cluster-config -mode master -replication_factor 2 -search_factor 2 -secret $IDX_SECRET
#ssh root@"$MASTER" '/opt/splunk/bin/splunk edit cluster-config -mode master -replication_factor 2 -search_factor 2 -secret $IDX_SECRET -auth admin:password'

#ssh root@host_server01.xxxxx '/opt/splunk/bin/splunk edit cluster-config -mode master -replication_factor 2 -search_factor 2 -secret idxcluster -auth admin:admin'


ssh "$OS_user"@"$MASTER" "/opt/splunk/bin/splunk edit cluster-config -mode master -replication_factor $IDX_REPLICATION_FACTOR -search_factor $IDX_SEARCH_FACTOR -secret $IDX_SECRET -auth $ADMIN_USER:$ADMIN_PSWD"
}

function config_indexer_peer ()
{
	#splunk edit cluster-config -mode slave -master_uri https://host_server05.xxxxx:8089 -secret idxcluster -replication_port 9100
	splunk edit cluster-config -mode slave -master_uri "$MASTER_URI" -secret $IDX_SECRET -replication_port "$IDX_REPLICATION_PORT"
}

#   this function will SSH onto peer and initiate cluster-config command to add a slave
function config_indexer_peer_ssh ()
{
#	local srvr_name=$IDX_PEER1
#declare -a arr=("$IDX_PEER1" "$IDX_PEER1")

#for i in "${arr[@]}"
#do
#ssh "root@$i" '/opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri "$MASTER_URI" -secret $IDX_SECRET -replication_port "$IDX_REPLICATION_PORT" -auth admin:admin'

#done

#splunk edit cluster-config -mode slave -master_uri https://host_server05.xxxxx:8089 -secret idxcluster -replication_port 9100

#ssh "$srvr_name" 'splunk edit cluster-config -mode slave -master_uri "$MASTER_URI" -secret $IDX_SECRET -replication_port "$IDX_REPLICATION_PORT"'

#--- this works ----
#ssh root@"$1" "/opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri https://host_server01.xxxxx:8089 -secret idxcluster -replication_port $2 -auth admin:admin"

ssh "$OS_user"@"$1" "/opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri $MASTER_URI -secret $IDX_SECRET -replication_port $IDX_REPLICATION_FACTOR -auth $ADMIN_USER:$ADMIN_PSWD"


}

function splunk_restart_ssh ()
{
  ssh "$OS_user"@"$1" '/opt/splunk/bin/splunk restart'
}

#config_master_mode

#splunk restart

###-------------------------
function config_SHC_member_ssh ()
{

#--- this works ----
#ssh root@"$1" "/opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri https://host_server01.xxxxx:8089 -secret idxcluster -replication_port $2 -auth admin:admin"

#/opt/splunk/bin/splunk edit cluster-config -mode searchhead -master_uri https://10.0.x.3:8089 -secret idxcluster
#ssh root@"$1" "/opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri https://host_server01.xxxxx:8089 -secret idxcluster -replication_port $2 -auth admin:admin"
 ssh "$OS_user"@"$i" "/opt/splunk/bin/splunk edit cluster-config -mode searchhead -master_uri $MASTER_URI -secret $IDX_SECRET -auth $ADMIN_USER:$ADMIN_PSWD"

}

function init_SHC_members ()
{
	ssh "$OS_user"@"$i" "/opt/splunk/bin/splunk init shcluster-config -auth $ADMIN_USER:$ADMIN_PSWD -mgmt_uri https://$i:8089 -replication_port $SHC_REPLICATION_PORT -conf_deploy_fetch_url  $DEPLOYER -secret password"

}

function bootstrap_SHC ()
{
	ssh "$OS_user"@"$CAPTAIN" "/opt/splunk/bin/splunk bootstrap shcluster-captain -servers_list  \"$1\" -auth $ADMIN_USER:$ADMIN_PSWD"
}
