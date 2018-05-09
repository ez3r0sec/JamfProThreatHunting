# JamfProThreatHunting

The work hosted here is designed as Extension Attribute scripts to facilitate malware hunting using the inventory collection 
capabilites of the JSS. Many suspicious indicators can be collected using scripts so that administrators or security personel
can find malware installed on managed devices. 

If the suspicious indicator is not found, the scripts should be written to return 'None' to the JSS which allows for one 
smart group to encompass all of the extension attributes with the criteria of 'is not - None' for each attribute. Each device 
in the smart group can then be investigate further within the JSS. An alternate method is to set up smart groups based on the 
perceived amount of risk. For example, if the sudoers file has been edited with 'defaults !tty_tickets' or there are root 
crontabs, that machine has likely been owned and is a risk that should be dealt with immediately. If there are just a few 
.jar files on a machine, it may be of less concern and could be placed in a medium or lower threat-level smart group.

Certain settings in the JSS and practices may also ease malware hunting. Some general recommendations are to:

  0. Implement the CIS Benchmarks for macOS (hxxps://github[.]com/jamfprofessionalservices/CIS-for-macOS-Sierra) and 
     maintain security settings using policies and smart groups in the JSS to manage desired state of security 
     configurations.
  
  1. Restrict the directories from which apps are allowed to run to /Applications and ~/Library in a configuration profile.
     Certain applications have components that run from subdirectories of ~/Library and with careful testing, even more 
     strict launch directories can be specified.
     
  2. Increase Computer Inventory Collection of .apps by adding custom search paths such as ~/Applications and ~/Library or 
     even ~/.
     
  3. After increasing the directories monitored for .app bundles, start constructing a smart group of known malware .app 
     bundles that is updated periodically as new items are found and new .app indicators of compromise are released by the 
     macOS security community.
     
  4. Use the Restricted Software function of the JSS to block known malicious .app files from running in your environment and 
     set up email notifications if the application attempted to run. Also make sure that you supply a message to the user 
     when malicious .apps attempt to run so that the proper incident response procedures may be followed.
     
  5. One way to isolate a machine when malware is detected is to scope a configuration profile that sets the curfew in 
     parental controls to allow login for only 1 minute and scope a script to turn off active network interfaces.
     
  6. Use the appWhitelistCheck.sh script to check for unknown .apps in your environment. This will take a considerable amount
     of tuning, however, once properly tuned, new malware that is in a .app bundle will be easy to find.
