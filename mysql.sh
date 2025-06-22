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

#mysql environment setup
apt update -y &>> $LF
 check $? "update"
apt install mysql-server -y &>> $LF
 check $? "mysql-server installed"
systemctl daemon-reload
systemctl enable mysql
 check $? "mysql enabled"
systemctl start mysql
 check $? "mysql started"

#mysql password setup
mysql -u root -p 'RoboShop@1' -e "CREATE USER 'root'@'shipping.rs37.xyz.eu-north-1.compute.internal' IDENTIFIED BY 'RoboShop@1'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'shipping.rs37.xyz.eu-north-1.compute.internal' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
check $? "DB IP changed to public"
systemctl restart mysql
 check $? "mysql restarted"