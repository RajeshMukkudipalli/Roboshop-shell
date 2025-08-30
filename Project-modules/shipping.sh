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

dnf install maven -y &>>$logfile
validate $? "Installing maven package"

id roboshopp
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Creating roboshop user"
else
    echo -e "roboshop user already exists"
fi

mkdir  /app
validate $? "Creating /app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip
validate $? "Downloading shipping zip file"

rm -rf /app/* &&>>$logfile
cd /app
unzip /tmp/shipping.zip
validate $? "Unzipping shipping.zip file"

mvn clean package &>>$logfile
validate $? "Building shipping application"
mv target/shipping-1.0.jar shipping.jar
validate $? "Renaming shipping jar file"

cp $script_dir/shipping.service /etc/systemd/system/shipping.service
validate $? "Copying shipping service file"

systemctl daemon-reload
validate $? "Reloading systemd daemon"

systemctl enable shipping
validate $? "Enabling shipping service"

systemctl start shipping
validate $? "Starting shipping service"

dnf install mysql -y
validate $? "Installing mysql client"
mysql -h mysql.devopsmaster.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
mysql -h mysql.devopsmaster.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql 
mysql -h mysql.devopsmaster.xyz -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
validate $? "Loading shipping database"

systemctl restart shipping
validate $? "Restarting shipping service"



End_time=$(date +%s)
Total_time=$(($End_time - $Start_time))
echo -e "$Y Total time took to execute the script: $Total_time seconds $N" | tee -a $logfile