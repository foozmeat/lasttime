#!/bin/sh

BUILD_NUMBER=`date +"%Y%m%d%H%M%S"`
GIT_TAG=`git describe --tags --abbrev=0`

agvtool new-marketing-version $GIT_TAG
agvtool new-version -all $BUILD_NUMBER