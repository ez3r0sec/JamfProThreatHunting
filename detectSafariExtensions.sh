#!/bin/bash
# -----------------------------------------------------------------------------
# detectSafariExtensions.sh
# look for safari extensions
# Last Edited: 6/27/18 Julian Thies
# -----------------------------------------------------------------------------

### VARIABLEs
fileType="safariextz"
outputFile="/tmp/$fileType-file.txt"

### SCRIPT
searchDir="/"
find $searchDir -name "*.$fileType" >> "$outputFile"

num_fileType="$(wc -l < "$outputFile")"

if [ "$num_fileType" -gt 0 ] ; then
     echoResult="$(cat $outputFile)"
     echo "<result>$echoResult</result>"
else
     echo "<result>None</result>"
fi

rm $outputFile
# -----------------------------------------------------------------------------
