#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function watchPID() {
	PROGRESS=${2}
	while [ -e /proc/${1} ]; do
		if (( ${PROGRESS} <= ${3} )); then
			PROGRESS=$(( PROGRESS+1 ))
			echo "${PROGRESS}"
		fi
		sleep 1
	done
}

if [ -z "${2}" ]; then
	# Open with the default URL
	"${DIR}/../Loffice365" "${1}"
else
	FILE=$(realpath "${2}")
	FILENAME="${FILE##*/}"
	DIRNAME="${FILE%/*}"
	# Send the file to Onedrive
	(
		ln -s "${FILE}" "${HOME}/OneDrive/Loffice365/${FILENAME}"
		echo "1"
		echo "# Uploading to OneDrive..."
		onedrive --synchronize --single-directory Loffice365 &
		watchPID $! 1 90
		echo "100"
		echo "# Finished"
	) | zenity --progress --auto-kill --auto-close --title="Loffice 365" --text="Creating link..." --percentage=0
	# Edit the file
	REMOTEFILE=$(onedrive --get-file-link "Loffice365/${FILENAME}" |grep ^https)
	"${DIR}/../Loffice365" "${REMOTEFILE}"
	# Resync after edit
	(
		echo "10"
		onedrive --synchronize --single-directory Loffice365 &
		watchPID $! 10 70
		rm "${HOME}/OneDrive/Loffice365/${FILENAME}"
		echo "75"
		echo "# Removing from OneDrive..."
		onedrive --synchronize --single-directory Loffice365 &
		watchPID $! 75 95
		echo "100"
		echo "# Finished"
	) | zenity --progress --auto-kill --auto-close --title="Loffice 365" --text="Downloading from OneDrive..." --percentage=0

fi