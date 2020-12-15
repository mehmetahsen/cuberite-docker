#!/bin/sh

{
# NOTE: compile.sh looks for this file in order to determine if this is the Cuberite folder.
# Please modify compile.sh if you want to rename or remove this file.
# This file was chosen arbitrarily and it is a good enough indicator that we are in the Cuberite folder.

set -ex

KERNEL=$(uname -s)
DOWNLOAD_URL="https://download.cuberite.org"
DOWNLOAD_FILE="Cuberite.tar.gz"

echo "Identifying kernel: $KERNEL"

if [ "$KERNEL" = "Linux" ]; then
	PLATFORM=$(uname -m)

	echo "Identifying platform: $PLATFORM"

	case $PLATFORM in
		"i686") PLATFORM_TAG="linux-i686" ;;
		"x86_64") PLATFORM_TAG="linux-x86_64" ;;
		# Assume that all arm devices are a raspi for now.
		arm*) PLATFORM_TAG="linux-armhf-raspbian"
	esac
elif [ "$KERNEL" = "Darwin" ]; then
	# All Darwins we care about are x86_64
	PLATFORM_TAG="darwin-x86_64"
#elif [ "$KERNEL" = "FreeBSD" ]; then
#	DOWNLOADURL="https://builds.cuberite.org/job/Cuberite%20FreeBSD%20x64%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz"
else
	echo "Unsupported kernel."
	exit 1
fi


echo "Downloading precompiled binaries."
wget "$DOWNLOAD_URL/$PLATFORM_TAG/$DOWNLOAD_FILE"

echo "Uncompressing tarball."
tar xzvf $DOWNLOAD_FILE
echo "Done."

echo "Cuberite is now installed, run using './Cuberite'."

}
