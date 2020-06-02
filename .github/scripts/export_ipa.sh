#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/SimpleFeed.xcarchive \
            -exportOptionsPlist Simple\ Feed/SimpleFeed\ iOS/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty