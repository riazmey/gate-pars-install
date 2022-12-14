#!/usr/bin/env bash

set -eu
#set -x

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source "etc/configuration.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/general.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/system.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/nginx.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/service.sh"
# shellcheck source=/dev/null
source "${INSTALL_DIR}/lib/chrome.sh"

########################################## MAIN ###########################################
if [ "${USER}" == "root" ]; then
    whiptail --title " Уведомление " --clear --msgbox \
        "Запрещено производить установку от пользователя root!" 7 60 3>&1 1>&2 2>&3
    exit 0
fi

sudo -k
if [ "$(requestPasswordSU)" == "${FALSE}" ]; then
    exit 0
fi

if [ -d "${TEMPORARY_DIR}" ]; then
    echo "$ROOT_PASS" | sudo -S rm -rf "${TEMPORARY_DIR}"
fi

mkdir -p "${TEMPORARY_DIR}"

clear

systemUpdatePackages
systemInstallPackages
systemInstallUser
systemInstallService

echo ""

nginxConfigUpdate
nginxSitesUpdate
nginxSitesActivate

echo ""

serviceStop
serviceCreateTreeDir
serviceCreateAppIni
serviceCreateEnv
serviceUpdateModules
serviceEnable

echo ""

chromeBrowserInstall
chromeDriverInstall
chromeDriverExcecutable

echo ""

echo 'Done'