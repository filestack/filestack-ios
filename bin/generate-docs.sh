#!/usr/bin/env bash
set -o errexit #abort if any command fails

swift doc generate Sources --module-name Filestack --format html --output docs --base-url https://filestack.github.io/filestack-ios/
