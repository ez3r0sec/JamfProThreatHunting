#!/bin/bash
# -----------------------------------------------------------------------------
# appsInUnusualLocations.sh
# extension attribute to find .apps in unusual locations
# Last Edited: 5/4/18
# -----------------------------------------------------------------------------
### VARIABLES
found="/tmp/findApps.txt"
errors="/tmp/hashErrors.txt"
results="/tmp/results.txt"

# array of dirs for search for apps
declare -a Search_Dirs=(
	"/tmp"
	"/usr"
	"/bin"
	"/etc"
	"/sbin"
	"/var"
	"/private"
)

### FUNCTIONS
function find_apps () {
	if [ -z "$1" ] ; then
		echo "<result>A directory to search was not passed in to find_app</result>"
		exit 1
	else
		searchDir="$1"
		# find .apps in the passed in directory
		sudo find "$searchDir" -name "*.app" >> "$found"
	fi
}

function hash_line {
	if [ -e "$found" ] ; then
		cat "$found" | while read line
		do
			# get a hash of the actual binary
			sha256="$(shasum -a 256 "$line/Contents/MacOS/*" | awk '{print $1}')"
			# check for 64 char length of sha256 hash
			length="${#sha256}"	
			if [ "$length" -ne 64 ] ; then
				echo "Could not hash $line/Contents/MacOS/*" >> "$errors"
			else
				echo "$line  SHA256: $sha256" >> "$results"
			fi
		done
	else
		echo "<result>$(cat $errors)</result>"
	fi
}

function read_results {
	if [ -e "$results" ] ; then
		buildResult="$(cat $results)"
		echo "<result>$buildResult</result>"
		rm "$results"
	else
		echo "<result>$(cat $errors)</result>"
	fi
}


### SCRIPT
# scan against array above
for (( i=0; i<${#Search_Dirs[@]}; i++ )) ; 
do
	find_apps "${Search_Dirs[$i]}"
done

# MiniTerm is signed by Apple
sudo find /usr -name "*.app" | grep -v '/usr/libexec/MiniTerm.app' >> "$found"

# hash it up
hash_line

# read 'em and weep
read_results

# clean up
if [ -e "$errors" ] ; then
	rm "$errors"
fi

if [ -e "$found" ] ; then
	rm "$found"
fi
