#!/bin/bash
#
# This is a library file that contains list of functions in it
#. ./remote.sh
# VERSION 101
#  6/11/2018 --- check last section at the end merged tinst.sh contents into here.

shopt -s expand_aliases

mylib1="mylibrary.sh:"


#function to enable debug

function enable_debugging()
{
	"echo enable debug function called"
	set -x			# activate debugging from here
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

#function to catch exception
function exception_cought1
{
	echo "Exception_coought1: exiting script, thank you for using this program"
	 exit;
}


# function tot track CTRL + xxx command
function trap_ctrlc ()
{
    echo 
 	echo "$mylib1, trap_ctrlc, you pressed Ctrl-C... bye, exiting script"
 	echo
    cleanup_code
 
    # exit shell script with error code 2
    exit 2
}

# function to clean up the code
function cleanup_code()
{
	echo "$mylib1: cleaning up temp files before exit"
	echo "Thank you for using this script"
}

#============= file operations ########

#================= file extension filters ===

# function to list file extensions
function file_untar ()
{
	local tarfile=$fname

	echo "untaring $tarfile file"

	tar xvzf $tarfile > /dev/null
	#  tar xvzf $tarfile
	
	echo "untar complete "

	# put here return code	
}


function file_extension ()
{
	# this function will ouput file extensions only
	local file_name=$fname
	#ls $file_name | cut -c 4-7

# reference: https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
	
	extension="${file_name##*.}"
	echo "     the extension of $file_name is = \"$extension\""
	echo

	<<COMMENT1
	REGEX_D="((^.*)(?<test>\..*))"
	echo "file name = $file_name"
	echo "reg id = $REGEX_D"
COMMENT1
	#echo "$file_name" | grep  '((^.*)(\..*)'
	#echo "$file_name" | egrep  "$REGEX_D"
	
}

# function that extracts base name of the file
function extract_fname()
{
	local file=$fname
	#file=abc_asdfjhdsf_dfksfj_12345678.csv
	echo "extracting base name from $file ..."
	
	n=${file%.*}   # n becomes abc_asdfjhdsf_dfksfj_12345678
	
	echo "           the base name of $file is = \"$n\""
	echo 

}

function print_prompt()
{
#	echo "  Please enter your input:"
	echo "  To install Splunk, type File press enter:"
	echo "  To Uninstall Splunk, Enter N for no:"
	#echo "  To extract file extension,e.g. log.txt=txt, type file name: \"File\":"
	echo "  Press any key to exit: "
	echo
}




#================ aliases =======


function setthat ()
{
	echo
	#. ./setaliases.sh # source the setaliases.sh script
	what="one thing"
	alias saywhat='echo $what'

	echo "alias has been set from setthat() function"
	alias | grep saywhat
	echo "**********"
}

function setaliases ()
{
	alias lsl='ls -l'
	alias lsla='ls -l -a'
	alias copy='cp'
	alias cp='cp -i'
	alias dir='/bin/ls'
	alias del='rm'

	#alias | grep lsl
	#alias

}

#================ set environment variables =======
function envariables ()
{
	export SPLUNK_HOME=/opt/splunk
	PATH=$PATH:$HOME/bin/:/opt/splunk/bin
	export PATH
}


#================ update splunk settings =======
function set_admin_paswd ()
{
	splunk edit user admin -role admin -auth admin:changeme -password admin
}

function add_license ()
{
	splunk add licenses LICENSEPATH

}

function remove_splunk ()
{
	#function to check process check process
	check_process

	#"$DEST_DIR"/bin/splunk stop -f 
	
	rm -rf $SPL_DIR

	echo "$SPL_DIR directory has been removed"
}

check_process() 
{
        echo "check _process func called"	
	SERVICE='splunk'
	number=0
        bb=1

while [ $number -lt 1 ] ; do

echo "value of number=$number"
if ps ax | grep -v grep | grep $SERVICE > /dev/null
	then
	    echo "$SERVICE service is running , calling stop $bb-st time"
	       "$DEST_DIR"/bin/splunk stop -f 
		#splunk stop -f
                bb=$((bb+1))
                number=$((number + 1)) 
	else
	    echo "$SERVICE is not running"
	       number=$((number + 1))
	    # echo "$SERVICE is not running!" | mail -s "$SERVICE down" root
	fi
done

<<COMMENT1
	PROCESS="splunkd"
	START_OR_STOP=1        # 0 = start | 1 = stop

	PROCESS_NUM=$(ps -ef | grep "$PROCESS" | grep -v "grep" | wc -l)
	if [ $PROCESS_NUM -gt 0 ]; then
	 #runs
            RET=1
            splunk stop
        else
            #stopped
            RET=0
        fi
COMMENT1

}


function remote_login()
{
	echo "list aliases "

	#alias rdlab1='/Users/rdjoraev/Desktop/Troubleshoot/Scripts/rdlab1.sh'
	#alias rdlab6='/Users/rdjoraev/Desktop/Troubleshoot/Scripts/rdlab6.sh'
	#alias rdlab8='/Users/rdjoraev/Desktop/Troubleshoot/Scripts/rdlab8.sh'

	echo "remote login"	
#	/Users/rdjoraev/Desktop/Troubleshoot/Scripts/rdlab8.sh

}

################# this will install splunk base ########

function install_base_splunk ()
{
cd /opt

trap trap_ctrlc SIGINT

VERSION=101
LICENSEPATH="/opt/Splunk_Enterprise_NFR_Q2FY19.lic"
SPL_DIR="splunk"
#fname="splunk-6.6.3-e21ee54bc796-Linux-x86_64.tgz"
#fname="splunk-6.6.2-4b804538c686-Linux-x86_64.tgz"
#fname="splunk-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz"
fname="splunk-7.0.3-fa31da744b51-Linux-x86_64.tgz"

curl -O http://download.splunk.com/products/splunk/releases/7.0.3/splunk/linux/splunk-7.0.3-fa31da744b51-Linux-x86_64.tgz

if [ -e "$SPL_DIR" ]
then
          echo "this  $SPL_DIR is directory"
          remove_splunk
          file_untar $fname
fi


#echo " set environment variables "

envariables

                splunk start --accept-license

                echo "change admin password"
                set_admin_paswd
                splunk add licenses "$LICENSEPATH"
                #splunk add licenses /opt/license/Splunk_Enterprise_NFR_Q4FY18.lic
                splunk restart -f
                echo "basic setup is complete"
                exit

}

