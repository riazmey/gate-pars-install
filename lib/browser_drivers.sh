#!/bin/bash

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source "${INSTALL_DIR}/etc/configuration.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/general.sh"

######################################## VARIABLES ########################################
SERVICE_DIR_BIN="${SERVICE_DIR}/bin"
DIR_TMP="/tmp"

########################################### MAIN ##########################################

function installChromeBrowser() {

    local namePackageBrowser="google-chrome-stable"
    resultDownLoad=$(wget "https://dl.google.com/linux/direct/${namePackageBrowser}_current_amd64.deb" -O "${DIR_TMP}/${namePackageBrowser}.deb" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &> /dev/null
    echo "$ROOT_PASS" | sudo -S dpkg -i --force-depends "${namePackageBrowser}.deb" &> /dev/null

}

function installChromeDriver() {

    local nameDriver="chromedriver"

    if [ ! -d "${SERVICE_DIR_BIN}" ]; then
        echo "$ROOT_PASS" | sudo -S mkdir -p "${SERVICE_DIR_BIN}"
    fi

    chrome_version=$(google-chrome --version | awk '{print $3}')

    echo "$ROOT_PASS" | sudo -S rm -f "${DIR_TMP}/${nameDriver}"
    echo "$ROOT_PASS" | sudo -S rm -f "${DIR_TMP}/${nameDriver}.zip"

    resultDownLoad=$(wget "https://chromedriver.storage.googleapis.com/${chrome_version}/chromedriver_linux64.zip" -O "${DIR_TMP}/${nameDriver}.zip" &> /dev/null && echo "${TRUE}" || echo "${FALSE}")

    if [ "${resultDownLoad}" == "${TRUE}" ]; then

        installPackage "unzip"
        unzip "${DIR_TMP}/${nameDriver}.zip" -d "${DIR_TMP}"

        if [ -f "${DIR_TMP}/${nameDriver}" ]; then
            echo "$ROOT_PASS" | sudo -S rm -f "${SERVICE_DIR_BIN}/${nameDriver}"
            echo "$ROOT_PASS" | sudo -S mv "${DIR_TMP}/${nameDriver}" "${SERVICE_DIR_BIN}/${nameDriver}" 

            echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${SERVICE_DIR_BIN}"
            echo "$ROOT_PASS" | sudo -S chmod -R 644 "${SERVICE_DIR_BIN}"
            echo "$ROOT_PASS" | sudo -S chmod +x "${SERVICE_DIR_BIN}/${nameDriver}"

        fi

    fi

}

installChromeBrowser
installChromeDriver