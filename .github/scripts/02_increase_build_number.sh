#!/bin/bash

# increase-build-number.sh
# @desc Auto-increment the build number every time the project is run and add build information to plist
# @usage
# 1. Select: your Target in Xcode
# 2. Select: Build Phases Tab
# 3. Select: Add Build Phase -> Add Run Script
# 4. Paste code below in to new "Run Script" section
# 5. Drag the "Run Script" below "Link Binaries With Libraries"
# 6. Insure that your starting build number is set to a whole integer and not a float (e.g. 1, not 1.0)

buildPlist="./Flavors/Simple Feed/Ressources/info.plist"
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$buildPlist")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$buildPlist"

# Create dictionary BuildEnvironment to keep Info.plist tidy
/usr/libexec/PlistBuddy -c "Add :BuildEnvironment dict" "$buildPlist"

# Time and date
date=`date`
/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildDate string" "$buildPlist"
/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:BuildDate $date" "$buildPlist"

# Git name and mail, e.g. "Jan-Gerd Tenberge (janten@gmail.com)"
gitName=`git config --global user.name`
gitMail=`git config --global user.email`
/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:GitUser string" "$buildPlist"
/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:GitUser $gitName ($gitMail)" "$buildPlist"

# Current git commit identifier as SHA-1 hash
gitRev=`git rev-parse HEAD`
echo "Revision is $gitRev"
/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:GitRef string" "$buildPlist"
/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:GitRef $gitRev" "$buildPlist"

# Users full name and username, e.g. "Jan-Gerd Tenberge (janten)"
longname="$(dscacheutil -q user -a name $(whoami) | fgrep gecos | sed -e 's/.*gecos: \(.*\)/\1/')"
/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildUser string" "$buildPlist"
/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:BuildUser $longname ($USER)" "$buildPlist"

# Create dictionary for build machine details name, model, hostname and UUID
/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildMachine dict" "$buildPlist"

	# Computer's name, e.g. "Jan-Gerds MacBook"
	computerName=`scutil --get ComputerName`
	/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildMachine:Name string" "$buildPlist"
	/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:BuildMachine:Name $computerName" "$buildPlist"

	# Computer's model, e.g. "MacBookPro10,2"
	computerModel=`sysctl -b hw.model`
	/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildMachine:Model string" "$buildPlist"
	/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:BuildMachine:Model $computerModel" "$buildPlist"

	# Current hostname, e.g. "macbook.jan-gerd.com"
	host=`hostname`
	/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildMachine:Hostname string" "$buildPlist"
	/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:BuildMachine:Hostname $host" "$buildPlist"

	# An unique identifier for the build machine, same as used for provisioning profiles
	computerUUID=`ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { split($0, line, "\""); printf("%s\n", line[4]); }'`
	/usr/libexec/PlistBuddy -c "Add :BuildEnvironment:BuildMachine:UUID string" "$buildPlist"
	/usr/libexec/PlistBuddy -c "Set :BuildEnvironment:BuildMachine:UUID $computerUUID" "$buildPlist"

