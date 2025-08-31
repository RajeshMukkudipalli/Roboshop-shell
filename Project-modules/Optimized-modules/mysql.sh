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
read -s MYSQL_ROOT_PASSWORD
# this is a validation function
validate() {
    if [ $1 -eq 0 ]; then
        echo -e "$G $2 is successful" | tee -a $logfile
    else
        echo -e "$R  $2 is failed"
        exit 1
    fi
}

dnf install mysql-server -y &>>$logfile
validate $? "Installing mysql server"

systemctl enable mysqld &>>$logfile
validate $? "Enabling mysql service"

systemctl start mysqld &>>$logfile
validate $? "Starting mysql service"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$logfile
validate $? "Setting root password for mysql"


End_time=$(date +%s)
Total_time=$(($End_time - $Start_time))
echo -e "$Y Total time took to execute the script: $Total_time seconds $N" | tee -a $logfile