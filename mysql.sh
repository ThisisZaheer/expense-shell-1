#!/bin/bash

source ./common.sh

set -e

trap 'failure ${LINENO} "$BASH_COMMAND' ERR

check_root

echo "Please enter DB Password:"
read  mysql_root_password

dnf install mysql-serverrr -y &>>LOGFILE
#VALIDATE $? "Installing Mysql-server"

systemctl enable mysqld &>>LOGFILE
#VALIDATE $? "Enabling Mysql-server"

systemctl start mysqld &>>LOGFILE
#VALIDATE $? "Starting Mysql-server"


#mysql_secure_installation --set-root-pass ExpenseApp@1
#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"


#Below code will be useful for idempotent nature

mysql -h db.iamzaheer.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
     mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
     #VALIDATE $? "Mysql Root Password Setup"
else
    echo -e "Mysql Root Password is already setup...$C SKIP $N"
fi
