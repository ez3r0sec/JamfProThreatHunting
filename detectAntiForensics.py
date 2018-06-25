#!/usr/bin/python
# detectAntiForensics.py
# attempt to detect anti-forensic/detection techniques on macOS
# Last Edited: 6/25/17 Julian Thies

### IMPORTS
import os

### VARIABLES
results = "/tmp/results"

### FUNCTIONS
''' function to write results line by line '''
def write_to_file(filepath, contents):
     with open(filepath, 'a') as f:
          f.write(contents + os.linesep)

def read_result_file(filename):
	if os.path.exists(filename):
		if len(open(filename).readlines()) > 0:
			with open(filename, 'r') as f:
				fileContent = f.read()
				print("<result>" + fileContent + "</result>")
		else:
			print("<result>None</result>")
		os.remove(filename)
	else:
		print("<result>None</result>")

##### anti-forensic technique detection
''' functions to look for anti-forensics and detection techniques '''
def check_fseventsd(outputfile):
	# fsevents record when files are created, modified, or deleted on a volume
	# hxxps://www.crowdstrike[.]com/blog/using-os-x-fsevents-discover-deleted-malicious-artifact/
	if os.path.exists("/.fseventsd/no_log"):
		write_to_file(outputfile, "*** no_log file detected in /.fseventsd.")

### SCRIPT
check_fseventsd(results)
# addtl technique detections to come
read_result_file(results)
