#!/usr/bin/env bash

set -eu

ipAdresses=$(ip a | grep inet | grep -v inet6 | grep -v '127.0.0.1' | awk '{print $2}' | sed 's/^\(.*\)\/.*$/\1/')
ipAdress=$(echo "${ipAdresses}" | awk '{ print $1}')
symbolTab=$(echo -e "\t")
installDir="$(pwd)"

########################################## MAIN ###########################################
export TRUE="true"
export FALSE="false"
export ROOT_PASS=""
export INSTALL_DIR="${installDir}"

#################################### SERVICE GATE_PARS ####################################
export SERVICE_IP_ADDRESS="${ipAdress}"
export SERVICE_NAME="gate-pars"
export SERVICE_USER="${SERVICE_NAME}"
export SERVICE_GROUP="www-data"
export SERVICE_DIR="/srv/${SERVICE_NAME}"
export SERVICE_DIR_TREE=(
    "${SERVICE_DIR}"
    "${SERVICE_DIR}/bin"
    "${SERVICE_DIR}/lib"
    "${SERVICE_DIR}/lib/common"
    "${SERVICE_DIR}/lib/sites"
    "${SERVICE_DIR}/data"
    "${SERVICE_DIR}/opt" )

###################################### CONFIG NGINX #######################################
export NGINX_CONF_FILE="/etc/nginx/nginx.conf"
export NGINX_CONF_DIR_SITES_AVAILABLE="/etc/nginx/sites-available"
export NGINX_CONF_DIR_SITES_ENABLED="/etc/nginx/sites-enabled"
export NGINX_CONF_FILE_TMP="/tmp/nginx.conf"
export NGINX_CONF_FILE_TEMPLATE="/tmp/nginx_template.conf"
export NGINX_CONF_PARAMS_RETREAT="${symbolTab}"
export NGINX_CONF_PARAMS_FOR_SET=(
	"uwsgi_read_timeout 600s"
	"fastcgi_read_timeout 600s"
	"keepalive_timeout 600s"
	"send_timeout 600s"
	"client_header_timeout 600s"
	"client_body_timeout 600s" )
