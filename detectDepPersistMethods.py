#!/usr/bin/python
# -----------------------------------------------------------------------------
# detectDepPersistMethods.py
# check for modified system files that could be used for persistence
# (deprecated methods, 10.9 and earlier)
# Last Edited: 7/2/18 Julian Thies
# -----------------------------------------------------------------------------

### IMPORTS
import os
import re
import hashlib

### VARIABLES
rcCommonSha256 = "768ff09154f6aacda857cb175ef29cf9d23ef9c38c69efdbf20354dbfd7875b1"
resultsFile = "/tmp/results.txt"

### FUNCTIONS
''' function to standardize writing to the output file '''
def write_to_file(filename, contents):	
	with open(filename, 'a') as f:
		f.write(contents + os.linesep)

''' read the results file for the JSS '''
def read_result_file(filename):
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            fileContent = f.read()
            print("<result>" + fileContent + "</result>")
            os.remove(filename)
    else:
        print("<result>None</result>")

''' search a file for strings matching the search term '''
def py_grep(fileName, searchTerm):
	matchList = []
	with open(fileName, 'r') as f:
		for line in f:
			if re.findall(searchTerm, line):
				if line.endswith("\n"):
					lineString = line[0:len(line) - 1 ]
					matchList.append(lineString)
				else:
					matchList.append(line)
	matchString = ""
	for i in range(len(matchList)):
		matchString = matchString + " " + matchList[i]
	return(matchString)

''' return the sha 256 hash of a file '''
def sha256_hash(filename):
	bufferSize = 65536
	sha256Hash = hashlib.sha256()
	with open(filename, 'rb') as f:
		while True:
			data = f.read(bufferSize)
			if not data: 
				break
			sha256Hash.update(data)
	sha256hashResult = "{0}".format(sha256Hash.hexdigest())
	return(sha256hashResult)

### SCRIPT
# check the hash of the /etc/rc.common file to see if it has been modified
rcCommonHash = sha256_hash("/etc/rc.common")
if rcCommonHash != rcCommonSha256:
    write_to_file(resultsFile, "*** Hash of /etc/rc.common does not match the default! " + rcCommonHash)

# check /etc/launchd.conf for bsexec commands
if os.path.exists("/etc/launchd.conf"):
    checkBsexec = py_grep("/etc/launchd.conf", "bsexec")
    if not checkBsexec.strip():
        write_to_file(resultsFile, checkBsexec)

# read the results
if len(open(resultsFile)).readlines() == 0:
    os.remove(resultsFile)

read_result_file(resultsFile)
# -----------------------------------------------------------------------------