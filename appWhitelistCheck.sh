#!/bin/bash
# -----------------------------------------------------------------------------
# appWhitelistCheck.sh
# check installed apps against app whitelists
# method is not the most effective due to only using file paths and names,
#+ however it could be useful for finding malware
# Last Edited: 5/15/18 Julian Thies
# -----------------------------------------------------------------------------

### VARIABLES
foundFile="/tmp/foundApps.txt"
matchFile="/tmp/match.txt"
resultsFile="/tmp/results.txt"

######### BEGIN WHITELISTS #########

# whitelist of corp-installed apps: modify with apps installed by your org
declare -a Corp_App_Whitelist=(
	"/Applications/Google Chrome.app"
	"/Applications/iMovie.app"
	"/Applications/GarageBand.app"
	"/Applications/Keynote.app"
	"/Applications/Numbers.app"
	"/Applications/Pages.app"
	"/Applications/Self Service.app"
	"/Library/Application Support/JAMF/bin/jamfHelper.app"
	"/Library/Application Support/JAMF/bin/Management Action.app"
	"/Library/Application Support/JAMF/Jamf.app"
	"/Library/Application Support/JAMF/Jamf.app/Contents/MacOS/JamfAAD.app"
)

# declare an array of whitelisted apps that are built into macOS
declare -a Builtin_App_Whitelist=(
	"/Applications/App Store.app"
	"/Applications/Automator.app"
	"/Applications/Automator.app/Contents/Resources/Application Stub.app"
	"/Applications/Calculator.app"
	"/Applications/Calendar.app"
	"/Applications/Chess.app"
	"/Applications/Contacts.app"
	"/Applications/DVD Player.app"
	"/Applications/Dashboard.app"
	"/Applications/Dictionary.app"
	"/Applications/FaceTime.app"
	"/Applications/Font Book.app"
	"/Applications/Image Capture.app"
	"/Applications/Launchpad.app"
	"/Applications/Mail.app"
	"/Applications/Maps.app"
	"/Applications/Messages.app"
	"/Applications/Mission Control.app"
	"/Applications/Notes.app"
	"/Applications/Photo Booth.app"
	"/Applications/Photos.app"
	"/Applications/Preview.app"
	"/Applications/QuickTime Player.app"
	"/Applications/Reminders.app"
	"/Applications/Safari.app"
	"/Applications/Siri.app"
	"/Applications/Stickies.app"
	"/Applications/System Preferences.app"
	"/Applications/TextEdit.app"
	"/Applications/Time Machine.app"
	"/Applications/iBooks.app"
	"/Applications/iTunes.app"
	"/Applications/iTunes.app/Contents/MacOS/iTunesHelper.app"
	"/Applications/Utilities/Activity Monitor.app"
	"/Applications/Utilities/AirPort Utility.app"
	"/Applications/Utilities/Audio MIDI Setup.app"
	"/Applications/Utilities/Bluetooth File Exchange.app"
	"/Applications/Utilities/Boot Camp Assistant.app"
	"/Applications/Utilities/ColorSync Utility.app"
	"/Applications/Utilities/Console.app"
	"/Applications/Utilities/Digital Color Meter.app"
	"/Applications/Utilities/Disk Utility.app"
	"/Applications/Utilities/Grab.app"
	"/Applications/Utilities/Grapher.app"
	"/Applications/Utilities/Keychain Access.app"
	"/Applications/Utilities/Migration Assistant.app"
	"/Applications/Utilities/Script Editor.app"
	"/Applications/Utilities/System Information.app"
	"/Applications/Utilities/Terminal.app"
	"/Applications/Utilities/VoiceOver Utility.app"
	"/Applications/Utilities/VoiceOver Utility.app/Contents/OtherBinaries/VoiceOverUtilityCacheBuilder.app"
)

