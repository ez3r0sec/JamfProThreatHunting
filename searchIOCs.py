#!/usr/bin/python
# -----------------------------------------------------------------------------
# searchIOCs.py
# extension attribute script that can be crafted to search for various specific IOCs in an ad hoc manner
# Last Edited: 7/18/18 Julian Thies
# -----------------------------------------------------------------------------

### IMPORTS
import os
import re
import hashlib

### VARIABLES
resultsFile = "/tmp/results.txt"

### FUNCTIONS
### base functions
''' function to write results line by line '''
def write_to_file(filepath, contents):
     with open(filepath, 'a') as f:
          f.write(contents + os.linesep)

''' read the results file for the JSS '''
def read_result_file(filename):
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            fileContent = f.read()
        print("<result>" + fileContent + "</result>")
    else:
        print("<result>None</result>")

''' take a sha256 hash of found files '''
def hash_file(filename):
    bufferSize = 65536
    sha256Hash = hashlib.sha256()
    with open(filename, 'rb') as f:
        while True:
            data = f.read(bufferSize)
            if not data: 
                break
            sha256Hash.update(data)
    hashResult = "{0}".format(sha256Hash.hexdigest())
    return hashResult

''' use the Regular Expression module to find all lines matching the input search term '''
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
		matchString = matchString + "," + matchList[i]
	return(matchString)

### IOC searching functions
# look for a specific file
def find_file(filepath):
    write_to_file(resultsFile, "Find file " + filepath)
    if os.path.exists(filepath):
		fileHash = hash_file(filepath)
		write_to_file(resultsFile, filepath + "," + fileHash)
    else:
        write_to_file(resultsFile, "File " + filepath + "  not found")
		
# look at all the files in a specific directory
def survey_dir(path):
    write_to_file(resultsFile, "Survey " + path + " directory")
    if os.path.exists(path):
        for path, dirs, files in os.walk(path):
            for file in files:
                fp = os.path.join(path, file)
                fileHash = hash_file(fp)
                write_to_file(resultsFile, fp + "," + fileHash)
    else:
        write_to_file(resultsFile, "Path "+ path + " does not exist")

# look for a specific hash (sha256)
def find_hash(searchPath, sha256hash):
    path = searchPath
    write_to_file(resultsFile, "Looking for " + sha256hash + " in path " + searchPath)
    if os.path.exists(searchPath):
        for path, dir, files in os.walk(path):
            for file in files:
                fp = os.path.join(path, file)
                fileHash = hash_file(fp)
                if fileHash == sha256hash:
                    write_to_file(resultsFile, "Hash " + sha256hash + " found at " + fp)
                else:
                    pass
    else:
        write_to_file(resultsFile, "Path " + searchPath + " does not exist")


# look for network connections to a specific IP -- currently nonfunctional
def network_connections(ip):
    write_to_file(resultsFile, "Looking for active network connections to " + ip)
    # only import these modules if the function is called
    import time
    import random
    import subprocess
    # use some bash commands to complete this task
    # NOTE will not show ICMP traffic if using netstat
    # open a file to catch the results
    nwFileName = "/tmp/network.txt"
    netwFile = open(nwFileName, "w")
    c = 0
    while c < 10:
        # call netstat at a random interval between 1 and 20 seconds and send to output file
        subprocess.call(['netstat', '-peanutw'], stdout=netwFile)
        time.sleep(random.randint(1,20))
        c = c + 1
    # search for the IP using regex
    host = py_grep(nwFileName, ip)
    # check if the var is an empty str
    if not host:
        write_to_file(resultsFile, "No network connections to " + ip + " detected")
    else:
        write_to_file(resultsFile, host)
    netwFile.close()
    #os.remove(netwFile)

# look for filetypes by a particular extension (fragile)
''' search for files matching the specified file type'''
def search_file_type(fileType, searchPath):
    write_to_file(resultsFile, "Searching for all " + fileType + " files")
    for root, dirs, files in os.walk(searchPath):
        for file in files:
            if file.endswith(fileType):
                filePath = os.path.join(root, file)
                fileHash = hash_file(filePath)
                write_to_file(resultsFile, filePath + "," + fileHash)


### SCRIPT
# make the function calls you want here

#find_file()
#survey_dir()
#find_hash()
network_connections("8.8.8.8")
#search_file_type()

### DO NOT MODIFY
read_result_file(resultsFile)
# -----------------------------------------------------------------------------
