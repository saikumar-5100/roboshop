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
 check $? "update"
apt install curl gnupg apt-transport-https lsb-release -y
curl -fsSL https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo gpg --dearmor -o /usr/share/keyrings/erlang.gpg
echo "deb [signed-by=/usr/share/keyrings/erlang.gpg] https://packages.erlang-solutions.com/ubuntu noble contrib" | sudo tee /etc/apt/sources.list.d/erlang.list

apt update &>> $LF
 check $? "update"
apt install erlang -y
check $? "erlang"
curl -fsSL https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/rabbitmq.gpg
echo "deb [signed-by=/usr/share/keyrings/rabbitmq.gpg] https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list

apt update &>> $LF
 check $? "update"
apt install rabbitmq-server -y
 check $? "rabbitmq installed"
systemctl enable rabbitmq-server
 check $? "enabled rabbitmq"
rabbitmq-plugins enable rabbitmq_management
systemctl start rabbitmq-server
http://rabbitmq.rs37.xyz:15672
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"