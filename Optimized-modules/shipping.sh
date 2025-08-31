#! /bin/bash


source ./common.sh
app_name=shipping
check_root_user

echo "please enter mysql root password"
read -s MYSQL_ROOT_PASSWORD #RoboShop@1



app_setup
maven_setup
systemd_setup

dnf install mysql -y
validate $? "Installing mysql client"

mysql -h mysql.devopsmaster.xyz -u root -p$MYSQL_ROOT_PASSWPRD -e 'use cities'
if [ $? -ne 0 ]
then
    mysql -h mysql.devopsmaster.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
    mysql -h mysql.devopsmaster.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql 
    mysql -h mysql.devopsmaster.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
    validate $? "Loading shipping database"
else
    echo -e "shipping database already exists $Y skipping the database creation $N"
fi


systemctl restart shipping
validate $? "Restarting shipping service"



print_time