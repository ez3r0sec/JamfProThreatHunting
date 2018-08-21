#!/bin/bash
# -----------------------------------------------------------------------------
# executablesInMail.sh
# check Mail.app directories for executables
# Last Edited: 8/21/18 Julian Thies
# -----------------------------------------------------------------------------

### VARIABLES
users_file="/tmp/users.txt"
executables="/tmp/executables.txt"
results="/tmp/results.txt"

### FUNCTIONS
function read_results {
	if [ -e "$results" ] ; then
		buildResult="$(cat $results)"
		echo "<result>$buildResult</result>"
		rm "$results"
	else
		echo "<result>None</result>"
	fi
}

function get_users {
	ls -1 /Users >> "$users_file"
}

function collect_exes {
	cat "$users_file" | while read line
	do
		if [ -d "/Users/$line/Library/Mail" ] ; then
			find "/Users/$line/Library/Mail/" -type f -perm +111 >> "$executables"
		fi
	done
	rm "$users_file"
}

function check_exes {
	numLines="$(wc -l < "$executables")"
	if [ $numLines -eq 0 ] ; then
		echo "<result>None</result>"
		rm "$executables"
		exit
	fi
}

function hash_exes {
	cat "$executables" | while read line
	do
		# get the sha256 hash
		hash="$(shasum -a 256 $line | awk '{print $1}')"
		length="${#hash}"
		if [ "$length" -ne 64 ] ; then
			hash="Unable to hash"
		fi
		
		# echo results to the results file
		echo "$line  $hash" >> "$results"
	done
}

### SCRIPT
get_users
collect_exes
check_exes
hash_exes
read_results
clean_up
# -----------------------------------------------------------------------------
