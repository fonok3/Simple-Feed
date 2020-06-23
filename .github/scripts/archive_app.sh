#!/bin/bash

set -eo pipefail

xcodebuild -resolvePackageDependencies -workspace ./Simple\ Feed.xcworkspace -scheme Simple\ Feed

xcodebuild  -showbuildsettings
            -workspace Simple\ Feed.xcworkspace \
            -scheme Simple\ Feed \

xcodebuild -workspace Simple\ Feed.xcworkspace \
            -scheme Simple\ Feed \
            -sdk iphoneos \
            -configuration AppStoreDistribution \
            -archivePath $PWD/build/SimpleFeed.xcarchive \
            clean archive | xcpretty
