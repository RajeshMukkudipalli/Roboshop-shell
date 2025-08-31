#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
Logs="/var/log/roboshop-logs"
script_name=$(echo $0 | cut -d   '.' -f1)
logfile="$Logs/$script_name-$(date +%F).log"
script_dir=$(pwd)

mkdir -p $Logs
echo "Script started at: $(date)" &>> $logfile



if [ $userid -ne 0 ]; then
    echo "You are not root user"
else
    echo "You are  root user"
fi
# this is a validation function
validate() {
    if [ $1 -eq 0 ]; then
        echo -e "$G $2 is successful" | tee -a $logfile
    else
        echo -e "$R  $2 is failed"
        exit 1
    fi
}

dnf module disable nginx -y
validate $? "Installing nginx package"
dnf module enable nginx:1.24 -y
validate $? "Enabling nginx package:1.24"

dnf install nginx -y
validate $? "Installing nginx package"

systemctl enable nginx
validate $? "Enabling nginx service"
systemctl start nginx
validate $? "Starting nginx service"

rm -rf /usr/share/nginx/html/*
validate $? "Removing default nginx content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
validate $? "Downloading frontend.zip file"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
validate $? "Unzipping frontend.zip file"

rm -rf /etc/nginx/nginx.conf
validate $? "Removing default nginx.conf file"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf
validate $? "Copying custom nginx.conf file"

systemctl restart nginx
validate $? "Restarting nginx service"