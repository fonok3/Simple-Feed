
#!/bin/bash

set -eo pipefail

xcodebuild -workspace Simple\ Feed.xcodeproj \
            -scheme Simple\ Feed \
            -destination platform=iOS\ Simulator,OS=13.3,name=iPhone\ 11 \
            clean test | xcpretty
