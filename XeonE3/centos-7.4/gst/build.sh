#!/bin/bash -e

IMAGE="xeone3-centos74-gst"
VERSION="1.0"
DIR=$(dirname $(readlink -f "$0"))

. "${DIR}/../../../script/build.sh"
