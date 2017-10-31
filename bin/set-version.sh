#!/bin/sh

#  set-version.sh
#  Filestack
#
#  Created by Ruben Nine on 7/5/17.
#  Copyright © 2017 Filestack. All rights reserved.

infoplist="$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"
shortVersionString=$(cat $SRCROOT/VERSION)

if [ -z "$shortVersionString" ]; then
    echo "Failed to set shortVersionString."
    exit 1
fi

/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $shortVersionString" "$infoplist"
