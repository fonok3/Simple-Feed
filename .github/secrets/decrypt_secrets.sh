#!/bin/sh
set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS_PROVISIONING" --output ./.github/secrets/Simple_Feed.mobileprovision ./.github/secrets/Simple_Feed.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS_CERTIFICATE" --output ./.github/secrets/Simple_Feed_Distribution.cer ./.github/secrets/Simple_Feed_Distribution.cer.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/Simple_Feed.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/Simple_Feed.mobileprovision


security create-keychain -p "" build.keychain
security import ./.github/secrets/Simple_Feed_Distribution.cer -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain