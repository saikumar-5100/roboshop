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

#requirements to setup environment
apt update &>> $LF
 check $? "update"
apt install unzip -y &>> $LF
 check $? "unzip installed"
apt install net-tools -y &>> $LF
 check $? "net-tools installed"
apt install nginx -y &>> $LF
 check $? "installing nginx"
systemctl enable nginx &>> $LF
 check $? "enabled" &>> $LF
systemctl start nginx
 check $? "start"

#application downloading
rm -rf /var/www/html/*
check $? "removed files from default html"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LF
check $? "downloading application"
cd /var/www/html
check $? "changing the directory to html"
unzip /tmp/web.zip &>> $LF
check $? "unzipping application"

#copying roboshop configuration file
cp -r ~/roboshop/roboshop /etc/nginx/sites-available/roboshop &>> $LF
check $? "copying roboshop configuration file"
#generating sym link
ln -s /etc/nginx/sites-available/roboshop /etc/nginx/sites-enabled/ &>> $LF
check $? "symlink generation"