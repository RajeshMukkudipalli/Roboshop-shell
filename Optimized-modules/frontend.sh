#!/bin/bash

source ./common.sh
app_name=frontend
check_root_user

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

print_time