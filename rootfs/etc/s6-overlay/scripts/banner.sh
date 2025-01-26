#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Community Add-on: Base Images
# Displays a simple add-on banner on startup
# ==============================================================================
echo \
    '-----------------------------------------------------------'
echo " Add-on: homeassistant-openthread-border-router"
echo " Homeassistant version of OpenThread Border Router"
echo \
    '-----------------------------------------------------------'

echo " Add-on version: null"
echo ' You are running the latest version of this add-on.'

echo " System: $(uname)" \
    " ($(uname -m) / $(uname -n))"
echo " Home Assistant Core: null"
echo " Home Assistant Supervisor: null"

echo \
    '-----------------------------------------------------------'
echo \
    ' Please, share the above information when looking for help'
echo \
    ' or support in, e.g., GitHub, forums or the Discord chat.'
echo \
    '-----------------------------------------------------------'