# whitelist of apps housed in /Library
declare -a Library_App_Whitelist=(
	"/Library/Application Support/Script Editor/Templates/Cocoa-AppleScript Applet.app"
	"/Library/Application Support/Script Editor/Templates/Droplets/Droplet with Settable Properties.app"
	"/Library/Application Support/Script Editor/Templates/Droplets/Recursive File Processing Droplet.app"
	"/Library/Application Support/Script Editor/Templates/Droplets/Recursive Image File Processing Droplet.app"	
	"/Library/Image Capture/Devices/Canon IJScanner2.app"
	"/Library/Image Capture/Devices/Canon IJScanner4.app"
	"/Library/Image Capture/Devices/Canon IJScanner6.app"
	"/Library/Image Capture/Devices/EPSON Scanner.app"
	"/Library/Image Capture/Support/LegacyDeviceDiscoveryHelpers/AirScanLegacyDiscovery.app"
	"/Library/Printers/EPSON/Fax/AutoSetupTool/EPFaxAutoSetupTool.app"
	"/Library/Printers/EPSON/Fax/FaxIOSupport/epsonfax.app"
	"/Library/Printers/EPSON/Fax/Filter/commandFilter.app"
	"/Library/Printers/EPSON/Fax/Filter/rastertoepfax.app"
	"/Library/Printers/EPSON/Fax/Utility/Fax Receive Monitor.app"
	"/Library/Printers/EPSON/Fax/Utility/FAX Utility.app"
	"/Library/Scripts/ColorSync/Embed.app"
	"/Library/Scripts/ColorSync/Extract.app"
	"/Library/Scripts/ColorSync/Match.app"
	"/Library/Scripts/ColorSync/Proof.app"
	"/Library/Scripts/ColorSync/Remove.app"
	"/Library/Scripts/ColorSync/Rename.app"
	"/Library/Scripts/ColorSync/Set Info.app"
	"/Library/Scripts/ColorSync/Show Info.app"
)	

