#!/bin/bash

# Creates new login accounts for users

USERNAME=$(id -un)
HOSTNAME=$(hostname)

if [[ "${USERNAME}" = root ]];
then
    # Getting USER Inputs for creation
    read -p 'Enter the username to create: ' CREATEUSER
    read -p 'Enter the user description: ' USERROLE

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


    # Setting the Password
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
        echo 'User Account is successfully created'
        echo '----Account Details----'
        echo "Username : ${CREATEUSER}"
        echo "Password : ${PASSWORD}"
        echo "Hostname : ${HOSTNAME}"
    else
        echo 'User Account Creation Failed'
        exit 1
    fi
else
    echo "${USERNAME}Need to Login with Root User or Sudo for Account creation" 
    exit 1  
fi

exit 0

