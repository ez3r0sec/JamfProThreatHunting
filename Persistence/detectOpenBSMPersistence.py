#!/usr/bin/python
# -----------------------------------------------------------------------------
# detectOpenBSMPersistence.py
# detect any changes to the audit_control and audit_warn files in /etc/security
# Last Edited: 7/25/18
# -----------------------------------------------------------------------------

### IMPORTS
import os
import hashlib

### VARIABLES
results = "/tmp/results"

# default sha256 hashes on macOS 10.13.6
AWHash = "d4a58e12a2e3a9aa4ca72cbe4c63b786b20d6a212a87759f6c93db594be3e3f0"
ACHash = "a435a0896584aa258238633315ab70b34ff9c64aa5c8c3cf93490aa2ca319917"

### FUNCTIONS
def print_result(content):
	print("<result>" + content + "</result>")
	
''' function to write results line by line '''
def write_to_file(filepath, contents):
	with open(filepath, 'a') as f:
		f.write(contents + os.linesep)

''' read the results file '''
def read_result_file(filename):
	if os.path.exists(filename):
		if len(open(filename).readlines()) > 0:
			with open(filename, 'r') as f:
				fileContent = f.read()
				print("<result>" + fileContent + "</result>")
			os.remove(filename)
		else:
			print("<result>None</result>")
			os.remove(filename)
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
	return(hashResult)

''' check a file against it's expected hash '''
def check_hash(filename, hash):
	if os.path.exists(filename):
		fileHash = hash_file(filename)
		if fileHash != hash:
			return(fileHash)
		else:
			return(True)
	else:
		return(str(filename + " not found"))

### SCRIPT
auditWarn = check_hash("/etc/security/audit_warn", AWHash)
auditControl = check_hash("/etc/security/audit_control", ACHash)

if auditWarn and auditControl ==  True:
	print_result("None")
else:
	write_to_file(results, auditWarn)
	write_to_file(results, auditControl)
	read_result_file(results)
	
# -----------------------------------------------------------------------------
