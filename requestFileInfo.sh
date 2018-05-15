#!/bin/bash
# -----------------------------------------------------------------------------
# requestFileInfo.sh
# request information about a suspicious file on a system
# Last Edited: 5/15/18 Julian Thies
# -----------------------------------------------------------------------------
### PARAMETERS ###
# parameter 4 is the first octet of your private address range (10, 172, 192)
# parameter 5 is the IP address/hostname of the local SMB/Samba share server for collection
# parameter 6 is the name of the SMB/Samba share
# parameter 7 is the username for the write user for the share
# parameter 8 is the password for the share (insecure, but the share can be given strict access controls)
# parameter 9 is the full file path of the file that you wish to inspect
# -----------------------------------------------------------------------------

### VARIABLES
localNWRange="$4"
localNetworkFile="/tmp/localYes.txt"
suspFile=$9     # pass in a full file path to param 4
destFile="/tmp/FileInfo.txt"

### FUNCTIONS
function space {
	echo >> "$destFile"
}

function section_header () {
	inputString="$1"
	echo "[ === $inputString ===]" >> "$destFile"
}

# check if on local network
function check_nw {
	rawIP="$(ifconfig | grep 'inet' | grep $localNWRange)"
	# if IP address starts with same first octet of internal network
	#+, assume it is on local network
	if [ "$rawIP" != "" ] ; then
		echo "On local network" >> "$localNetworkFile"
    	else
		exit
    	fi
}
# check for param 5 -- Share IP address/hostname
function check_five {
	if [ "$5" != "" ] ; then
    		IPaddr="$5"
    	else
    		echo "Parameter 5 not specified in the JSS"
    		exit
    	fi
}
# check for param 6 -- share name
function check_six {
	if [ "$6" != "" ] ; then
   		shareName="$6"
	else
    	 	echo "Parameter 6 not specified in the JSS"
    	  	exit
	fi
}
# check for param 7 -- username
function check_seven {
	if [ "$7" != "" ] ; then
    		shareUser="$7"
	else
    	 	echo "Parameter 7 not specified in the JSS"
    	  	exit
	fi
}
# check for param 8 -- password
function check_eight {
	if [ "$8" != "" ] ; then
    		sharePass="$8"
    	else
    		echo "Parameter 8 not specified in the JSS"
    		exit
    	fi
}
# send report to smb/samba share
function send_data {
	diskutil unmount force "/Volumes/$shareName"    # unmount in case it is already mounted
	shareString="smb://$shareUser:$sharePass@$IPaddr/$shareName"
	open "$shareString"
	sudo rysnc -var "$dataDir/" "/Volumes/$shareName"
	sleep 120
	diskutil unmount force "/Volumes/$shareName" 
}

### SCRIPT
# PREFLIGHT CHECKS
check_nw
check_five
check_six
check_seven
check_eight

# GENERATE FILE
# file header
echo "[ === $(date) -- $(hostname) -- FileInfo: $suspFile === ]" > "$destFile"
space

# file ops
section_header "HASH"
echo "sha256:  $(shasum -a 256 $hashFile | awk '{print $1}')" >> "$destFile"
echo "md5   :  $(md5 $hashFile | awk '{print $4}')" >> "$destFile"
echo "sha1  :  $(shasum $hashFile | awk '{print $1}')" >> "$destFile"
space

section_header "FILE"
file "$suspFile" >> "$destFile"
space

section_header "FILE SIZE KB"
file_size_kb="$(du -k "$suspFile" | cut -f1)"
echo "$file_size_kb" >> "$destFile"
space

section_header "STRINGS"
strings "$suspFile" >> "$destFile"
space

section_header "STRINGS FOR IP"
strings "$suspFile" | grep -w '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -u >> "$destFile"
space

section_header "STAT"
stat "$suspFile" >> "$destFile"
space

# SEND DATA
send_data
exit
