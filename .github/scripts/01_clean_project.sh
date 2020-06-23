#!/bin/bash

set -eo pipefail

xcodebuild -workspace Simple\ Feed.xcworkspace \
            -scheme Simple\ Feed \
            -sdk iphoneos \
            -configuration Release \
            clean
