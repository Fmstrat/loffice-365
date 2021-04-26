#!/usr/bin/env bash

set -e

# Install zenity
if [ -z "$(which zenity)" ]; then
	echo "This application requires zenity. Install it with:

sudo apt install zenity"
	exit
fi

# Install onedrive
if [ -z "$(which onedrive)" ]; then
	echo "This application requires the onedrive CLI. Install it with:

sudo add-apt-repository ppa:yann1ck/onedrive
sudo apt-get update
sudo apt install onedrive"
	exit
fi

# Login to onedrive
if [ ! -f ~/.config/onedrive/refresh_token ]; then
	echo -e "You must log in to your onedrive. Do this with:
	
onedrive"
	exit
fi

# Create the sync folder
if [ ! -d ~/OneDrive/Loffice365 ]; then
	mkdir -p ~/OneDrive/Loffice365
fi
onedrive --create-directory Loffice365

BIN_PATH="${HOME}/.local/bin"
APP_PATH="${HOME}/.local/share/applications"
SYS_PATH="${HOME}/.local/share/loffice-365"

# Download app
rm -rf "${SYS_PATH}"
mkdir -p "${HOME}/.local/share/"
mkdir -p "${BIN_PATH}"
mkdir -p "${APP_PATH}"
cd "${HOME}/.local/share/"
ARCHIVE=$(curl https://api.github.com/repos/Fmstrat/loffice-365/releases |grep browser_download_url |head -n1 |sed 's/"browser_download_url": "//g;s/"//g;s/ //g')
curl -L "${ARCHIVE}" --output loffice-365.tgz
tar xfz loffice-365.tgz
rm -f loffice-365.tgz
cd loffice-365

function configureApp() {
		. "${SYS_PATH}/apps/${1}/info"
		echo -n "  Configuring ${NAME}..."
		echo "[Desktop Entry]
Name=${NAME}
Exec=${BIN_PATH}/${1} %F
Terminal=false
Type=Application
Icon=${SYS_PATH}/apps/${1}/icon.svg
StartupWMClass=${FULL_NAME}
Comment=${FULL_NAME}
Categories=${CATEGORIES}
MimeType=${MIME_TYPES}
" > "${APP_PATH}/loffice-365-${1}.desktop"
		echo "#!/usr/bin/env bash
set -e		
rm -f ${SYS_PATH}/resources/app/icon.png
ln -s ${SYS_PATH}/apps/${1}/icon.png ${SYS_PATH}/resources/app/icon.png
${SYS_PATH}/apps/loffice365.sh ${URL} \"\$@\"
" > "${BIN_PATH}/${1}"
		chmod a+x "${BIN_PATH}/${1}"
		echo " Finished."
}

# Make shortcuts
cd "${SYS_PATH}/apps"
for APP in $(find * -type d); do
	configureApp ${APP}
done
