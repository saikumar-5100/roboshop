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

#requirments to setup rabbitmq environment
apt update &>> $LF
apt install -y curl gnupg apt-transport-https &>> $LF
check $? "update"
curl -1sLf 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/setup.deb.sh' \
  | sudo -E bash &>> $LF
check $? "installing rabbitmq from cloudsmith"
apt install -y rabbitmq-server &>> $LF
check $? "rabbitmq installed"
systemctl enable --now rabbitmq-server
systemctl status rabbitmq-server &>> $LF
check $? "rabbitmq enabled"
sudo rabbitmq-plugins enable rabbitmq_management &>> $LF
check $? "enabled plugins"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_user_tags roboshop administrator
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
check $? "setting username and password"
