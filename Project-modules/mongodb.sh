#! /bin/bash

source ./common.sh
app_name=mongodb

check_root_user

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb.repo file"

dnf install mongodb-org -y &&>>$logfile
VALIDATE $? "Installing mongodb-org package"

systemctl enable mongod &&>>$logfile
VALIDATE $? "Enabling mongod service"

systemctl start mongod &&>>$logfile
VALIDATE $? "Starting mongod service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating bindIp in mongod.conf file"
systemctl restart mongod &&>>$logfile
VALIDATE $? "Restarting mongod service"

print_time