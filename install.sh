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

systemUpdatePackages
systemInstallPackages
systemInstallUser
systemInstallService

nginxConfigUpdate
nginxSitesUpdate
nginxSitesActivate

serviceCreateTreeDir
serviceCreateAppIni

echo "$ROOT_PASS" | sudo -S chown -R "${USER}:${USER}" "${SERVICE_DIR}"

serviceCreateEnv
serviceUpdateModules
serviceInstallChrome

echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${SERVICE_DIR}"

echo "$ROOT_PASS" | sudo -S systemctl enable "${SERVICE_NAME}" &> /dev/null
echo "$ROOT_PASS" | sudo -S systemctl start "${SERVICE_NAME}" &> /dev/null

echo 'Done'