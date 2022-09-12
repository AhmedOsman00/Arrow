#!/bin/bash
# exit when any command fails
set -ex

FILE=./.dependancies.arrow.generated
# check if file exist
if test -f "$FILE"; then
    # check if git is setup
    xcodeFiles=$(find "$2" -name '*.xcodeproj' | tr '\n' ',')
    files=$(git diff HEAD --name-only | grep '**/*.swift' | tr '\n' ',')
    if [ $? -eq 0 ]; then
        # call swift script with files
        swift run arrow generate  --swift-files "$files" "$xcodeFiles" "$1" "$2"
    else
        # call swift script with xcodefiles
        swift run arrow generate --complete "$xcodeFiles" "$1" "$2"
    fi    
else
    swift run arrow generate --complete "$xcodeFiles" "$1" "$2"
fi
