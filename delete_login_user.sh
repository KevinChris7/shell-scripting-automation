#!/bin/bash

# This Script can disable,delete and archive the user account based on input
# To Run below command format should be given
# sudo SCRIPT_NAME USER [OPTION]
# OPTION can be -d or -r or -a

LOGINUSER=$(id -un)
INPUTS="${#}"
USERNAME="${1}"
USERID=$(id -u ${USERNAME})

user_check() {
    # Checks whether the Username for Login Name is given to proceed
    if [[ "${INPUTS}" -lt 1 ]];
    then
        echo "Usage: ${0} USER [OPTION]"
        echo 'Disables the given User Account'
        echo '-d Deletes the accounts'
        echo '-r Removes the HOME directory'
        echo '-a Creates the archive and compress'
        exit 1
    fi
}

user_disable() {
    # Chage command determines the age of the password using various options
    # Option E sets the number of days from default date
    chage -E 0 ${USERNAME} 2>/etc/null

    # Check to confirm the Disable
    if [[ "${?}" -eq 0 ]];
    then
        echo "${USERNAME} Account is Disabled" 1>/dev/null
    else
        echo "User account ${USERNAME} was not disabled"
        #exit 1
    fi
}

user_backup() {
    # Archiving the USER
    tar -cvf ${USERNAME}.tar /home/${USERNAME}/ 1>/dev/null
    
    if [[ "${?}" -eq 0 ]];
    then
        # Compress the file using gzip
        gzip -f ${USERNAME}.tar 1>/dev/null
    else
        echo "User ${USERNAME} Backup Failed"
    fi
}

user_delete() {
    # Deleting the User
    if [[ "${USERID}" -gt 1000 ]];
    then 
        userdel ${USERNAME} 
    else
        echo " Cannot the Delete the user ${USERNAME} with UID ${USERID}"
        exit 1
    fi
    # Confirming the Delete operation
    if [[ "${?}" -ne 0 ]];
    then 
        echo "Delete User Failed for ${USERNAME} or User ${USERNAME} does not exist"
        exit 1
    fi
    echo "${USERNAME} account is deleted"
}

user_disable_del() {
    # Deleting the User and HOME directory
    userdel -r ${USERNAME}
    # Confirming the Delete operation
    if [[ "${?}" -ne 0 ]];
    then 
        echo "Delete and disable User Failed for ${USERNAME}"
        exit 1
    else 
        echo "User ${USERNAME} does not exist"
    fi
    echo "${USERNAME} account is deleted"    
}

user_result() {
    echo
    echo '----Account Details----'
    echo "Linux User: ${USERNAME}"
    echo "Status: Process Completed"
    echo "$(date)"
    echo 
}

if [[ "${LOGINUSER}" = root ]];
then

    # Checking whether Username is given to delete
    user_check

    # Disabling the Username
    if [[ "${?}" -eq 0 ]];
    then
        user_disable
    else 
        echo " Username Disable not processed "
        exit 1
    fi

    # Neglecting filename ${#} and first argument username ${1}
    # After using SHIFT till ${1} will be removed
    # Then ${#} becomes values from 2nd argument
    shift
    OPTION="${#}"

    while getopts dra OPTION
    do 
        case ${OPTION} in 
            d)
                echo "Deleting the User ${USERNAME}"
                user_delete
                break;;
            r)
                echo 'Deleting the User ${USERNAME} and HOME directory'
                user_disable_del
                break;;
            a)
                echo 'Archiving and Compressing the User Details!!!'
                user_backup
                break;;
            *)
                echo 'No Option is selected for Process'
                exit 1
                ;;
        esac
    done   
    user_result 

else
    echo "${LOGINUSER} Need to Login with Root Privileges"
    exit 1
fi