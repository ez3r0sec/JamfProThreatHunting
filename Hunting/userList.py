#!/usr/bin/python
# -----------------------------------------------------------------------------
# userList.py
# check the list of users below UID 501 and display it to the JAMF server
# make a smart group and whitelist known users in the criteria section
# Last Edited: 11/13/18 Julian Thies
# -----------------------------------------------------------------------------

### IMPORTS
import os
import subprocess

### VARIABLES
results_file = "/tmp/user_table.txt"

### FUNCTIONS
''' function to read the results file to display to JAMF '''
def readResultFile(filename):
	if os.path.exists(filename):
		with open(filename, 'r') as f:
	        	fileContent = f.read()
		print("<result>" + fileContent + "</result>")
		os.remove(filename)
	else:
		print("<result>None</result>")

''' function to write results line by line '''
def writeToFile(filepath, contents):
	with open(filepath, 'a') as f:
		f.write(contents + os.linesep)

### SCRIPT
# collect the dscl user/id# table (result is a string)
user_string = subprocess.check_output(["dscl", ".", "-list", "/Users", "UniqueID"])
# split the string by newline characters (list of strings in this format: [...,username     id,...])
user_list_table = user_string.split("\n")
# initialize a dictionary to store the results
user_list_dict = {}
# loop through the list of strings and split the username from the id and place in a dictionary
for i in range(len(user_list_table)):
	# split the string that contains the username and id number into a list with entries for each
	field_list = user_list_table[i].split()
	# the first entry is the username, the second entry is the id number
	if len(field_list) == 2:
		if int(field_list[1]) <= 500:
			user_list_dict[field_list[0]] = field_list[1]
			writeToFile(results_file, field_list[0] + ": " + field_list[1])
		else:
			pass
	else:
		pass

# read the results file to JAMF
readResultFile(results_file)
		
# -----------------------------------------------------------------------------