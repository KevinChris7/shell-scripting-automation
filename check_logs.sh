#!/bin/bash

# This Script will check the given Log file for Illegal access try

USER="$(id -un)"
INPUTS="${#}"
LOG_FILE="${1}" #File is in local directory
OUTPUT_FILE='output.csv'

# This function first fetches the matching Failed attempt using GREP command in a file
# Retrieves the IP address from the matched lines using AWK
# Sorts the Ip address using SORT command
# Fetches the unique Ip address with their occurrence count using UNIQ -C command
# Checks the condition based on count using AWK
# Output the details to a CSV file
scan_log(){

    echo 'Scanning the Log File'  
    grep 'Failed password' syslog-sample2 | awk '{print $11}' | sort -n | uniq -c |
    #awk 'ip=$2 { if ($1 >= 1) print $1 " " $2 " " system("geoiplookup " ip);}' > output.csv |
    awk 'BEGIN{print "COUNT""\tIP""\tLOCATION"}; ip=$2{ if ($1 >= 1) print $1 " " $2 " " system("geoiplookup " ip);}' > ${OUTPUT_FILE}
    echo 'Scanning Completed'

}

# Condition to check whether the User is Privileged User
if [[ "${USER}" = root ]];
then
    LOG_FILE='syslog-sample'
    if [[ "${INPUTS}" -eq 1 ]];
    then
        scan_log
    else
        echo "${LOG_FILE} is not provided"
        exit 1
    fi
else
    echo "${USER} You need root access to execute the script"
    exit 1
fi

exit 0