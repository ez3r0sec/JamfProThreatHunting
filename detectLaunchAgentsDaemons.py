#!/usr/bin/python
# -----------------------------------------------------------------------------
# detectLaunchAgentsDaemons.py
# display launch agents and daemons
# Last Edited: 5/3/2018
# -----------------------------------------------------------------------------
import os
import glob
# ---------------- global variables
daemonFile = "/tmp/daemons.txt"
agentFile = "/tmp/agents.txt"
resultFile = "/tmp/results.txt"

userList = glob.glob('/Users/*')
# ---------------- functions
def write_directory_contents(filename, directory):
     if os.path.exists(directory):
          directoryList = os.listdir(directory)          
          for i in range(len(directoryList)):
               with open(filename, 'a') as f:
                    f.write(directory + "/" + directoryList[i] + os.linesep)

def multi_users_loop(filename, userList, osPath):
    for i in range(len(userList)):
         write_directory_contents(filename, userList[i] + osPath)

def check_results(filename):
     fileLength = len(open(filename).readlines())
     if fileLength > 0:
          with open(filename, 'r') as f:
               contents = f.read()
               with open(resultFile, 'a') as f:
                    f.write(contents)
     os.remove(filename)

def read_result_file(filename):
     if os.path.exists(filename):
          with open(filename, 'r') as f:
               fileContent = f.read()
          print("<result>" + fileContent + "</result>")
          os.remove(filename)
     else:
          print("<result>None</result>")

# ---------------- script
''' Launch Daemons '''
write_directory_contents(daemonFile, "/Library/LaunchDaemons")
multi_users_loop(daemonFile, userList, "/Library/LaunchDaemons")

''' Launch Agents '''
write_directory_contents(agentFile, "/Library/LaunchAgents")
multi_users_loop(agentFile, userList, "/Library/LaunchAgents")

''' check if there are LDs or LAs '''
check_results(daemonFile)
check_results(agentFile)

''' read results '''
read_result_file(resultFile)
# -----------------------------------------------------------------------------
