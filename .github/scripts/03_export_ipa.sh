#!/bin/bash

set -eo pipefail

xcodebuild -archivePath "$PWD/build/SimpleFeed.xcarchive" \
            -exportOptionsPlist "$PWD/.github/scripts/exportOptions.plist" \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
