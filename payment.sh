#!/bin/bash

ID=$(id -u)

#color codes storing as variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Time stamp storage for Logfiles
TS=$(date +%F-%H-%M-%S)
echo -e "$Y started execution at $TS $N"

mkdir -p ~/logger

LF="/root/logger/$0-$TS.log"

#Function to validate the executed command
check(){
if [ $1 -ne 0 ]
then
 echo -e "$2....$R failed $N"
 exit 1
 else
 echo -e "$2....$G success $N"
fi
}

if [ $ID -ne 0 ]
then
echo -e "Access denied run as root user"
exit 1
else
echo -e "Accessing as root user"
fi

echo -e "$Y starting script execution at $TS $N"

#requirments to setup python environment
apt update &>> $LF
 check $? "update"
apt install unzip -y &>> $LF
 check $? "unzip installed"
apt install net-tools &>> $LF
 check $? "net-tools installed"
apt install python3-pip -y &>> $LF
 check $? "installing python3"

#adding a user
useradd roboshop &>> $LF
 check $? "roboshop user added"

#downloading payment application
cd / && mkdir -p app
curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LF
 check $? "payment application downloaded"
cd app
unzip -o /tmp/payment.zip &>> $LF
 check $? "unzip payment"

apt update &>> $LF
 check $? "update"
pip3 install -r requirements.txt &>> $LF
check $? "installing pip3"

#payment service file setup
cp -r ~/roboshop/payment.service /etc/systemd/system/payment.service &>> $LF

systemctl daemon-reload  &>> $LF
 check $? "daemon-reload" 
systemctl enable payment
 check $? "payment enabled"
systemctl start payment &>> $LF
 check $? "payment service started"