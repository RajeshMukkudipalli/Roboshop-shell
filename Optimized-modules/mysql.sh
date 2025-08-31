#! /bin/bash


source ./common.sh
app_name=mysql
check_root_user

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


print_time