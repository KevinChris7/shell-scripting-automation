#!/bin/bash

# Creates new login accounts for users
# You must specify the USERNAME as an argument to script
# Optionally you can specify the USERROLE or description as an additional argument

USERNAME=$(id -un)
HOSTNAME=$(hostname)

if [[ "${USERNAME}" = root ]];
then
    # Getting USER Inputs for creation
    INPUTS="${#}"
    CREATEUSER="${1}"

    # SHIFT command neglects the first argenument and takes the rest
    shift
    USERROLE="${@}"

    # Checking whether required argument is given
    echo "You have given request for ${INPUTS} arguments"
    if [[ ${INPUTS} -lt 1 ]];
    then
        echo "Usage: ${0} UserName [UserRole]..."
        exit 1
    fi

    # Creating the useraccount
    useradd -c "${USERROLE}" -m "${CREATEUSER}"
    if [[ "${?}" -ne 0 ]];
    then
        echo ' User Account already Exists '
        exit 1
    fi

    # Generating more secured one time password
    # date command with %s and %N generates APAC time with Nano seconds
    # Hash function is applied by sha256sum
    # head gives the content and the number of character using -c option
    # shuf is for shuffling the characters
    temp1="$(date +%s%N{RANDOM} | sha256sum | head -c32)"
    temp2="$(echo '!@#$%^&*' | shuf | head -c1)"
    PASSWORD="${temp1}${temp2}"
    #echo "${CREATEUSER}:${PASSWORD}"

    # Setting the Password and checking the result of it
    echo -e "${PASSWORD}\n${PASSWORD}" | passwd ${CREATEUSER}
    if [[ "${?}" -ne 0 ]];
    then
        echo ' Password Set Failed '
        exit 1
    fi

    # Force Password change on First login
    passwd -e ${CREATEUSER}

    # Display the User Creation Result
    if [[ "${?}" -eq 0 ]];
    then
        echo
        echo 'User Account is successfully created'
        echo '----Account Details----'
        echo "Username : ${CREATEUSER}"
        echo "UserRole : ${USERROLE}"
        echo "Password : ${PASSWORD}"
        echo "Hostname : ${HOSTNAME}"
    else
        echo 'User Account Creation Failed'
        exit 1
    fi
else
    echo "${USERNAME} need to Login with Root User or Sudo for Account creation" 
    exit 1  
fi

exit 0
