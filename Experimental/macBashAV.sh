#!/bin/bash
# ----------------------------------------------------------------------------
# macBashAV.sh
# collect malware hashes from Objective-See and compare to local files as a 
#+crude AV implementation, however, any positive results are 100% m41w4r3
# Last Edited: 5/15/18 Julian Thies
# ----------------------------------------------------------------------------

### VARIABLES
# set directories to scan here
declare -a Scan_Dirs=(
	"/Library"
	"/Applications"
	"/Users"
)

# some variables
jsonURL="https://objective-see.com/malware.json"
malHashes="/tmp/hashes.txt"

dirContents="/tmp/dirContents.txt"
hashStore="/tmp/sysHashes.txt"

infectedFile="/tmp/infected.txt"

### FUNCTIONS
### [=== collect hashes from Objective-See ===] ###
function download_IOCs {
	# grab the json file from Objective-See
	curl -s -o /tmp/malware.json "$jsonURL"

	# Pull out lines containing the VT URLs and then isolate the URL
	cat /tmp/malware.json | grep 'virusTotal' | awk '/virusTotal/ {print $2}' >> /tmp/links.txt

	# Read each URL and cut it down to just the SHA 256 hash
	cat /tmp/links.txt | while read line
	do
		lenString="${#line}"
		cutString="$((($lenString - 38)))"
		sha256Hash="${line:35:$cutString}"
		# if hash string is not exactly 64 characters, send it to an errors file
		lenHashString="${#sha256Hash}"
		if [ "$lenHashString" == 64 ] ; then
			# echo Mac malware hashes to a text file
		  	echo "$sha256Hash" >> "$malHashes" 
		else
			# echo lines that did not work for some reason to a file as well
			echo "$sha256Hash" >> /tmp/errors.txt
		fi
	done
	# the next lines are for debugging: add an empty file into one of the directories 
	#+to scan and uncomment the next line, should return a detection
	#touch "/tmp/emptyfile.txt"
	#echo "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" >> "$malHashes"
}

### [============ compare to files ============] ###
function compare_hashes () {
	if [ -z "$1" ] ; then
		echo "<result>A hash was not passed in to the compare_hashes function</result>"
		exit 1
	else
		cat "$malHashes" | while read line
		do
			if [ "$1" == "$line" ] ; then
				fileName="$(grep "$1" "$hashStore")"
				echo "$fileName  :  INFECTED" >> "$infectedFile"
			fi
		done
		# rm hashStore to make way for the next dir
		rm "$hashStore"
	fi
}

function hash_file () {
	if [ -z "$1" ] ; then
		echo "<result>A hash was not passed in to the hash_file function</result>"
		exit 1    
	else
		if [ -d "$line" ] ; then
			echo "$line is a directory"
		else
			sha256="$(shasum -a 256 "$line" | awk '{print $1}')"
			if [ "$sha256" != "" ] ; then
				#echo "$line  :  $sha256"     # this line is for debugging
				# echo to a file so that the filename can be retrieved				
				echo "$line  :  $sha256" >> "$hashStore"
				compare_hashes "$sha256"
			fi
		fi
	fi
}

function traverse_dirs () {
	if [ -z "$1" ] ; then
		echo "<result>Pass in a scan directory to traverse_dirs function</result>"
		exit 1
	else
		find "" -type f >> "$dirContents"
		cat "$dirContents" | while read line
		do
			hash_file "$line"
		done	
	fi
	rm "$dirContents"
}

### SCRIPT
# extract hashes from Objective-See
download_IOCs

# for each directory specified in the Scan_Dirs array, scan the directory 
#+recursively
for (( i=0; i<${#Scan_Dirs[@]}; i++ )) ; 
do
	traverse_dirs "${Scan_Dirs[$i]}"
done

# check if there are any detections
if [ -e "$infectedFile" ] ; then
	echo "<result>$(cat $infectedFile)</result>"
	rm "$infectedFile"
else
	echo "<result>None</result>"
fi

# clean up
rm /tmp/malware.json
rm /tmp/links.txt
rm /tmp/errors.txt
rm "$malHashes"
# ----------------------------------------------------------------------------
