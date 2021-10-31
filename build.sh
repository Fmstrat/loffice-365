#!/usr/bin/env bash

# Install docker
if [ -z "$(which docker)" ]; then
	echo "This application requires docker. Install it with:

sudo apt install docker.io

You may need to add yourself to the docker group and reboot:

sudo groupadd docker
sudo usermod -aG docker \$USER"
	exit
fi

if [ "$1" == "image" ]; then
	cd /tmp
	#git clone https://github.com/jiahaog/nativefier.git
	git clone https://github.com/Fmstrat/nativefier.git
	cd nativefier
	git checkout argv-url
	docker build -t nativefier .
	exit
fi

sudo rm -rf compile binaries
mkdir -p compile
mkdir -p binaries
cp apps/office/icon.png compile
chmod a+rw compile -R
chmod a+rw binaries -R
cd compile

# Linux
docker run -v "${PWD}":/target nativefier --name Loffice365 -p linux --internal-urls "(.*)" --browserwindow-options '{"webPreferences":{"nativeWindowOpen":true}}' --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.72 Safari/537.36 Edg/90.0.818.41" https://www.office.com/ /target/
sudo chown $(id -u):$(id -g) . -R
mv Loffice365-linux-x64 loffice-365
cp -a ../apps loffice-365/apps

tar cvfz loffice-365.tgz loffice-365
mv loffice-365.tgz ../binaries

cd ..
sudo rm -rf compile
sudo chown $(id -u):$(id -g) binaries -R

