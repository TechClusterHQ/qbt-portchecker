#!/usr/bin/with-contenv bash

log() {
    local message="$1"
    local timestamp=$(date +"%Y.%m.%dT%H:%M:%S")
    echo "${timestamp} (qbt-portchecker) (cleaner) ${message}"
}

response=$(curl --silent --request POST --url "http://localhost:${WEBUI_PORT}/api/v2/app/setPreferences" --data "json={\"banned_IPs\": \"\"}")

if [[ $? -eq 0 ]]; then
    log "banlist cleared successfully"
else
    log "error clearing banlist"
fi