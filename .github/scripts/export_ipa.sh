#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/SimpleFeed.xcarchive \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
