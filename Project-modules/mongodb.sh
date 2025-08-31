#! /bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
Logs="/var/log/roboshop-logs"
script_name=$(echo $0 | cut -d   '.' -f1)
logfile="$Logs/$script_name-$(date +%F).log"

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