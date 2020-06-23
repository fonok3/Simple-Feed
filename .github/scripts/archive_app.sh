#!/bin/bash

set -eo pipefail

xcodebuild -resolvePackageDependencies -workspace ./Simple\ Feed.xcworkspace -scheme Simple\ Feed

xcodebuild  -showBuildSettings \
            -workspace Simple\ Feed.xcworkspace \
            -scheme Simple\ Feed \

xcodebuild  -workspace Simple\ Feed.xcworkspace \
            -scheme Simple\ Feed \
            -destination 'gerneric/platform=iOS' \
            -configuration AppStoreDistribution \
            -archivePath $PWD/build/SimpleFeed.xcarchive \
            clean archive | xcpretty
