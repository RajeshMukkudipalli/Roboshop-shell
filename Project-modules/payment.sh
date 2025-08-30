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
# this is a validation function
validate() {
    if [ $1 -eq 0 ]; then
        echo -e "$G $2 is successful" | tee -a $logfile
    else
        echo -e "$R  $2 is failed"
        exit 1
    fi
}

dnf install python3 gcc python3-devel -y &>>$logfile
validate $? "Installing python3 package"

id roboshopp
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Creating roboshop user"
else
    echo -e "roboshop user already exists"
fi

mkdir  /app   &>>$logfile
validate $? "Creating /app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 

rm -rf /app/* &&>>$logfile
cd /app

unzip /tmp/payment.zip &>>$logfile
validate $? "Unzipping payment.zip file"

pip3 install -r requirements.txt &>>$logfile
validate $? "Installing python dependencies"

cp $script_dir/payment.service /etc/systemd/system/payment.service &>>$logfile
validate $? "Copying payment.service file"

systemctl daemon-reload &>>$logfile
validate $? "Reloading systemctl daemon"
systemctl enable payment &>>$logfile
validate $? "Enabling payment service"  
systemctl start payment &>>$logfile
validate $? "Starting payment service"
END_time=$(date +%s)
echo "Total time taken to execute the script: $(($END_time - $Start_time)) seconds $N"