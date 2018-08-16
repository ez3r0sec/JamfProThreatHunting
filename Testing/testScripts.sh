#!/bin/bash
# -----------------------------------------------------------------------------
# testScripts.sh
# test the threat hunting scripts against the current machine to ensure they are effective
#+and detect changes in system file hashes
# After downloading the repo, ad hoc hunting could be performed on single systems using
#+this script as well
# Make sure you input the profile IDs in the detectNewProfiles.sh script before running
# Last Edited: 8/16/18 Julian Thies
# -----------------------------------------------------------------------------

### SCRIPT
ls -1R ../ | grep 'sh' > /tmp/scripts.txt
ls -1R ../ | grep 'py' >> /tmp/scripts.txt

cat /tmp/scripts.txt | while read line
do
	if [ "$line" != "forensicsAndLogCollection.sh" ] && [ "$line" != "requestFileInfo.sh" ] ; then
		# give permission to the scripts
		chmod +x "$line"
		echo "Running $line"
		echo
		# run the scripts
		"$(pwd)/$line"
		echo "====="
	fi
done

echo
echo "===== All scripts complete ====="

rm /tmp/scripts.txt
# -----------------------------------------------------------------------------
