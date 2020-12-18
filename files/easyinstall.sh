#!/bin/sh

{
# NOTE: compile.sh looks for this file in order to determine if this is the Cuberite folder.
# Please modify compile.sh if you want to rename or remove this file.
# This file was chosen arbitrarily and it is a good enough indicator that we are in the Cuberite folder.

set -ex

OS_NAME=$(uname -s)
DOWNLOAD_URL="https://download.cuberite.org"
DOWNLOAD_FILE="Cuberite.tar.gz"

echo "Identified platform: $OS_NAME"

if [ "$OS_NAME" = "Linux" ]; then
	ARCH_NAME=$(uname -m)

	echo "Identified architecture: $ARCH_NAME"

	case $ARCH_NAME in
		"i686")   ARCH_TAG="linux-i686" ;;
		"x86_64") ARCH_TAG="linux-x86_64" ;;
		"armv7l") ARCH_TAG="linux-armhf-raspbian"
	esac
elif [ "$OS_NAME" = "Darwin" ]; then
	# All Darwins we care about are x86_64
	ARCH_TAG="darwin-x86_64"
else
	echo "Unsupported OS: $OS_NAME"
	exit 1
fi


echo "Downloading precompiled binaries."
wget --no-check-certificate "$DOWNLOAD_URL/$ARCH_TAG/$DOWNLOAD_FILE"

echo "Uncompressing tarball."
tar xzvf $DOWNLOAD_FILE
echo "Done."

}
