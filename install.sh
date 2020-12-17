#!/bin/sh
set -e

hadoop_user="hadoopu"
hadoop_user_password="xxxxxxxxxx"

# add hadoop user
if grep -c ""$hadoop_user":" /etc/passwd; then
    echo "User "$hadoop_user" exist, bypass add user."
else
    sudo adduser $hadoop_user --disabled-password --home /home/$hadoop_user --gecos "Hadoop User"
    echo "$hadoop_user:$hadoop_user_password" | sudo chpasswd
    sudo usermod -aG sudo $hadoop_user
    echo "$hadoop_user ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
fi

sudo -i -u $hadoop_user bash ~/install-hadoop.sh