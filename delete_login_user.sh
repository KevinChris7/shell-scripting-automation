#!/bin/bash

# Deletes the Account for Login User
# And Optionally Archives it

LOGINUSER=$(id -un)
INPUT="${#}"
#echo "${INPUT}"

# USERNAME="${1}"
# #echo "${USERNAME}"

username_check() {
    # Checks whether the Username for Login Name is given to proceed
    echo "I am In"
    if [[ "${USERNAME}" -ne 0 ]];
    then
        echo "Usage: ${0} USERNAME [][][]"
        exit 1
    fi
}

username_disable() {
    # Chage command determines the age of the password using various options
    # Option E sets the number of days from default date
    chage -E 0 ${USERNAME} 2>/etc/null

    if [[ "${?}" -eq 0 ]];
    then
        echo "${USERNAME} Account is Disabled"
    else
        echo "User ${USERNAME} does not exist"
        exit 1
    fi
}

if [[ "${LOGINUSER}" = root ]];
then
    USERNAME="${1}"
    echo "${USERNAME}"
    # Checking whether Username is given to delete
    username_check

    # Disabling the Username
    if [[ "${?}" -eq 0 ]];
    then
        username_disable
    else 
        echo " Username Disable Failed "
        exit 1
    fi

else
    echo "${LOGINUSER} Need to Login with Root Privileges"
    exit 1
fi