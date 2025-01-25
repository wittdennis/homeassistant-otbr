#!/bin/sh

sed '/VERSION=/!d' Dockerfile | cut -d'=' -f2