# whitelist of apps housed in /System/Library and other UNIXy directories
declare -a System_App_WhiteList=(
	"/usr/libexec/MiniTerm.app"
	"/System/Library/ColorSync/Calibrators/Display Calibrator.app"
	"/System/Library/CoreServices/AddPrinter.app"
	"/System/Library/CoreServices/AddressBookUrlForwarder.app"
	"/System/Library/CoreServices/AirPlayUIAgent.app"
	"/System/Library/CoreServices/AirPort Base Station Agent.app"
	"/System/Library/CoreServices/AppleFileServer.app"
	"/System/Library/CoreServices/AppleGraphicsWarning.app"
	"/System/Library/CoreServices/AppleScript Utility.app"
	"/System/Library/CoreServices/Applications/About This Mac.app"
	"/System/Library/CoreServices/Applications/Archive Utility.app"
	"/System/Library/CoreServices/Applications/Directory Utility.app"
	"/System/Library/CoreServices/Applications/Feedback Assistant.app"
	"/System/Library/CoreServices/Applications/Folder Actions Setup.app"
	"/System/Library/CoreServices/Applications/Network Utility.app"
	"/System/Library/CoreServices/Applications/RAID Utility.app"
	"/System/Library/CoreServices/Applications/Screen Sharing.app"
	"/System/Library/CoreServices/Applications/Storage Management.app"
	"/System/Library/CoreServices/Applications/System Image Utility.app"
	"/System/Library/CoreServices/Applications/Wireless Diagnostics.app"
	"/System/Library/CoreServices/Automator Runner.app"
	"/System/Library/CoreServices/AVB Audio Configuration.app"
	"/System/Library/CoreServices/backupd.bundle/Contents/Resources/TMHelperAgent.app"
	"/System/Library/CoreServices/Bluetooth Setup Assistant.app"
	"/System/Library/CoreServices/BluetoothUIServer.app"
	"/System/Library/CoreServices/CalendarFileHandler.app"
	"/System/Library/CoreServices/Captive Network Assistant.app"
	"/System/Library/CoreServices/Certificate Assistant.app"
	"/System/Library/CoreServices/cloudphotosd.app"
	"/System/Library/CoreServices/ControlStrip.app"
	"/System/Library/CoreServices/CoreLocationAgent.app"
	"/System/Library/CoreServices/CoreServicesUIAgent.app"
	"/System/Library/CoreServices/Database Events.app"
	"/System/Library/CoreServices/DiscHelper.app"
	"/System/Library/CoreServices/DiskImageMounter.app"
	"/System/Library/CoreServices/Dock.app"
	"/System/Library/CoreServices/Dock.app/Contents/Resources/DashboardClient.app"
	"/System/Library/CoreServices/Dock.app/Contents/Resources/Widget Installer.app"
	"/System/Library/CoreServices/Dwell Control.app"
	"/System/Library/CoreServices/EscrowSecurityAlert.app"
	"/System/Library/CoreServices/Expansion Slot Utility.app"
	"/System/Library/CoreServices/Finder.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/All My Files.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/Computer.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/iCloud Drive.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/Network.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/Recents.app"
	"/System/Library/CoreServices/FolderActionsDispatcher.app"
	"/System/Library/CoreServices/Games.app"
	"/System/Library/CoreServices/HelpViewer.app"
	"/System/Library/CoreServices/iCloud.app"
	"/System/Library/CoreServices/Image Events.app"
	"/System/Library/CoreServices/Install Command Line Developer Tools.app"
	"/System/Library/CoreServices/Install in Progress.app"
	"/System/Library/CoreServices/Installer Progress.app"
	"/System/Library/CoreServices/Installer.app"
	"/System/Library/CoreServices/Jar Launcher.app"
	"/System/Library/CoreServices/Java Web Start.app"
	"/System/Library/CoreServices/KernelEventAgent.bundle/Contents/Resources/FileSystemUIAgent.app"
	"/System/Library/CoreServices/KeyboardSetupAssistant.app"
	"/System/Library/CoreServices/Keychain Circle Notification.app"
	"/System/Library/CoreServices/Language Chooser.app"
	"/System/Library/CoreServices/LocationMenu.app"
	"/System/Library/CoreServices/loginwindow.app"
	"/System/Library/CoreServices/ManagedClient.app"
	"/System/Library/CoreServices/ManagedClient.app/Contents/Resources/MCXDiskAuthorization.app"
	"/System/Library/CoreServices/ManagedClient.app/Contents/Resources/MCXMenuExtraTool.app"
	"/System/Library/CoreServices/Memory Slot Utility.app"
	"/System/Library/CoreServices/Menu Extras/TextInput.menu/Contents/SharedSupport/TISwitcher.app"
	"/System/Library/CoreServices/MRT.app"
	"/System/Library/CoreServices/NetAuthAgent.app"
	"/System/Library/CoreServices/NotificationCenter.app"
	"/System/Library/CoreServices/NowPlayingTouchUI.app"
	"/System/Library/CoreServices/NowPlayingWidgetContainer.app"
	"/System/Library/CoreServices/OBEXAgent.app"
	"/System/Library/CoreServices/ODSAgent.app"
	"/System/Library/CoreServices/OSDUIHelper.app"
	"/System/Library/CoreServices/Paired Devices.app"
	"/System/Library/CoreServices/Pass Viewer.app"
	"/System/Library/CoreServices/Photo Library Migration Utility.app"
	"/System/Library/CoreServices/PIPAgent.app"
	"/System/Library/CoreServices/PowerChime.app"
	"/System/Library/CoreServices/Problem Reporter.app"
	"/System/Library/CoreServices/RapportUIAgent.app"
	"/System/Library/CoreServices/rcd.app"
	"/System/Library/CoreServices/RegisterPluginIMApp.app"
	"/System/Library/CoreServices/RemoteManagement/AppleVNCServer.bundle/Contents/Support/LockScreen.app"
	"/System/Library/CoreServices/RemoteManagement/AppleVNCServer.bundle/Contents/Support/Share Screen Request.app"
	"/System/Library/CoreServices/RemoteManagement/AppleVNCServer.bundle/Contents/Support/SSDragHelper.app"
	"/System/Library/CoreServices/RemoteManagement/ARDAgent.app"
	"/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/Remote Desktop Message.app"
	"/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/Shared Screen Viewer.app"
	"/System/Library/CoreServices/RemoteManagement/ScreensharingAgent.bundle/Contents/Support/SSAssistanceCursor.app"
	"/System/Library/CoreServices/RemoteManagement/ScreensharingAgent.bundle/Contents/Support/SSInvitationAgent.app"
	"/System/Library/CoreServices/RemoteManagement/SSMenuAgent.app"
	"/System/Library/CoreServices/ReportPanic.app"
	"/System/Library/CoreServices/screencapturetb.app"
	"/System/Library/CoreServices/ScreenSaverEngine.app"
	"/System/Library/CoreServices/ScriptMonitor.app"
	"/System/Library/CoreServices/Setup Assistant.app"
	"/System/Library/CoreServices/Siri.app"
	"/System/Library/CoreServices/SocialPushAgent.app"
	"/System/Library/CoreServices/Software Update.app"
	"/System/Library/CoreServices/Software Update.app/Contents/Resources/SoftwareUpdateLauncher.app"
	"/System/Library/CoreServices/Spotlight.app"
	"/System/Library/CoreServices/Stocks.app"
	"/System/Library/CoreServices/System Events.app"
	"/System/Library/CoreServices/SystemUIServer.app"
	"/System/Library/CoreServices/ThermalTrap.app"
	"/System/Library/CoreServices/Ticket Viewer.app"
	"/System/Library/CoreServices/UniversalAccessControl.app"
	"/System/Library/CoreServices/UnmountAssistantAgent.app"
	"/System/Library/CoreServices/UserNotificationCenter.app"
	"/System/Library/CoreServices/VoiceOver.app"
	"/System/Library/CoreServices/Weather.app"
	"/System/Library/CoreServices/WiFiAgent.app"
	"/System/Library/Filesystems/AppleShare/check_afp.app"
	"/System/Library/Filesystems/webdav.fs/Contents/Resources/webdav_cert_ui.app"
	"/System/Library/Frameworks/AddressBook.framework/Versions/A/Helpers/ABAssistantService.app"
	"/System/Library/Frameworks/AddressBook.framework/Versions/A/Helpers/AddressBookManager.app"
	"/System/Library/Frameworks/AddressBook.framework/Versions/A/Helpers/AddressBookSourceSync.app"
	"/System/Library/Frameworks/AddressBook.framework/Versions/A/Helpers/AddressBookSync.app"
	"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/A/Support/FontRegistryUIAgent.app"
	"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/SpeechSynthesis.framework/Versions/A/Resources/SpeechSynthesisServer.app"
	"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/SpeechSynthesis.framework/Versions/A/SpeechSynthesisServer.app"
	"/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/Print.framework/Versions/A/Plugins/PrinterProxy.app"
	"/System/Library/Frameworks/NotificationCenter.framework/Versions/A/Resources/Widget Simulator.app"
	"/System/Library/Frameworks/Python.framework/Versions/2.7/Resources/Python.app"
	"/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuickLookUI.framework/Versions/A/Resources/Quick Look Simulator.app"
	"/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuickLookUI.framework/Versions/A/Resources/QuickLookUIHelper.app"
	"/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd.app"
	"/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd32.app"
	"/System/Library/Frameworks/SyncServices.framework/Versions/A/Resources/SyncServer.app"
	"/System/Library/Frameworks/Tk.framework/Versions/8.5/Resources/Wish Shell.app"
	"/System/Library/Frameworks/Tk.framework/Versions/8.5/Resources/Wish.app"
	"/System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/WebKitLegacy.framework/Versions/A/WebKitPluginHost.app"
	"/System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/WebKitLegacy.framework/WebKitPluginHost.app"
	"/System/Library/Image Capture/Automatic Tasks/Build Web Page.app"
	"/System/Library/Image Capture/Automatic Tasks/MakePDF.app"
	"/System/Library/Image Capture/Devices/AirScanScanner.app"
	"/System/Library/Image Capture/Devices/MassStorageCamera.app"
	"/System/Library/Image Capture/Devices/PTPCamera.app"
	"/System/Library/Image Capture/Devices/Type4Camera.app"
	"/System/Library/Image Capture/Devices/Type5Camera.app"
	"/System/Library/Image Capture/Devices/Type8Camera.app"
	"/System/Library/Image Capture/Devices/VirtualScanner.app"
	"/System/Library/Image Capture/Support/Application/AutoImporter.app"
	"/System/Library/Input Methods/50onPaletteServer.app"
	"/System/Library/Input Methods/AinuIM.app"
	"/System/Library/Input Methods/Assistive Control.app"
	"/System/Library/Input Methods/Assistive Control.app/Contents/Resources/Panel Editor.app"
	"/System/Library/Input Methods/CharacterPalette.app"
	"/System/Library/Input Methods/DictationIM.app"
	"/System/Library/Input Methods/EmojiFunctionRowIM.app"
	"/System/Library/Input Methods/HindiIM.app"
	"/System/Library/Input Methods/InkServer.app"
	"/System/Library/Input Methods/JapaneseIM.app"
	"/System/Library/Input Methods/KeyboardViewer.app"
	"/System/Library/Input Methods/KoreanIM.app"
	"/System/Library/Input Methods/KoreanIM.app/Contents/PlugIns/KIM_Extension.appex/Contents/Resources/HanjaTool.app"
	"/System/Library/Input Methods/PluginIM.app"
	"/System/Library/Input Methods/PressAndHold.app"
	"/System/Library/Input Methods/SCIM.app"
	"/System/Library/Input Methods/TamilIM.app"
	"/System/Library/Input Methods/TCIM.app"
	"/System/Library/Input Methods/TrackpadIM.app"
	"/System/Library/Input Methods/VietnameseIM.app"
	"/System/Library/Java/Support/CoreDeploy.bundle/Contents/Download Java Components.app"
	"/System/Library/PreferencePanes/Displays.prefPane/Contents/Resources/MirrorDisplays.app"
	"/System/Library/PrivateFrameworks/AccessibilitySupport.framework/Versions/A/Resources/AccessibilityVisualsAgent.app"
	"/System/Library/PrivateFrameworks/AmbientDisplay.framework/Versions/A/Resources/Calibration Assistant.app"
	"/System/Library/PrivateFrameworks/AOSAccounts.framework/Versions/A/Resources/iCloudUserNotificationsd.app"
	"/System/Library/PrivateFrameworks/AOSKit.framework/Versions/A/Helpers/AOSAlertManager.app"
	"/System/Library/PrivateFrameworks/AOSKit.framework/Versions/A/Helpers/AOSHeartbeat.app"
	"/System/Library/PrivateFrameworks/AOSKit.framework/Versions/A/Helpers/AOSPushRelay.app"
	"/System/Library/PrivateFrameworks/AskPermission.framework/Versions/A/Resources/AskPermissionUI.app"
	"/System/Library/PrivateFrameworks/CloudDocsDaemon.framework/Versions/A/Resources/iCloud Drive.app"
	"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/LaterAgent.app"
	"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storeuid.app"
	"/System/Library/PrivateFrameworks/CommunicationsFilter.framework/CMFSyncAgent.app"
	"/System/Library/PrivateFrameworks/CoreChineseEngine.framework/Versions/A/SharedSupport/CIMFindInputCodeTool.app"
	"/System/Library/PrivateFrameworks/CoreFollowUp.framework/Versions/A/Resources/FollowUpUI.app"
	"/System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/DiskImages UI Agent.app"
	"/System/Library/PrivateFrameworks/EAP8021X.framework/Support/eaptlstrust.app"
	"/System/Library/PrivateFrameworks/FamilyControls.framework/Versions/A/Resources/ParentalControls.app"
	"/System/Library/PrivateFrameworks/FamilyNotification.framework/Versions/A/Resources/Family.app"
	"/System/Library/PrivateFrameworks/FindMyMac.framework/Versions/A/Resources/FindMyMacMessenger.app"
	"/System/Library/PrivateFrameworks/IDS.framework/identityservicesd.app"
	"/System/Library/PrivateFrameworks/IDSFoundation.framework/IDSRemoteURLConnectionAgent.app"
	"/System/Library/PrivateFrameworks/IMAVCore.framework/imavagent.app"
	"/System/Library/PrivateFrameworks/IMCore.framework/imagent.app"
	"/System/Library/PrivateFrameworks/IMDPersistence.framework/IMAutomaticHistoryDeletionAgent.app"
	"/System/Library/PrivateFrameworks/IMTransferServices.framework/IMTransferAgent.app"
	"/System/Library/PrivateFrameworks/MessagesKit.framework/Versions/A/Resources/soagent.app"
	"/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/AppleMobileDeviceHelper.app"
	"/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/AppleMobileSync.app"
	"/System/Library/PrivateFrameworks/Noticeboard.framework/Versions/A/Resources/nbagent.app"
	"/System/Library/PrivateFrameworks/PubSub.framework/Versions/A/Resources/PubSubAgent.app"
	"/System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/ScreenReaderUIServer.app"
	"/System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/VoiceOver Quickstart.app"
	"/System/Library/PrivateFrameworks/SIUFoundation.framework/Versions/A/XPCServices/com.apple.SIUAgent.xpc/Contents/Resources/AutoPartition.app"
	"/System/Library/PrivateFrameworks/SpeechObjects.framework/Versions/A/SpeechDataInstallerd.app"
	"/System/Library/PrivateFrameworks/SpeechObjects.framework/Versions/A/SpeechRecognitionServer.app"
	"/System/Library/PrivateFrameworks/StorageManagement.framework/Versions/A/Resources/STMUIHelper.app"
	"/System/Library/PrivateFrameworks/SyncServicesUI.framework/Versions/A/Resources/Conflict Resolver.app"
	"/System/Library/PrivateFrameworks/SyncServicesUI.framework/Versions/A/Resources/syncuid.app"
	"/System/Library/PrivateFrameworks/UniversalAccess.framework/Versions/A/Resources/DFRHUD.app"
	"/System/Library/PrivateFrameworks/UniversalAccess.framework/Versions/A/Resources/universalAccessAuthWarn.app"
	"/System/Library/PrivateFrameworks/UniversalAccess.framework/Versions/A/Resources/UniversalAccessHUD.app"
	"/System/Library/PrivateFrameworks/UserActivity.framework/Agents/UASharedPasteboardProgressUI.app"
	"/System/Library/Services/ChineseTextConverterService.app"
	"/System/Library/Services/ImageCaptureService.app"
	"/System/Library/Services/SummaryService.app"
	"/System/Library/UserEventPlugins/BTMMPortInUseAgent.plugin/Contents/Resources/BTMMDisable.app"
	"/System/Library/CoreServices/AppDownloadLauncher.app"
	"/System/Library/CoreServices/Applications/Network Utility.app"
	"/System/Library/CoreServices/FirmwareUpdateHelper.app"
	"/System/Library/CoreServices/Network Diagnostics.app"
	"/System/Library/CoreServices/Network Setup Assistant.app"
	"/System/Library/CoreServices/SecurityFixer.app"
	"/System/Library/CoreServices/ZoomWindow.app"
	"/System/Library/Frameworks/IMServicePlugIn.framework/IMServicePlugInAgent.app"
	"/System/Library/Frameworks/PubSub.framework/Versions/A/Resources/PubSubAgent.app"
	"/System/Library/Frameworks/Python.framework/Versions/2.6/Resources/Python.app"
	"/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app"
	"/System/Library/Frameworks/Tk.framework/Versions/8.4/Resources/Wish Shell.app"
	"/System/Library/Frameworks/Tk.framework/Versions/8.4/Resources/Wish.app"
	"/System/Library/Input Methods/Switch Control.app"
	"/System/Library/Input Methods/Switch Control.app/Contents/Resources/Panel Editor.app"
	"/System/Library/PreferencePanes/DateAndTime.prefPane/Contents/Resources/TimeZone.prefPane/Contents/Resources/timezoned.app"
	"/System/Library/StagedFrameworks/Safari/WebKitLegacy.framework/Versions/A/WebKitPluginHost.app"
	"/System/Library/StagedFrameworks/Safari/WebKitLegacy.framework/WebKitPluginHost.app"
)
########## END WHITELISTS ##########

### FUNCTIONS
function match_list () {
	if [ -z "$1" ] ; then
		echo "<result>An index number for the whitelist was not passed in</result>"
		exit 1
	else
		if [ "$line" == "$1" ] ; then
			echo "$line" >> "$matchFile"
		fi
	fi
}

function check_white_lists {
	cat "$foundFile" | while read line
	do
		# check against each whitelist above
		
		### check against Builtin_App_Whitelist
		for (( i=0; i<${#Builtin_App_Whitelist[@]}; i++ )) ; 
		do
			match_list "${Builtin_App_Whitelist[$i]}"
		done
		### check against Library_App_Whitelist
		for (( i=0; i<${#Library_App_Whitelist[@]}; i++ )) ; 
		do
			match_list "${Library_App_Whitelist[$i]}"
		done
		### check against System_App_Whitelist
		for (( i=0; i<${#System_App_WhiteList[@]}; i++ )) ; 
		do
			match_list "${System_App_WhiteList[$i]}"
		done
		### check against Corp_App_Whitelist
		for (( i=0; i<${#Corp_App_Whitelist[@]}; i++ )) ; 
		do
			match_list "${Corp_App_Whitelist[$i]}"
		done

		# check for non-matches
		if [ -e "$matchFile" ] ; then
			# if there is a match, throw it away
			rm "$matchFile"
		else
			# if there is no match, hash it and present it
			hashPath="$(ls -1 "$line/Contents/MacOS")"
			sha256="$(shasum -a 256 "$line/Contents/MacOS/$hashPath" | awk '$1 {print $1}')"
			echo "$line  -- SHA256:  $sha256" >> "$resultsFile"
		fi
	done
}

function read_results {
	buildResult="$(cat $resultsFile)"
	echo "<result>$buildResult</result>"
}

### SCRIPT
# find all of the .apps on the system
sudo find / -name *.app >> "$foundFile"

# check the found apps against the white lists
check_white_lists

# display the results to the JSS
read_results

# clean up
rm "$foundFile"

if [ -e "$resultsFile" ] ; then
	rm "$resultsFile"
fi
