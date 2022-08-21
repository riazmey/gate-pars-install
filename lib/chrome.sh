#!/bin/bash

######################################## VARIABLES ########################################
namePackageBrowser="google-chrome-stable"
serviceDirBin="${SERVICE_DIR}/bin"
nameDriver="chromedriver"
dirTmpChrome="${TEMPORARY_DIR}/chrome"

########################################### MAIN ##########################################

function chromeBrowserInstall() {

    echo "chromeBrowserInstall"

    if [ ! -d "${dirTmpChrome}" ]; then
        mkdir -p "${dirTmpChrome}"
    fi

    resultDownLoad=$(wget "https://dl.google.com/linux/direct/${namePackageBrowser}_current_amd64.deb" -O "${dirTmpChrome}/${namePackageBrowser}.deb" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultDownLoad}" == "${TRUE}" ]; then
        echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends "${dirTmpChrome}/${namePackageBrowser}.deb" &> /dev/null
    fi

    echo "$ROOT_PASS" | sudo -S apt-get install -f -y &> /dev/null

}

function chromeDriverInstall() {

    echo "chromeDriverInstall"

    if [ -f "${serviceDirBin}/${nameDriver}" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "${serviceDirBin}/${nameDriver}"
    fi

    installed=$(packageIsInstalled "${namePackageBrowser}")

    if [ "${installed}" == "${FALSE}" ]; then
        return 0
    fi

    chrome_version=$(${namePackageBrowser} --version | awk '{print $3}')

    echo "$ROOT_PASS" | sudo -S rm -f "${dirTmpChrome}/${nameDriver}"
    echo "$ROOT_PASS" | sudo -S rm -f "${dirTmpChrome}/${nameDriver}.zip"

    resultDownLoad=$(wget "https://chromedriver.storage.googleapis.com/${chrome_version}/chromedriver_linux64.zip" -O "${dirTmpChrome}/${nameDriver}.zip" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultDownLoad}" == "${TRUE}" ]; then

        installPackage "unzip"
        unzip "${dirTmpChrome}/${nameDriver}.zip" -d "${dirTmpChrome}"

        if [ -f "${dirTmpChrome}/${nameDriver}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -f "${serviceDirBin}/${nameDriver}"
            echo "$ROOT_PASS" | sudo -S mv "${dirTmpChrome}/${nameDriver}" "${serviceDirBin}/${nameDriver}" 
        fi

    fi

}

function chromeDriverExcecutable() {

    echo "chromeDriverExcecutable"

    fileChromeDriver="${serviceDirBin}/${nameDriver}"

    if [ -f "${fileChromeDriver}" ]; then
        echo "$ROOT_PASS" | sudo -S chmod u+x "${fileChromeDriver}"
    fi

}

if [ ! -d "${dirTmpChrome}" ]; then
    mkdir -p "${dirTmpChrome}"
fi