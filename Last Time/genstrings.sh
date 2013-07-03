#!/bin/sh

find . -name \*.m -not -path "./Resources/*" -print0 | xargs -0 genstrings -o en.lproj -1