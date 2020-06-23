#!/bin/bash

buildPlist="./Flavors/Simple Feed/Ressources/info.plist"
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$buildPlist")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$buildPlist")
buildNumber=$(($buildNumber + 1))

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$buildPlist"

git commit --all -m "🔖 v$versionNumber - $buildNumber"
git push
