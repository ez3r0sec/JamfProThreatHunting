#!/usr/bin/python
# -----------------------------------------------------------------------------
# findFileType.py
# find files matching the specified types
# Last Edited: 5/15/18 Julian Thies
# -----------------------------------------------------------------------------

### IMPORTS
import os

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

def search_file_type(fileType, searchPath, fileSizeThreshold):    # recursively search for files with .XXX extension
     outfile = "/tmp/" + fileType + ".txt"                        # generate an outfile for each file extension called
     for root, dirs, files in os.walk(searchPath):                # recursively look through directories with searchPath as the root of the search
          for file in files:
               if file.endswith(fileType):                        # use the endswith function to find files with that ending
            	     filePath = os.path.join(root, file)           # records the full file path
            	     fileSizeKB = os.path.getsize(filePath) / 1000000 # convert to MB
                    if fileSizeKB > fileSizeThreshold:            # flag files greater than the specified size threshold
                         append_file(outfile, "*LARGE FILE* " + os.path.join(root, file) + "   ==   " + str(fileSizeKB) + " KB")
                    else:
            	         append_file(outfile, os.path.join(root, file) + "   ==   " + str(fileSizeKB) + " KB")
     check_results(outfile)

def clean_up(directory, fileType):
     directoryList = os.listdir(directory)          
     for i in range(len(directoryList)):
          if directoryList[i].endswith(fileType):
               os.remove(directory + "/" + directoryList[i])

### SCRIPT
''' write a new function call for each file type '''

search_file_type("sh", "/tmp", 1)
search_file_type("sh", "/Users", 1)
search_file_type("py", "/tmp", 1)
search_file_type("py", "/Users", 1)
search_file_type("exe", "/tmp", 2)
search_file_type("exe", "/Users", 2)
search_file_type("msi", "/tmp", 1)
search_file_type("msi", "/Users", 2)
search_file_type("dll", "/tmp", 2)
search_file_type("dll", "/Users", 2)
search_file_type("jar", "/tmp", 1)
search_file_type("jar", "/Users", 1)
search_file_type("php", "/tmp", 1)
search_file_type("php", "/Users", 1)
search_file_type("lua", "/tmp", 1)
search_file_type("lua", "/Users", 1)
search_file_type("js", "/tmp", 1)
search_file_type("js", "/Users", 1)
search_file_type("jsp", "/tmp", 1)
search_file_type("jsp", "/Users", 1)
search_file_type("deb", "/tmp", 2)
search_file_type("deb", "/Users", 2)
search_file_type("rpm", "/tmp", 2)
search_file_type("rpm", "/Users", 2)
search_file_type("tar.gz", "/tmp", 5)
search_file_type("tar.gz", "/Users", 5)
search_file_type("iso", "/tmp", 50)
search_file_type("iso", "/Users", 50)
search_file_type("7z", "/tmp", 2)
search_file_type("7z", "/Users", 2)
search_file_type("tar", "/tmp", 2)
search_file_type("tar", "/Users", 2)

''' read the results file '''
read_result_file(resultFile)

''' clean up '''
clean_up("/tmp", "txt")
# -----------------------------------------------------------------------------
