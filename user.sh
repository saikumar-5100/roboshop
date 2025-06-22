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

#downloading application
cd / && mkdir -p app
curl -L -o /tmp/user.zip https://sairobo.s3.amazonaws.com/user.zip &>> $LF
 check $? "user application downloaded"
cd app
unzip -o /tmp/user.zip
 check $? "unzip user"
cd / && apt install npm -y &>> $LF
 check $? "npm installed"
cd /app 
npm install &>> $LF
 check $? "npm runned in application location"

#user service file setup
cp -r ~/roboshop/user.service /etc/systemd/system/user.service &>> $LF
systemctl daemon-reload  &>> $LF
 check $? "daemon-reload" 
systemctl enable user
 check $? "user enabled"
systemctl start user &>> $LF
 check $? "user started"

 #mongodb client setup(can use any other server)
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor &>> $LF

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
  https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list &>> $LF
check $? "mongo repo and gpg download"
apt update &>> $LF
 check $? "update"
apt install -y mongodb-mongosh &>> $LF
 check $? "mongosh client installed"
mongosh --host mongo.rs37.xyz </app/schema/user.js &>> $LF
 check $? "user schema loaded"
systemctl restart user &>> $LF
 check $? "restart user"