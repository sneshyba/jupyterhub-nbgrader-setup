#!/bin/bash

# get existing nbgrader students
export students=$(nbgrader db student list 2> /dev/null | tail -n +2 | awk '{print $1}')


while read -r username; do
    # make user home directories if not already made
    if [ ! -d "/home/$username" ]; then
        mkdir "/home/$username"
        chown -R "$username:$username" "/home/$username"
        chmod 700 "/home/$username"
    fi
    # add users to nbgrader if not already in database
    if [[ ! $students == *$username* ]]; then
        nbgrader db student add $username
    fi
done < /srv/jupyterhub/usernames

# copy over nbgrader configs
if [ ! -f "/home/instructor/.jupyter" ]; then
    mkdir -p /home/instructor/.jupyter
    cp /etc/jupyter/nbgrader_config.py /home/instructor/.jupyter/.
fi
chown -R "instructor:instructor" /home/instructor/

# start jupyterhub
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
