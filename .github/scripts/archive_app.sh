#!/bin/bash

set -eo pipefail

xcodebuild  -workspace Simple\ Feed.xcworkspace -scheme Simple\ Feed -archivePath $PWD/build/SimpleFeed.xcarchive -sdk iphoneos -configuration Release archive

#xcodebuild -resolvePackageDependencies -workspace ./Simple\ Feed.xcworkspace -scheme Simple\ Feed
#
#xcodebuild  -showBuildSettings
#            -workspace Simple\ Feed.xcworkspace \
#            -scheme Simple\ Feed \
#
#xcodebuild -workspace Simple\ Feed.xcworkspace \
#            -scheme Simple\ Feed \
#            -sdk iphoneos \
#            -configuration AppStoreDistribution \
#            -archivePath $PWD/build/SimpleFeed.xcarchive \
#            clean archive | xcpretty
