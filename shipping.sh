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
#requirments to setup java environment
apt update -y &>> $LF
 check $? "update"
apt install unzip -y &>> $LF
 check $? "unzip installed"
apt install net-tools &>> $LF
 check $? "net-tools installed"
apt install maven -y &>> $LF
 check $? "installing maven"

#adding a user
useradd roboshop &>> $LF
 check $? "roboshop user added"

#downloading shipping application
cd / && mkdir app
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LF
check $? "shipping application downloaded"
cd app
unzip -o /tmp/shipping.zip &>> $LF
check $? "unzip shipping"
mvn clean package &>> $LF
check $? "mvn run to generate bytecode"
mv target/shipping-1.0.jar shipping.jar &>> $LF
check $? "renamed to shipping .jar"

#shipping service file setup
cp -r ~/roboshop/shipping.service /etc/systemd/system/shipping.service &>> $LF
systemctl daemon-reload  &>> $LF
 check $? "daemon-reload" 
systemctl enable shipping &>> $LF
 check $? "shipping enabled"
systemctl start shipping &>> $LF
 check $? "shipping started"

#mysql client setup(can use any other server)
apt update -y &>> $LF
 check $? "update"
apt install mysql-server -y &>> $LF
 check $? "mysql-server installed"
systemctl enable mysql 
 check $? "mysql enabled"
systemctl start mysql &>> $LF
 check $? "mysql started" 
mysql -h mysql.rs37.xyz -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LF
mysql -h mysql.rs37.xyz -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LF
mysql -h mysql.rs37.xyz -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LF
 check $? "schema loaded"
systemctl restart shipping &>> $LF
 check $? "application restarted"