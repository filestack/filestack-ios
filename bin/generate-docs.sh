#!/usr/bin/env bash
set -o errexit #abort if any command fails

swift doc generate Sources --module-name Filestack --format html --output docs
# jazzy --build-tool-arguments -Xswiftc,-sdk,-Xswiftc,$(xcrun --sdk iphonesimulator --show-sdk-path),-Xswiftc,-target,-Xswiftc,"x86_64-apple-ios11.0-simulator"
