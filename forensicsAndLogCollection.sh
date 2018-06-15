#!/bin/bash
# -----------------------------------------------------------------------------
# forensicsAndLogCollection.sh
# pull data remotely from a macOS client with suspicious indicators found in JAMF Pro
# this script is designed to load data onto a secured smb share on a local network
#+to then view with another device.
# Last Edited: 6/15/18 Julian Thies
# -----------------------------------------------------------------------------
### parameters ###
# parameter 4 set in the JSS is the first octet of your private address range (10, 172, 192)
# parameter 5 set in the JSS is the IP address/hostname of the local SMB/Samba share server for collection
# parameter 6 set in the JSS is the name of the SMB/Samba share
# parameter 7 set in the JSS is the username for the write user for the share
# parameter 8 set in the JSS is the password for the share (insecure, but the share can be given strict access controls)
# -----------------------------------------------------------------------------

### VARIABLES
starDate="$(date +%y-%m-%d)"
hostName="$(hostname)"
localNWRange="$4"

localNetworkFile="/tmp/localYes.txt"

usersFile="/tmp/users.txt"
dataDir="/tmp/deviceInspect-$hostName-$starDate"
dotAppFile="$dataDir/applications.txt"
downloadsFile="$dataDir/downloads.txt"
persistenceFile="$dataDir/persistenceLocations.txt"
processesFile="$dataDir/processes.txt"
networkConnectionsFile="$dataDir/networkConnections.txt"

### FUNCTIONS
# check if on local network
function check_nw {
	rawIP="$(ifconfig | grep 'inet' | grep $localNWRange)"     # if IP address starts with 10, assume it is on local network
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
# make data directory
function make_dir {
    	if [ -e "$dataDir" ] ; then
		rm -r "$dataDir"
		mkdir "$dataDir"
    	else
		mkdir "$dataDir"
    	fi
}
# construct users file to use for collection and find all users
function user_search {
	destFile="$usersFile"
	ls -1 /Users >> "$destFile"
	# all users
	destFile="$dataDir/AllUsers.txt"
	echo "---- All Users ----" >> "$destFile"
	dscl . list /Users UniqueID >> "$destFile"
}
# list contents of ~/Downloads
function list_downloads {
	cat "$usersFile" | while read line
	do
        	echo "Downloads for $line"
		ls -l /Users/$line/Downloads >> "$downloadsFile"
    	done
}
# find all .apps
function find_dotApps {
	find / -iname *.app >> "$dotAppFile"
}
# persistence mechanisms
function persist_mechs {
	echo "---- /Users/*/Library/LaunchAgents ----" >> "$persistenceFile"
	cat "$usersFile" | while read line
	do
		echo "---- $line" >> "$persistenceFile"
		ls -la /Users/$line/Library/LaunchAgents >> "$persistenceFile"
	done
	echo ; echo "---- /Library/LaunchAgents ----" >> "$persistenceFile"
	ls -la /Library/LaunchAgents >> "$persistenceFile"
	# LDs
	echo ; echo "---- /Library/LaunchDaemons ----" >> "$persistenceFile"
	ls -la /Library/LaunchDaemons >> "$persistenceFile"

	echo "---- Login Items ----" >> "$persistenceFile"	
	cat "$usersFile" | while read line
	do
		echo "" >> "$persistenceFile"
		echo "---- $line ----" >> "$persistenceFile"
		echo >> "$persistenceFile"
		cat "/Users/$line/Library/Preferences/com.apple.loginitems.plist" >> "$persistenceFile" 2>&1
	done
	# Browser Extensions
	echo "---- Safari Extensions ----" >> "$persistenceFile"
	cat "$usersFile" | while read line
	do
		ls -l /Users/$line/Library/Safari/Extensions/ >> "$persistenceFile" 2>&1
	done
	# Firefox
	if [ -e "/Applications/Firefox.app" ] ; then
		echo "---- Firefox Extensions ----" >> "$persistenceFile"
		cat "$usersFile" | while read line
		do
			ls -lR "/Users/$line/Library/Application Support/Firefox/Profiles" >> "$persistenceFile" 2>&1
		done
	else
		echo "Firefox is not installed" >> "$persistenceFile"
	fi
	# Google Chrome
	if [ -e "/Applications/Google Chrome.app" ] ; then
		echo "---- Google Chrome Extensions ----" >> "$persistenceFile"
		cat "$usersFile" | while read line
		do
			ls -l "/Users/$line/Library/Application Support/Google/Chrome/Default/Extensions" >> "$persistenceFile" 2>&1
		done
	else
		echo "Google Chrome is not installed" >> "$persistenceFile"
	fi
	#
	# find all bash_history files on the system
	find / -name '.bash_history' >> /tmp/historyFiles.txt
	# try to figure out the users
	cat /tmp/historyFiles.txt | while read line
	do
		length="${#line}"
		cutString="$((($length - 15)))"
		userName="${line:1:$cutString}"
		# sort into files based on username
		if [ "$userName" == "root" ] ; then
			echo "$userName =====" >> "$persistenceFile"
			cat "$line" >> "$persistenceFile"
		else
			# flush out additional users' bash_history
			afterHome=${userName#*Users}
			lengthAfterHome="(( ${#afterHome} - 1 ))"
			afterCut="${afterHome:1:$lengthAfterHome}"
			echo "$afterCut =====" >> "$persistenceFile"
			cat "$line" >> "$persistenceFile"
		fi
	done
	rm /tmp/historyFiles.txt
}
# processes
function get_processes {
	ps aux >> "$processesFile"
}
# network stats
function network_stats {
	netstat -nal >> "$networkConnectionsFile"
}
# send report to smb/samba share
function send_data {
	diskutil unmount force "/Volumes/$shareName"    # unmount in case it is already mounted
	shareString="smb://$shareUser:$sharePass@$IPaddr/$shareName"
	open "$shareString"
	rysnc -var "$dataDir/" "/Volumes/$shareName"
	sleep 120
	diskutil unmount force "/Volumes/$shareName" 
}

### SCRIPT
# preflight checks
check_nw
check_five
check_six
check_seven
check_eight
####
make_dir
user_search
list_downloads
find_dotApps
persist_mechs
get_processes
network_stats

send_data
exit
# -----------------------------------------------------------------------------
