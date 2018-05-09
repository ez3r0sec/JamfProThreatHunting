#!/bin/bash
# -----------------------------------------------------------------------------
# detectApache.sh
# check for Apache running on the machine
# Last Edited: 1/23/18
# -----------------------------------------------------------------------------
checkApache="$(ps aux | grep '/usr/sbin/httpd' | grep -v 'grep /usr/sbin/httpd')"

if [ "$checkApache" != "" ] ; then
	echo "<result>Apache is running</result>"
else
	echo "<result>None</result>"
fi
