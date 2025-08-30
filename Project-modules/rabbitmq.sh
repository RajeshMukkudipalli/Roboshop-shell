#! /bin/bash


Start_time=$(date +%s)
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
echo "please enter mysql root password"
read -s RABBITMQ_PASSWORD
# this is a validation function
validate() {
    if [ $1 -eq 0 ]; then
        echo -e "$G $2 is successful" | tee -a $logfile
    else
        echo -e "$R  $2 is failed"
        exit 1
    fi
}

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Copying rabbitmq.repo file"

dnf install rabbitmq-server -y &>>$logfile
validate $? "Installing rabbitmq-server package"    

systemctl enable rabbitmq-server &>>$logfile
validate $? "Enabling rabbitmq-server service"

systemctl start rabbitmq-server &>>$logfile
validate $? "Starting rabbitmq-server service"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"



End_time=$(date +%s)
Total_time=$(($End_time - $Start_time))
echo -e "$Y Total time took to execute the script: $Total_time seconds $N" | tee -a $logfile