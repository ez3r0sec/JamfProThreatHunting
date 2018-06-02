#!/bin/bash
# -----------------------------------------------------------------------------
# detectSuspiciousBash.sh
# look for evidence of obfuscation or suspicious commands in bash_history
# Last Edited: 6/1/18 Julian Thies
# -----------------------------------------------------------------------------

### VARIABLES
collectDir="/tmp/bh"
rootHistFile="$collectDir/ROOT-bash_history.log"
histFile="bash_history.log"
detectFile="/tmp/possible-intrusion.log"

### ARRAYS
# add or remove queries to your heart's content ## uname adds a lot of false positives
declare -a Susp_CLs=(
	"curl"
	"ssh"
	"telnet"
	"whoami"
	"tcpdump"
	"ifconfig"
	"visudo"
	"nano"
	"cron"
	"zip"
	"?"
	"*"
	";"
)

### FUNCTIONS
function mk_dir {
	if [ -e "$collectDir" ] ; then
		rm -r "$collectDir"
		mkdir "$collectDir"
	else
		mkdir "$collectDir"
	fi
}

function collect_bash_history {
	# find all bash_history files on the system
	sudo find / -name '.bash_history' >> /tmp/historyFiles.txt
	# try to figure out the users
	cat /tmp/historyFiles.txt | while read line
	do
		length="${#line}"
		cutString="$((($length - 15)))"
		userName="${line:1:$cutString}"
		# sort into files based on username
		if [ "$userName" == "root" ] ; then
			sudo cat "$line" >> "$rootHistFile"
		else
			# flush out additional users' bash_history
			afterHome=${userName#*Users}
			lengthAfterHome="(( ${#afterHome} - 1 ))"
			afterCut="${afterHome:1:$lengthAfterHome}"
			sudo cat "$line" >> "$collectDir/$afterCut-$histFile"
		fi
	done
	rm /tmp/historyFiles.txt
}

function match_list () {
	if [ -z "$1" ] || [ -z "$2" ] ; then
		echo "<result>Not enough parameters</result>"
		exit 1
	else
		grep "$1" "$collectDir/$2" >> "$detectFile"
	fi
}


function check_history {
	# find which files we need to loop through
	ls -1 "$collectDir" >> /tmp/run.txt
	# loop through each file and check for suspicious command lines
	cat /tmp/run.txt | while read line
	do
		echo "$line =====" >> "$detectFile"
		# first grep for IPs
		grep -w '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' "$collectDir/$line" >> "$detectFile"
		# iterate through the array
		for (( i=0; i<${#Susp_CLs[@]}; i++ )) ; 
		do
			match_list "${Susp_CLs[$i]}" "$line"
		done
	done
	rm /tmp/run.txt		
}

function read_result {
	# remove all lines containing "=====" to see if there are any matches
	isEmpty="$(grep -v "=====" "$detectFile")"
	if [ "$isEmpty" != "" ] ; then
		result="$(cat "$detectFile")"
		echo "<result>$result</result>"
	else
		echo "<result>None</result>"
	fi
}

function clean_up {
	if [ -e "$detectFile" ] ; then
		rm "$detectFile"
	fi
	if [ -e "$collectDir" ] ; then
		rm -r "$collectDir"
	fi
}

### SCRIPT
mk_dir
collect_bash_history
check_history
read_result
clean_up
