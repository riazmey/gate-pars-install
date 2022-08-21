#!/bin/bash

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source "${INSTALL_DIR}/etc/configuration.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/general.sh"

######################################## VARIABLES ########################################
ServiceDirBin="${SERVICE_DIR}/bin"
DirTmp="/tmp"

########################################### MAIN ##########################################

function installChromeBrowser() {

    local namePackageBrowser="google-chrome-stable"
    resultDownLoad=$(wget "https://dl.google.com/linux/direct/${namePackageBrowser}_current_amd64.deb" -O "${DirTmp}/${namePackageBrowser}.deb" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &> /dev/null
    echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends "${namePackageBrowser}.deb" &> /dev/null

}

function installChromeDriver() {

    local nameDriver="chromedriver"

    if [ ! -d "${ServiceDirBin}" ]; then
        echo "$ROOT_PASS" | sudo -S mkdir -p "${ServiceDirBin}"
    fi

    chrome_version=$(google-chrome --version | awk '{print $3}')

    echo "$ROOT_PASS" | sudo -S rm -f "${DirTmp}/${nameDriver}"
    echo "$ROOT_PASS" | sudo -S rm -f "${DirTmp}/${nameDriver}.zip"

    resultDownLoad=$(wget "https://chromedriver.storage.googleapis.com/${chrome_version}/chromedriver_linux64.zip" -O "${DirTmp}/${nameDriver}.zip" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultDownLoad}" == "${TRUE}" ]; then

        installPackage "unzip"
        unzip "${DirTmp}/${nameDriver}.zip" -d "${DirTmp}"

        if [ -f "${DirTmp}/${nameDriver}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -f "${ServiceDirBin}/${nameDriver}"
            echo "$ROOT_PASS" | sudo -S mv "${DirTmp}/${nameDriver}" "${ServiceDirBin}/${nameDriver}" 

            echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${ServiceDirBin}"
            echo "$ROOT_PASS" | sudo -S chmod -R 644 "${ServiceDirBin}"
            echo "$ROOT_PASS" | sudo -S chmod +x "${ServiceDirBin}/${nameDriver}"

        fi

    fi

}

installChromeBrowser
installChromeDriver