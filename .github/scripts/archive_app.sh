#!/bin/bash

set -eo pipefail

xcodebuild  -workspace Simple\ Feed.xcworkspace -scheme Simple\ Feed -archivePath $PWD/build/SimpleFeed.xcarchive -sdk iphoneos -configuration Release archive
