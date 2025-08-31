#! /bin/bash


sosurce ./common.sh
app_name=rabbitmq
check_root_user
echo "please enter mysql root password"
read -s RABBITMQ_PASSWORD  #roboshop123
# this is a validation function


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

print_time