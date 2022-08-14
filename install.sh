#!/usr/bin/env bash

set -eu
#set -x

####################################### IMPORT FILES ######################################
# shellcheck source=/dev/null
source lib/general.sh
# shellcheck source=/dev/null
source lib/system.sh
# shellcheck source=/dev/null
source lib/nginx.sh
# shellcheck source=/dev/null
source etc/configuration.sh

#################################### SERVICE FUNCTIONS ####################################
function serviceMakeTreeDir() {

    for currentDir in ${SERVICE_DIR_TREE}; do

        if [ -d "${currentDir}" ]; then
            rm -rf "${currentDir}"
        fi

        mkdir -p "${currentDir}"

        echo "$ROOT_PASS" | sudo -S mkdir -p "${currentDir}"
        echo "$ROOT_PASS" | sudo -S chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${currentDir}"
        echo "$ROOT_PASS" | sudo -S chmod -R 644 "${currentDir}"

    done

}

function serviceCreateEnv() {

    cd "${SERVICE_DIR}" || exit
    local dirEnv="${SERVICE_DIR}/env"

    if [ -d "${dirEnv}" ]; then
        rm -rf "${dirEnv}"
    fi

    python3 -m venv "${dirEnv}"

    # shellcheck source=/dev/null
    source "${dirEnv}/bin/activate"

    packagesPython="wheel requests selenium selenium-wire beautifulsoup4 \
        html5lib fake-useragent uwsgi flask"

    for namePackage in ${packagesPython}; do
        installPython3Package "${namePackage}"
    done

    deactivate

}

########################################## MAIN ###########################################
if [ "${USER}" == "root" ]; then
    whiptail --title " Уведомление " --clear --msgbox "Запрещено производить установку от пользователя root!" 7 60 3>&1 1>&2 2>&3
    exit 0
fi

sudo -k
if [ "$(requestPasswordSU)" == "${FALSE}" ]; then
    exit 0
fi

systemUpdatePackages
systemInstallPackages
nginxConfig
nginxConfigSites
serviceCreatUnit
#serviceMakeTreeDir
#serviceCreateEnv
#systemInstallService

echo 'Done'