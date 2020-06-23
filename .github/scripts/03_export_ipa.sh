#!/bin/bash

set -eo pipefail

xcodebuild -archivePath "$PWD/build/SimpleFeed.xcarchive" \
            -exportOptionsPlist "$PWD/.github/secrets/exportOptions.plist" \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
