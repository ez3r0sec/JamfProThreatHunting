#!/usr/bin/python
# -----------------------------------------------------------------------------
# findFileType.py
# find files matching the specified types
# Last Edited: 5/4/22 Julian Thies
# -----------------------------------------------------------------------------

### MODIFY as needed
locationsToSearch = ["/tmp", "/Users"]
searchList = [".sh", ".py", ".exe", ".msi", ".dll", ".jar", ".php", ".lua", ".js", ".jsp", ".deb", ".rpm", ".tar.gz", ".iso", ".7z", ".tar"]


### IMPORTS
import os
import hashlib

### VARIABLES
resultFile = "/tmp/results.txt"

### FUNCTIONS
def append_file(filename, contents):
    with open(filename, 'a') as f:
        f.write(contents + os.linesep)

def read_result_file(filename):
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            fileContent = f.read()
            print("<result>" + fileContent + "</result>")  
    else:
        print("<result>None</result>")

def check_results(filename):
    if os.path.exists(filename):
        fileLength = len(open(filename).readlines())
        if fileLength > 0:
            with open(filename, 'r') as f:
                contents = f.read()
                with open(resultFile, 'a') as f:
                    f.write(contents)
                    
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
	return(hashResult)

# main function
def search_file_type(fileType, searchPath):
    # recursively search for files with .XXX extension
    # generate an outfile for each file extension called
    outfile = "/tmp/" + fileType + ".txt"
    # recursively look through directories with searchPath as the root of the search
    for root, dirs, files in os.walk(searchPath):
        for file in files:
            # use the endswith function to find files with that endingn (bruttle but file magic is hard)
            if file.endswith(fileType):
                # records the full file path
                filePath = os.path.join(root, file)
                # hash the file
                hash = hash_file(filePath)
                # make sure we are doing floating point calcs
                fileSizeKB = os.path.getsize(filePath) / 1000.0
                append_file(outfile, filePath + " HASH: " + hash + " SIZE:" + str(fileSizeKB) + " KB")
    check_results(outfile)

def clean_up(directory, fileType):
    directoryList = os.listdir(directory)
    for i in range(len(directoryList)):
        if directoryList[i].endswith(fileType):
            os.remove(directory + "/" + directoryList[i])

### SCRIPT
for j in range(len(locationsToSearch)):
	for i in range(len(searchList)):
		# for each directory specified above, look for the file types specified above
		search_file_type(locationsToSearch[j], searchList[i])

''' read the results file '''
read_result_file(resultFile)

''' clean up '''
clean_up("/tmp", "txt")
# -----------------------------------------------------------------------------
