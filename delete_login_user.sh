#!/bin/bash

# Deletes the Account for Login User
# And Optionally Archives it

LOGINUSER=$(id -un)
#INPUT="${#}"
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

user_backup() {
    # Archiving the USER
    tar -cvf ${USERNAME}.tar /home/${USERNAME}/
    
    if [[ "${?}" -eq 0 ]];
    then
        # Compress the file using gzip
        gzip -f ${USERNAME}.tar
    else
        echo "User ${USERNAME} Backup Failed"
    fi
}

user_delete() {
    # Deleting the User
    userdel ${USERNAME}
    # Confirming the Delete operation
    if [[ "${?}" -ne 0 ]];
    then 
        echo "Delete User Failed for ${USERNAME}"
        exit 1
    else 
        echo "User ${USERNAME} does not exist"
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

    # Neglecting filename ${#} and first argument username ${1}
    # After using SHIFT till ${1} will be removed
    # Then ${#} becomes values from 2nd argument
    shift
    OPTION="${#}"
    echo "${OPTION}"

    while getopts dra OPTION
    echo 'I am in While'
    do 
        case ${OPTION} in 
            d)
                echo "Deleting the User ${USERNAME}"
                user_delete
                break;;
            r)
                echo 'Home Directory removed'
                break;;
            a)
                echo 'Archiving and Compressing the User Details!!!'
                user_backup
                break;;
            *)
                echo 'Wrong Input'
                exit 1
                ;;
        esac
    done    

else
    echo "${LOGINUSER} Need to Login with Root Privileges"
    exit 1
fi