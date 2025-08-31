#!/bin/bash


Start_time=$(date +%s)
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

End_time=$(date +%s)
Total_time=$(($End_time - $Start_time))
echo -e "$Y Total time took to execute the script: $Total_time seconds $N" | tee -a $logfile




