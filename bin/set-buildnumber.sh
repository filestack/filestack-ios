#!/bin/sh

#  set-buildnumber.sh
#  Filestack
#
#  Created by Ruben Nine on 7/5/17.
#  Copyright © 2017 Filestack. All rights reserved.

infoplist="$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"
buildnum=$(git --git-dir="$SRCROOT/.git" log --oneline | wc -l | tr -d '[:space:]')

if [ -z "$buildnum" ]; then
    echo "Failed to set buildNum."
    exit 1
fi

/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildnum" "$infoplist"
