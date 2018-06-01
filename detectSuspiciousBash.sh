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
			for (( i=0; i<${#Susp_CLs[@]}; i++ )) ; 
			do
				echo "$line =====" >> "$detectFile"
				match_list "${Susp_CLs[$i]}" "$line"
			done
		done
		

}

function read_result {
	isEmpty="$(grep -v "=====" "$detectFile")"
	if [ "$isEmpty" != "" ] ; then
		result="$(cat "$detectFile")"
		echo "<result>$result</result>"
	else
		echo "<result>None</result>"
	fi
}

function clean_up {
	if [ -e "/tmp/historyFiles.txt" ] ; then
		rm "/tmp/historyFiles.txt"
	fi
	if [ -e "/tmp/run.txt" ] ; then
		rm "/tmp/run.txt"
	fi
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
