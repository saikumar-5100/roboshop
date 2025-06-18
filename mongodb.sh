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

#requirments to setup mongodb environment
apt update &>> $LF
 check $? "update"
 apt install net-tools &>> $LF
 check $? "net-tools installed"
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor &>> $LF

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
  https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list &>> $LF
 check $? "mongo repo and gpg download"

#install mongodb
apt update &>> $LF
 check $? "update"
apt install -y mongodb-org &>> $LF
 check $? "mongodb install"
systemctl enable mongod &>> $LF
 check $? "mongodb enabled" 
systemctl start mongod &>> $LF
 check $? "mongodb started" 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LF
 check $? "DB IP changed to public"
systemctl restart mongod
check $? "mongod restarted"