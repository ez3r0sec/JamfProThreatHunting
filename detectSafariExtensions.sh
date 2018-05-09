#!/bin/bash
# -----------------------------------------------------------------------------
# detectSafariExtensions.sh
# look for safari extensions
# Last Edited: 1/29/18
# -----------------------------------------------------------------------------
fileType="safariextz"
outputFile="/tmp/$fileType-file.txt"

searchDir="/"
sudo find $searchDir -name "*.$fileType" >> "$outputFile"

num_fileType="$(wc -l < "$outputFile")"

if [ "$num_fileType" -gt 0 ] ; then
     echoResult="$(cat $outputFile)"
     echo "<result>$echoResult</result>"
else
     echo "<result>None</result>"
fi

rm $outputFile
