#!/bin/bash
# -----------------------------------------------------------------------------
# detectCrontabs.sh
# check for installed crontabs
# Last Edited: 1/8/18
# -----------------------------------------------------------------------------
adminUser=""     # if there is a local admin user, hardcode here
adminUser2=""    # if there is an alternate local admin user

# move into /Users to collect usernames above UID 500
cd /Users
echo "$(ls -1)" >> /tmp/Users.txt

# read usernames find user that is not Guest, Shared, or the adminUser(s)
if [ "$adminUser" == "" ] && [ "$adminUser2" == "" ] ; then
	targetUser="$(grep -v -e "Guest" -e "Shared" /tmp/Users.txt)"
elif [ "$adminUser" == "" ] ; then
	targetUser="$(grep -v -e "$adminUser2" -e "Guest" -e "Shared" /tmp/Users.txt)"
elif [ "$adminUser2" == "" ] ; then
	targetUser="$(grep -v -e "$adminUser" -e "Guest" -e "Shared" /tmp/Users.txt)"
else
	targetUser="$(grep -v -e "$adminUser" -e "$adminUser2" -e "Guest" -e "Shared" /tmp/Users.txt)"
fi

userTabFile="/tmp/usercrontabs.txt"
rootTabFile="/tmp/rootcrontabs.txt"
checkFile="/tmp/editedCrontabs.txt"

runUserTab="$(sudo crontab -l -u "$targetUser")"
if [ "$runUserTab" == "crontab: no crontab for $targetUser" ] ; then
    targetUserTab="Null"
elif [ "$runUserTab" != "" ] ; then
    crontab -u "$targetUser" -l >> "$userTabFile"
else
    targetUserTab="Null"
fi

runRootTab="$(sudo crontab -l)"
if [ "$runRootTab" == "crontab: no crontab for root" ] ; then
    rootUserTab="Null"
elif [ "$runRootTab" != "" ] ; then
    sudo crontab -l >> "$rootTabFile"
else
    rootUserTab="Null"
fi

# check if there are crontab files in /tmp for the target user and root
if [ -e "$userTabFile" ] && [ -e "$rootTabFile" ] ; then
    echo "<result>User and Root Crontab Found</result>"
elif [ -e "$userTabFile" ] ; then
    echo "<result>User Crontab Found</result>"
elif [ -e "$rootTabFile" ] ; then
    echo "<result>Root Crontab Found</result>"
else
    echo "<result>None</result>"
fi

rm /tmp/*.txt
