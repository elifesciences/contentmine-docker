#!/bin/bash

set -e

ZIP_URL="$1"
TARGET_DIR="$2"

mkdir -p $(dirname $TARGET_DIR)

ZIP_FILE=/tmp/repo.zip
EXTRACTED_DIR=/tmp/extracted

wget --no-verbose --output-document $ZIP_FILE $ZIP_URL

unzip -q $ZIP_FILE -d $EXTRACTED_DIR
mv $EXTRACTED_DIR/* $TARGET_DIR

rm $ZIP_FILE
