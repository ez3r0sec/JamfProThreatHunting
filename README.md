# JamfProThreatHunting

The work hosted here is designed as Extension Attribute scripts to facilitate malware hunting using the inventory collection 
capabilites of the JSS. Many suspicious indicators can be collected using scripts so that administrators or security 
personnel can find malware installed on managed devices. 

If the suspicious indicator is not found, the scripts are written to return 'None' to the JSS. Setting an "all clear" result 
as none across scripts allows allows for flexible grouping of criteria to generate smart groups. Smart groups could be
constructed for each script individually, or scripts can be grouped into smart groups for high-medium-low indicator ratings
based on the perceived amount of risk. For example, if the sudoers file has been edited with 'defaults !tty_tickets' or there 
are root crontabs that run unknown files, that machine has likely been owned and is a risk that should be dealt with 
immediately. If there are just a few .jar files on a machine, it may be of less concern and could be placed in a medium or 
lower risk-level smart group. In either case, each device in the smart group can then be investigated further within 
the JSS or with other custom scripts such as Yelp's osxcollector (https://github.com/Yelp/osxcollector), requestFileInfo.sh, 
and forensicsAndLogCollection.sh scripts in the repository. 

Certain settings in the JSS and practices may also ease malware hunting. Some general recommendations are to:

  0. Implement the CIS Benchmarks for macOS (hxxps://github[.]com/jamfprofessionalservices/CIS-for-macOS-Sierra) and 
     maintain security settings using policies and smart groups in the JSS to manage desired state of security 
     configurations. Doing so will not only aid hunting, the general security posture of your managed fleet will be much
     stronger.
  
  1. Restrict the directories from which apps are allowed to run to /Applications and ~/Library in a configuration profile.
     Certain applications have components that run from subdirectories of ~/Library and with careful testing, even more 
     strict launch directories can be specified to further control where malware can persistently execute.
     
  2. Increase Computer Inventory Collection of .apps by adding custom search paths such as ~/Applications and ~/Library or 
     even ~/ and/or use the findFileType.py script template looking only for .app files and make a separate smart group.
     
  3. After increasing the directories monitored for .app bundles, start constructing a smart group of known malware .app 
     bundles that is updated periodically as new items are found and new .app indicators of compromise are released by the 
     macOS security community. 
     
  4. Use the Restricted Software function of the JSS to block known malicious .app files from running in your environment and 
     set up email notifications if the application attempted to run. Also make sure that you supply a message to the user 
     when malicious .apps attempt to run so that the proper incident response procedures may be followed. The addition of new 
     IOCs to the Restricted Software records and smart group criteria can be be scripted using the Jamf API.
     
  5. One way to isolate a machine when malware is detected is to scope a configuration profile that sets the curfew in 
     parental controls to allow login for only 1 minute and scope a script to turn off active network interfaces.
     
  6. Use the appWhitelistCheck.sh script to check for unknown .apps in your environment. This will take a considerable amount
     of tuning, however, once properly tuned, new malware that is in a .app bundle will be easy to find.
