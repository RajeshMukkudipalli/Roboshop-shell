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

dnf module disable nodejs -y &&>>$logfile
validate $? "Disabling nodejs package"

dnf module enable nodejs:20 -y &&>>$logfile
validate $? "Enabling nodejs package:20"

dnf install nodejs -y &&>>$logfile
validate $? "Installing nodejs package"

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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 

rm -rf /app/* &&>>$logfile
cd /app

unzip /tmp/cart.zip
validate $? "Unzipping cart.zip file"

npm install &&>>$logfile
validate $? "Installing npm packages"

cp $script_dir/cart.service /etc/systemd/system/cart.service
validate $? "Copying cart.service file"

systemctl daemon-reload &&>>$logfile
validate $? "Reloading systemd daemon"

systemctl enable cart &&>>$logfile
validate $? "Enabling cart service"   

systemctl start cart &&>>$logfile
validate $? "Starting cart service"

End_time=$(date +%s)
Total_time=$(($End_time - $Start_time))
echo -e "$Y Total time took to execute the script: $Total_time seconds $N" | tee -a $logfile
