#!/bin/bash
# -----------------------------------------------------------------------------
# detectOldPersistenceMethods.sh
# check for modified system files that could be used by malware for persistence
# (deprecated methods, 10.9 and earlier)
# Last Edited: 5/29/18
# -----------------------------------------------------------------------------
# rc.common
md5RCCommon="28ce428faefe6168618867f3ff5527f9"
sysRCCommonHash="$(md5 /etc/rc.common | awk '{print $4}')"

if [ "$sysRCCommonHash" != "$md5RCCommon" ] ; then
	echo "rc.common hash: $sysRCCommonHash" > /tmp/rc.txt
fi

# launchd.conf + bsexec
if [ -e /etc/launchd.conf ] ; then
	checkBSexec="$(grep 'bsexec' /etc/launchd.conf)"
	if [ "$checkBSexec" != "" ] ; then
		echo "/etc/launch.conf exists (bsexec): $checkBSexec" > /tmp/lc.txt
	fi
fi

# build result
if [ -e /tmp/rc.txt ] || [ -e /tmp/lc.txt ] ; then
	buildResult="$(cat /tmp/*.txt)"
	echo "<result>$buildResult</result>"
else
	echo "<result>None</result>"
fi

# clean up
if [ -e /tmp/rc.txt ] ; then
	rm /tmp/rc.txt
fi

if [ -e /tmp/lc.txt ] ; then
	rm /tmp/lc.txt
fi
