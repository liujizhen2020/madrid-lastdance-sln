#!/bin/bash

agvtool -noscm next-version -all > /dev/null 2>&1

APP_VERSION=$(agvtool what-version -terse) 


PROJECT_NAME="MadridExpressVM"

if [ $# -lt 1 ]; then
    echo "**** auto commit ~~~~ v$APP_VERSION"
    git commit -m "v$APP_VERSION (auto) " $PROJECT_NAME.xcodeproj/project.pbxproj $PROJECT_NAME/Info.plist
else
    echo "VERSION: $APP_VERSION"
    echo "**** skip commit"
fi

