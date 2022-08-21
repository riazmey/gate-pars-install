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

    installed=$(packageIsInstalled "${namePackageBrowser}")
    echo "  chromeInstalled=${installed}"

    if [ "${installed}" == "${FALSE}" ]; then

        resultDownLoad=$(wget "https://dl.google.com/linux/direct/${namePackageBrowser}_current_amd64.deb" -O "${dirTmpChrome}/${namePackageBrowser}.deb" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

        if [ "${resultDownLoad}" == "${TRUE}" ]; then
            echo "      resultDownLoad=${resultDownLoad}"
            echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends "${dirTmpChrome}/${namePackageBrowser}.deb" &> /dev/null
        fi

    fi

    if [ -f "/tmp/apt.log" ]; then
        echo "$ROOT_PASS" | sudo -S rm -rf "/tmp/apt.log"
    fi

    echo "$ROOT_PASS" | sudo -S apt-get install -y -f

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

    latestChromeDriverVersion=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE)

    echo "$ROOT_PASS" | sudo -S rm -f "${dirTmpChrome}/${nameDriver}"
    echo "$ROOT_PASS" | sudo -S rm -f "${dirTmpChrome}/${nameDriver}.zip"

    resultDownLoad=$(wget "https://chromedriver.storage.googleapis.com/${latestChromeDriverVersion}/chromedriver_linux64.zip" -O "${dirTmpChrome}/${nameDriver}.zip" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultDownLoad}" == "${TRUE}" ]; then

        installPackage "unzip"
        unzip "${dirTmpChrome}/${nameDriver}.zip" -d "${dirTmpChrome}" &> /dev/null

        if [ -f "${dirTmpChrome}/${nameDriver}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -f "${serviceDirBin}/${nameDriver}" &> /dev/null
            echo "$ROOT_PASS" | sudo -S mv "${dirTmpChrome}/${nameDriver}" "${serviceDirBin}/${nameDriver}" &> /dev/null
        fi

    fi

}

function chromeDriverExcecutable() {

    echo "chromeDriverExcecutable"

    fileChromeDriver="${serviceDirBin}/${nameDriver}"

    if [ -f "${fileChromeDriver}" ]; then
        echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${fileChromeDriver}"
        echo "$ROOT_PASS" | sudo -S chmod u+x "${fileChromeDriver}"
    fi

}

if [ ! -d "${dirTmpChrome}" ]; then
    mkdir -p "${dirTmpChrome}"
fi