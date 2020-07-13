#!/bin/bash

# This Script will check the given Log file for Illegal access try

USER="$(id -un)"
INPUTS="${#}"
LOG_FILE='syslog-sample' #File is in local directory

# Condition to check whether the User is Privileged User
if [[ "${USER}" = root ]];
then
    if [[ "${INPUTS}" -eq 1 ]];
    then
        echo 'Scanning the Log File'
    else
        echo "${LOG_FILE} is not provided"
        exit 1
    fi
else
    echo "${USER} You need root access to execute the script"
    exit 1
fi
