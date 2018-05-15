#!/usr/bin/python
# -----------------------------------------------------------------------------
# detectFirefoxExtensions.py
# look for safari extensions
# Last Edited: 4/2/18
# -----------------------------------------------------------------------------

### IMPORTS
import os
import hashlib

### VARIABLES
resultsFile = "/tmp/xpi.txt"

### FUNCTIONS
''' function to write results line by line '''
def write_to_file(filepath, contents):
     with open(filepath, 'a') as f:
          f.write(contents + os.linesep)

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

''' search for files matching the specified file type'''
def search_file_type(fileType, searchPath):
     fileTypeCounter = 0
     for root, dirs, files in os.walk(searchPath):
          for file in files:
               if file.endswith(fileType):
                    fileTypeCounter = fileTypeCounter + 1
                    filePath = os.path.join(root, file)
                    fileHash = hash_file(filePath)
                    write_to_file(resultsFile, filePath + " -- SHA256: " + fileHash)

''' read the results file for the JSS '''
def read_result_file(filename):
     if os.path.exists(filename):
          with open(filename, 'r') as f:
               fileContent = f.read()
          print("<result>" + fileContent + "</result>")
     else:
          print("<result>None</result>")

### SCRIPT
search_file_type("XPI", "/")
read_result_file(resultsFile)
os.remove(resultsFile)
