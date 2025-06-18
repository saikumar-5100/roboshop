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

mkdir ~/logger

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
cd / && mkdir app
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LF
 check $? "application downloaded"
cd app
unzip /tmp/catalogue.zip &>> $LF
 check $? "unzip catalogue"
cd / && apt install npm -y &>> $LF
 check $? "npm installed"
cd /app 
npm install &>> $LF
 check $? "npm runned in application location"

#catalogue service file setup
cp -r ~/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> $LF
systemctl daemon-reload  &>> $LF
 check $? "daemon-reload" 
systemctl enable catalogue
 check $? "catalogue enabled"
systemctl start catalogue &>> $LF
 check $? "catalogue started"

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
mongosh --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>> $LF
 check $? "schema loaded"
systemctl restart catalogue &>> $LF
 check $? "restart catalogue"
