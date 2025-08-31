#! /bin/bash


source ./common.sh
app_name=mysql
check_root_user

echo "please enter mysql root password"
read -s MYSQL_ROOT_PASSWORD #RoboShop@1

dnf install mysql-server -y &>>$logfile
validate $? "Installing mysql server"

systemctl enable mysqld &>>$logfile
validate $? "Enabling mysql service"

systemctl start mysqld &>>$logfile
validate $? "Starting mysql service"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$logfile
validate $? "Setting root password for mysql"


print_time