#!/bin/bash

echo "Checking for updates..."

# Download the latest version of the server updater depending on architecture...
echo "Downloading latest version of the server updater..."
if [ "$(uname -m)" == "x86_64" ]; then
	echo "64 bit system detected, downloading 64 bit updater"
	wget https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-unknown-linux-gnu.tar.gz -O $UPDATER_DIRECTORY/latestupdater.tar.gz -q --show-progress
else
	echo "ARM system detected, downloading ARM updater"
	echo "ARM is currently not supported, please use a 64 bit system"
	exit 1
fi

# Check if the latest updater is the same as the current updater
if cmp -s "$UPDATER_DIRECTORY/latestupdater.tar.gz" "$UPDATER_DIRECTORY/updater.tar.gz"; then
	echo "Latest updater already downloaded!"
	rm -f $UPDATER_DIRECTORY/latestupdater.tar.gz
	touch $STATUS_DIRECTORY/.updater_downloaded
else
	mv $UPDATER_DIRECTORY/latestupdater.tar.gz $UPDATER_DIRECTORY/updater.tar.gz
	echo "Updater version updated!"
	# Remove the extract flag and remove the old extracted files to extract the new files
	rm -f $STATUS_DIRECTORY/.updater_extracted
	rm -f $UPDATER_DIRECTORY/plutonium-updater
fi

# Check if the updater is already extracted, if not extract it
if [ -e $STATUS_DIRECTORY/.updater_extracted ]; then
	echo "Updater already extracted!"
else
	echo "Extracting updater..."
	tar -xvf $UPDATER_DIRECTORY/updater.tar.gz -C $UPDATER_DIRECTORY/
	# Check the exit status
	if [ $? -eq 0 ]; then
		echo "Updater extracted successfully!"
		touch $STATUS_DIRECTORY/.updater_extracted
	else
		echo "Command failed"
		exit 1
	fi
fi

#Run the updater
chmod +x $UPDATER_DIRECTORY/plutonium-updater
echo "Updater found, running updater..."
$UPDATER_DIRECTORY/plutonium-updater -d /t6server/plutonium
