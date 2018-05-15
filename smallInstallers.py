#!/usr/bin/python
# -----------------------------------------------------------------------------
# smallInstallers.py
# Look for installer files smaller than a reasonable threshold for legitimate software
# Last Edited: 5/15/18 Julian Thies
# -----------------------------------------------------------------------------

### IMPORTS
import os.path

### FUNCTIONS
def check_file_contents(filename):
     if os.path.exists(filename):
          with open(filename, 'r') as contents:
               fileContent = contents.read()
          print("<result>" + fileContent + "</result>")
     else:
          print("File does not exist")

def write_file(fileName, contents):
     with open(fileName, 'a') as f:
          f.write(contents + os.linesep)

def search_file_type(fileType, searchPath, fileSizeThreshold):    # recursively search for files with .XXX extension
     fileTypeSizeKB = 0                                           # initialize a storage variable for size in KB
     for root, dirs, files in os.walk(searchPath):                # recursively look through directories with searchPath as the root of the search
          for file in files:
               if file.endswith(fileType):                        # use the endswith function to find files with that ending
                    filePath = os.path.join(root, file)           # records the full file path
                    fileSizeKB = os.path.getsize(filePath) / 1000 # convert to KB
                    if fileSizeKB < fileSizeThreshold:            # flag files less than the specified size threshold
                         posResult = os.path.join(root, file) + " == " + str(fileSizeKB) + " KB"
                         write_file("/tmp/smallInstallers.txt", posResult)

### SCRIPT
search_file_type(".dmg", "/", 10000)     # look for dmgs smaller than 10 MB
search_file_type(".pkg", "/", 5000)      # look for pkgs smaller than 5 MB

fileLength = len(open("/tmp/smallInstallers.txt").readlines(  ))
# if there are files matching the above criteria, print the file
if fileLength > 0:
     check_file_contents("/tmp/smallInstallers.txt")
else:
     print("<result>None</result>")

os.remove("/tmp/smallInstallers.txt")
# -----------------------------------------------------------------------------
