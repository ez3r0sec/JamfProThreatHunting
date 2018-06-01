#!/usr/bin/python
# -----------------------------------------------------------------------------
# findFileType.py
# find files matching the specified types
# Last Edited: 6/1/18 Julian Thies
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

def search_file_type(fileType, searchPath):    # recursively search for files with .XXX extension
     outfile = "/tmp/" + fileType + ".txt"                        # generate an outfile for each file extension called
     for root, dirs, files in os.walk(searchPath):                # recursively look through directories with searchPath as the root of the search
          for file in files:
               if file.endswith(fileType):                        # use the endswith function to find files with that ending
            	     filePath = os.path.join(root, file)           # records the full file path
                    fileSizeKB = os.path.getsize(filePath) / 1000000.0 # make sure we are doing floating point calcs
            	     append_file(outfile, os.path.join(root, file) + "   ==   " + str(fileSizeKB) + " KB")
     check_results(outfile)

def clean_up(directory, fileType):
     directoryList = os.listdir(directory)          
     for i in range(len(directoryList)):
          if directoryList[i].endswith(fileType):
               os.remove(directory + "/" + directoryList[i])

### SCRIPT
''' write a new function call for each file type '''
#search_file_type("file extension", "search directory")
search_file_type("sh", "/tmp")
search_file_type("sh", "/Users")
search_file_type("py", "/tmp")
search_file_type("py", "/Users")
search_file_type("exe", "/tmp")
search_file_type("exe", "/Users")
search_file_type("msi", "/tmp")
search_file_type("msi", "/Users")
search_file_type("dll", "/tmp")
search_file_type("dll", "/Users")
search_file_type("jar", "/tmp")
search_file_type("jar", "/Users")
search_file_type("php", "/tmp")
search_file_type("php", "/Users")
search_file_type("lua", "/tmp")
search_file_type("lua", "/Users")
search_file_type("js", "/tmp")
search_file_type("js", "/Users")
search_file_type("jsp", "/tmp")
search_file_type("jsp", "/Users")
search_file_type("deb", "/tmp")
search_file_type("deb", "/Users")
search_file_type("rpm", "/tmp")
search_file_type("rpm", "/Users")
search_file_type("tar.gz", "/tmp")
search_file_type("tar.gz", "/Users")
search_file_type("iso", "/tmp")
search_file_type("iso", "/Users")
search_file_type("7z", "/tmp")
search_file_type("7z", "/Users")
search_file_type("tar", "/tmp")
search_file_type("tar", "/Users")

''' read the results file '''
read_result_file(resultFile)

''' clean up '''
clean_up("/tmp", "txt")
# -----------------------------------------------------------------------------
