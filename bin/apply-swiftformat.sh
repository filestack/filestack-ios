#!/bin/sh

if ! which swiftformat >/dev/null; then
    if which brew >/dev/null; then
        brew update && brew install swiftformat
    else
        echo "WARNING: Tried to automatically install SwiftFormat using `brew` but `brew` itself could not be found. Please install SwiftFormat manually and try again."
    fi
fi

if which swiftformat >/dev/null; then
    swiftformat .
else
    echo "WARNING: SwiftFormat is missing. Please install it manually and try again."
fi
