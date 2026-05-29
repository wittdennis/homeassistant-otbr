#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# ==============================================================================
# Select OTBR version and handle automatic beta disable/promotion
# ==============================================================================

# Auto disable beta when we promote beta -> stable
declare beta_auto_disable_version
declare marker
declare marker_version
declare beta_active

beta_auto_disable_version=1
marker=/data/beta_auto_disabled
marker_version=0
if [[ -f ${marker} ]]; then
    marker_version=$(< "${marker}")
fi

beta_active=false
if [ "$BETA" == "1" ]; then
    if (( marker_version < beta_auto_disable_version )); then
        echo "WARN: Disabling beta mode automatically; the previous beta is now stable."
        export BETA=0
    else
        beta_active=true
    fi
fi
echo "${beta_auto_disable_version}" > "${marker}"

if [[ ${beta_active} == true ]]; then
    echo "INFO: Beta mode enabled."

    ln -sf "/opt/otbr-beta/sbin/otbr-agent" /usr/sbin/otbr-agent
    ln -sf "/opt/otbr-beta/sbin/otbr-web" /usr/sbin/otbr-web
    ln -sf "/opt/otbr-beta/sbin/ot-ctl" /usr/sbin/ot-ctl
else
    echo "INFO: Stable enabled"

    ln -sf "/opt/otbr-stable/sbin/otbr-agent" /usr/sbin/otbr-agent
    ln -sf "/opt/otbr-stable/sbin/otbr-web" /usr/sbin/otbr-web
    ln -sf "/opt/otbr-stable/sbin/ot-ctl" /usr/sbin/ot-ctl
fi

# ==============================================================================
# Disable OTBR Web if necessary ports are not exposed
# ==============================================================================

# if bashio::var.has_value "$(bashio::addon.port 8080)" &&
#     bashio::var.has_value "$(bashio::addon.port 8081)"; then
#     echo "INFO: Web UI and REST API port are exposed, starting otbr-web."
# else
#     rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-web
#     echo "INFO: The otbr-web is disabled."
# fi

# ==============================================================================
# Enable socat-otbr-tcp service if needed
# ==============================================================================

if [ ! -z "$NETWORK_DEVICE" ]; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/socat-otbr-tcp
    touch /etc/s6-overlay/s6-rc.d/otbr-agent/dependencies.d/socat-otbr-tcp
    echo "INFO: Enabled socat-otbr-tcp."
fi
