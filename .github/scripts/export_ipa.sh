#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/SimpleFeed.xcarchive \
            -exportOptionsPlist $PWD/build/SimpleFeed.xcarchive/info.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
