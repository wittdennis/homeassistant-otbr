#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# ==============================================================================
# Send OTBR discovery information to Home Assistant
# ==============================================================================
# declare config

# config=$(
#     bashio::var.json \
#         host "$(uname -n)" \
#         port "^8081" \
#         device "$(bashio::config 'device')" \
#         firmware "$(ot-ctl rcp version | head -n 1)"
# )

# # Send discovery info
# if bashio::discovery "otbr" "${config}" >/dev/null; then
#     echo "INFO: Successfully sent discovery information to Home Assistant."
# else
#     bashio::log.error "Discovery message to Home Assistant failed!"
# fi

echo "Home Assistant automatic discovery disabled for this version of the addon"
