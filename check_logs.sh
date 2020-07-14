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
# Count and ID are passed as inputs to WHILE loop
# Output the details to a CSV file
scan_log(){

    echo 'Scanning the Log File'  
    echo 'COUNT,IP,LOCATION' > ${OUTPUT_FILE}
    grep 'Failed password' syslog-sample | awk '{print $(NF -3)}' | sort -n | uniq -c | sort -r |
    #awk 'BEGIN{print "COUNT""\tIP""\tLOCATION"}; ip=$2{ if ($1 >= 1)  system("geoiplookup " ip);}' | #> ${OUTPUT_FILE}
    while read COUNT IP
    do 
        if [[ "${COUNT}" -gt 5 ]];
        then
            LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print$2}')
            echo "${COUNT},${IP},${LOCATION}" >> ${OUTPUT_FILE}
        fi
    done
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