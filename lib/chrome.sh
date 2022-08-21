#!/bin/bash

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/general.sh"

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

    if [ "${installed}" == "${FALSE}" ]; then

        echo "$ROOT_PASS" | sudo -S bash -c "wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - " &> /dev/null
        echo "$ROOT_PASS" | sudo -S sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' &> /dev/null

        echo "$ROOT_PASS" | sudo -S apt-get -y update &> /dev/null

        installPackage "${namePackageBrowser}"

        #resultDownLoad=$(wget "https://dl.google.com/linux/direct/${namePackageBrowser}_current_amd64.deb" -O "${dirTmpChrome}/${namePackageBrowser}.deb" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")
        #
        #if [ "${resultDownLoad}" == "${TRUE}" ]; then
        #    echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends "${dirTmpChrome}/${namePackageBrowser}.deb" &> /dev/null
        #fi

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