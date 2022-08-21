#!/bin/bash

######################################## VARIABLES ########################################
namePackageBrowser="google-chrome-stable"
serviceDirBin="${SERVICE_DIR}/bin"
nameDriver="chromedriver"
DirTmp="/tmp"

########################################### MAIN ##########################################

function chromeBrowserInstall() {

    resultDownLoad=$(wget "https://dl.google.com/linux/direct/${namePackageBrowser}_current_amd64.deb" -O "${DirTmp}/${namePackageBrowser}.deb" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &> /dev/null
    echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends "${namePackageBrowser}.deb" &> /dev/null

}

function chromeDriverInstall() {

    if [ ! -d "${serviceDirBin}" ]; then
        echo "$ROOT_PASS" | sudo -S mkdir -p "${serviceDirBin}"
    fi

    chrome_version=$(google-chrome --version | awk '{print $3}')

    echo "$ROOT_PASS" | sudo -S rm -f "${DirTmp}/${nameDriver}"
    echo "$ROOT_PASS" | sudo -S rm -f "${DirTmp}/${nameDriver}.zip"

    resultDownLoad=$(wget "https://chromedriver.storage.googleapis.com/${chrome_version}/chromedriver_linux64.zip" -O "${DirTmp}/${nameDriver}.zip" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultDownLoad}" == "${TRUE}" ]; then

        installPackage "unzip"
        unzip "${DirTmp}/${nameDriver}.zip" -d "${DirTmp}"

        if [ -f "${DirTmp}/${nameDriver}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -f "${serviceDirBin}/${nameDriver}"
            echo "$ROOT_PASS" | sudo -S mv "${DirTmp}/${nameDriver}" "${serviceDirBin}/${nameDriver}" 
        fi

    fi

}

function chromeDriverExcecutable() {

    fileChromeDriver="${serviceDirBin}/${nameDriver}"

    if [ -f "${fileChromeDriver}" ]; then
        echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${fileChromeDriver}"
        echo "$ROOT_PASS" | sudo -S chmod +x "${fileChromeDriver}"
    fi

}