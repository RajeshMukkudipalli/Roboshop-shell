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

app_setup(){
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

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 

    rm -rf /app/* &&>>$logfile
    cd /app

    unzip /tmp/$app_name.zip
    validate $? "Unzipping $app_name.zip file"
}

node_js_setup(){
    dnf module disable nodejs -y &&>>$logfile
    validate $? "Disabling nodejs package"

    dnf module enable nodejs:20 -y &&>>$logfile
    validate $? "Enabling nodejs package:20"

    dnf install nodejs -y &&>>$logfile
    validate $? "Installing nodejs package" 
    
    npm install &&>>$logfile
    validate $? "Installing npm packages"
}

maven_setup(){
    dnf install maven -y &>>$logfile
    validate $? "Installing maven package"

    mvn clean package &>>$logfile
    validate $? "Building shipping application"

    mv target/shipping-1.0.jar shipping.jar
    validate $? "Renaming shipping jar file"
}

python3_setup(){
    dnf install python3 gcc python3-devel -y &>>$logfile
    validate $? "Installing python3 package"

    pip3 install -r requirements.txt &>>$logfile
    validate $? "Installing python dependencies"

    cp $script_dir/payment.service /etc/systemd/system/payment.service &>>$logfile
    validate $? "Copying payment.service file"
}

systemd_setup(){
    cp $script_dir/$app_name.service /etc/systemd/system/$app_name.service
    validate $? "Copying $app_name.service file"

    systemctl daemon-reload &&>>$logfile
    validate $? "Reloading systemd daemon"

    systemctl enable $app_name &&>>$logfile
    validate $? "Enabling $app_name service"   

    systemctl start $app_name &&>>$logfile
    validate $? "Starting $app_name service"
}

check_root_user(){
    if [ $userid -ne 0 ]; then
        echo "You are not root user"
    else
        echo "You are  root user"
    fi
    # this is a validation function
    validate() {
        if [ $1 -eq 0 ]; then
            echo -e "$2 $G is successful $N" | tee -a $logfile
        else
            echo -e "$2 $R is failed $N"
            exit 1
        fi
    }
}

print_time(){
    End_time=$(date +%s)
    Total_time=$(($End_time - $Start_time))
    echo -e "\nTime taken to execute the script: $Y $Total_time seconds $N"
}