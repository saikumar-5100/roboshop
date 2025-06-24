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

echo -e "$Y starting script execution at $TS $N"apt update
#requirments to setup nodejs environment
apt update &>> $LF
 check $? "update"
apt install unzip -y &>> $LF
 check $? "unzip installed"
apt install net-tools &>> $LF
 check $? "net-tools installed"
apt install nodejs -y &>> $LF
 check $? "installing nodejs"

#adding a user
useradd roboshop &>> $LF
 check $? "roboshop user added"

#downloading cart application
cd / && mkdir -p app
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LF
 check $? "cart application downloaded"
cd app
unzip -o /tmp/cart.zip &>> $LF
 check $? "unzip cart"
cd / && apt install npm -y &>> $LF
 check $? "npm installed"
cd /app 
npm install &>> $LF
 check $? "npm runned in application location"

 #cart service file setup
 cp -r ~/roboshop/cart.service /etc/systemd/system/cart.service &>> $LF
systemctl daemon-reload  &>> $LF
 check $? "daemon-reload" 
systemctl enable cart &>> $LF
 check $? "cart enabled"
systemctl start cart &>> $LF
 check $? "cart started"