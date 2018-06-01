#!/bin/bash
# -----------------------------------------------------------------------------
# crontabs.sh
# interrogate the cron jobs on a macOS system
# Last Edited: 6/1/18 Julian Thies
# -----------------------------------------------------------------------------

### VARIABLES
tabs="/tmp/crontabs.txt"
artifacts="/tmp/artifacts.txt"

### SCRIPT
# find out if anything is in the crontab directory
sudo ls -1 /usr/lib/cron/tabs >> "$tabs"

# calculate the number of lines in the tabs file
lengthTabs="$(wc -l < "$tabs")"

if [ "$lengthTabs" -gt 0 ] ; then
	cat "$tabs" | while read line
	do
		echo "$line ==========" >> "$artifacts"
		sudo cat "/usr/lib/cron/tabs/$line" >> "$artifacts"
	done
	
	result="$(cat $artifacts)"

	# display result to the JSS
	echo "<result>$result</result>"

	# clean up
	if [ -e "$tabs" ] ; then
		rm "$tabs"
	fi
	if [ -e "$tabs" ] ; then
		rm "$artifacts"
	fi
else
	# no crontabs, display None
	echo "<result>None</result>"
	if [ -e "$tabs" ] ; then
		rm "$tabs"
	fi
fi

