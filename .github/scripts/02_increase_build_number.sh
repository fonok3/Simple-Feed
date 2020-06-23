#!/bin/bash

buildPlist="./Flavors/Simple Feed/Ressources/info.plist"
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$buildPlist")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$buildPlist")
buildNumber=$(($buildNumber + 1))

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$buildPlist"

#git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
#git pull github ${GITHUB_REF} --ff-only
#
#git commit --all -m "🔖 v$versionNumber - $buildNumber"
#git push github HEAD:${GITHUB_REF}
