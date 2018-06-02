#!/bin/bash
# -----------------------------------------------------------------------------
# detectServices.sh
# check for services like Apache and SMB running on the machine
# Last Edited: 6/2/18 Julian Thies
# -----------------------------------------------------------------------------
runServ="/tmp/runningservices.txt"

checkApache="$(ps aux | grep '/usr/sbin/httpd' | grep -v 'grep /usr/sbin/httpd')"
checkAFP="$(sudo launchctl list | grep AppleFileServer)" 
checkSMB="$(sudo launchctl list | grep smbd)"

# check for Apache
if [ "$checkApache" != "" ] ; then
	echo "Apache is running" >> "$runServ"
fi
# check for AFP
if [ "$checkAFP" != "" ] ; then
	echo "AFP is running" >> "$runServ"
fi
# check for SMB
if [ "$checkSMB" != "" ] ; then
	echo "Samba is running" >> "$runServ"
fi

# read results
if [ -e "$runServ" ] ; then
	readResults="$(cat $runServ)"
	echo "<result>$readResults</result>"
	rm "$runServ"
else
	echo "<result>None</result>"
fi
