#!/bin/bash


source ./common.sh
app_name=redis
check_root_user

dnf module disable redis -y &&>>$logfile
validate $? "Disabling redis version"

dnf module enable redis:7 -y &&>>$logfile
validate $? "Enabling redis version:7"

dnf install redis -y &&>>$logfile
validate $? "Installing redis package"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protect-mode/ c protect-mode no' /etc/redis/redis.conf
validate $? "Updating redis.conf file to our desired configuration so that it can communicate between our modules"

systemctl enable redis &&>>$logfile
validate $? "Enabling redis service"
systemctl start redis &&>>$logfile
validate $? "Starting redis service"

print_time




