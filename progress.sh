#!/bin/bash

(
echo "10" ; sleep 1
echo "20" ; sleep 1
echo "50" ; sleep 1
echo "75" ; sleep 1
echo "100" ; sleep 1
) |
zenity --progress \
  --title="Loffice 365" \
  --text="Uploading to OneDrive..." \
  --percentage=0

if [ "$?" = -1 ] ; then
        zenity --error \
          --text="Update canceled."
fi