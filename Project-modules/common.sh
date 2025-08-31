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