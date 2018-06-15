#!/bin/bash
# -----------------------------------------------------------------------------
# detectNewProfiles.sh
# detect profiles that are not whilelisted by management
# response to new Crossrider Adware variant using Configuration Profiles
#+for persistence <hxxps://
#+blog.malwarebytes[.]com/threat-analysis/2018/04/new-crossrider-variant
#+-installs-configuration-profiles-on-macs/>
# Last Edited: 6/15/18 Julian Thies
# -----------------------------------------------------------------------------

### VARIABLES
foundFile="/tmp/foundProfiles.txt"
matchFile="/tmp/match.txt"
resultsFile="/tmp/results"

# array for the identifiers of profiles that you wish to whitelist
declare -a Profile_Whitelist=(
	"remove this note and populate with ID #s"
)

### FUNCTIONS
function match_list () {
	if [ -z "$1" ] ; then
		echo "<result>An index number for the whitelist was not passed in</result>"
		exit 1
	else
		if [ "$line" == "$1" ] ; then
			echo "$line" >> "$matchFile"
		fi
	fi
}

function iterate_whitelist {
	cat "$foundFile" | while read line
	do
		for (( i=0; i<${#Profile_Whitelist[@]}; i++ )) ; 
		do
			match_list "${Profile_Whitelist[$i]}"
		done

		# check for non-matches
		if [ -e "$matchFile" ] ; then
			# if there is a match, throw it away
			rm "$matchFile"
		else
			# if there is no match, add it to the result file
			echo "$line" >> "$resultsFile"
		fi
	done
}

function read_results {
	buildResult="$(cat $resultsFile)"
	echo "<result>$buildResult</result>"
}

### SCRIPT
# collect profile identifiers
profiles -L | awk '{print $4}' | grep -v 'system' >> "$foundFile"

# check against whitelist
iterate_whitelist

# read the results
if [ -e "$resultsFile" ] ; then
	read_results
	rm "resultsFile"
else
	echo "<result>None</result>"
fi

# clean up
if [ -e "$foundFile ] ; then
	rm "$foundFile"
fi
