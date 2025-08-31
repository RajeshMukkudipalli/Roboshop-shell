#!bin/bash

source ./common.sh
app_name=catalogue 
check_root_user
app_setup
node_js_setup
systemd_setup

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y
validate $? "Installing mongodb-mongosh package"

status=$(mongosh --host mongodb.devopsmaster.xyz --eval 'db.getMongo().getDBNames().indexof("catalogue")')
if [ $status -lt 0 ]
 then
    mongosh --host mongodb.devopsmaster.xyz </app/db/master-data.js
else
    echo -e "data already exists"
fi
print_time