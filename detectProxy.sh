#!/bin/bash
# -----------------------------------------------------------------------------
# detectProxy.sh
# check for configured proxies
# Last Edited: 6/12/18 Julian Thies
# -----------------------------------------------------------------------------
md5DefaultSettings="ecfac3dd55e6cf2c05c1d11865eee893"

# collect system proxy settings
scutil --proxy >> /tmp/proxysettings.txt

# collect an MD5 hash of the settings to compare to the hash of the default settings above
sysSettingsHash="$(md5 /tmp/proxysettings.txt | awk '{print $4}')"

# compare the two MD5 hashes
if [ "$sysSettingsHash" != "$md5DefaultSettings" ] ; then
	proxyFileContents="$(scutil --proxy)"
	echo "<result>$proxyFileContents</result>"
else
	echo "<result>None</result>"
fi

rm /tmp/proxysettings.txt
