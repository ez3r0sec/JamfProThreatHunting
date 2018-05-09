#!/bin/bash
# -----------------------------------------------------------------------------
# suspiciousSudoersEntries.sh
# look for suspicious entries in the sudoers file
# Last Edited: 4/2/18
# -----------------------------------------------------------------------------
sudoersFile="/etc/sudoers"

# example string in the configuration file that would match our criteria
exampleString="# %wheel ALL=(ALL) NOPASSWD: ALL"

# check if no password is required to run commands in the sudo context
noPass="$(sudo grep 'ALL=(ALL) NOPASSWD: ALL' $sudoersFile | grep -v "$exampleString")"

# check if there is no expiration for sudo authorization
noTimeLimit="$(sudo grep 'defaults !tty_tickets' $sudoersFile)"

if [ "$noPass" == "" ] && [ "$noTimeLimit" == "" ] ; then
	echo "<result>None</result>"
else
        # print each result from above to a text file that can be read all at once
	echo "$noPass" >> /tmp/result.txt
	echo "$noTimeLimit" >> /tmp/result.txt
	buildResult="$(cat /tmp/result.txt)"
	echo "<result>$buildResult</result>"	
fi

# clean up
if [ -e /tmp/result.txt ] ; then
	rm /tmp/result.txt
fi
