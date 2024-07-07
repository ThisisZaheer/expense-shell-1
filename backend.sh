#!/bin/bash

set -e

# trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

error 
source ./common.sh

check_root

echo "Please enter DB password:"
read  mysql_root_password


dnf module disable nodejs -y &>>$LOGFILE
# VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
# VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
# VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    # VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created.. $C SKIP $N"
fi

mkdir -p /app &>>$LOGFILE
# VALIDATE $? "Creating App Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
# VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
# VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
# VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service
# VALIDATE $? "Copied backend-service"

systemctl daemon-reload
# VALIDATE $? "Daemon-reload"

systemctl start backend
# VALIDATE $? "Starting Backend"

systemctl enable backend
# VALIDATE $? "Enabling Backend"

dnf install mysql -y &>>$LOGFILE
# VALIDATE $? "Installing Mysql Client"

mysql -h db.iamzaheer.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
# VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
# VALIDATE $? "Restarting Backend"
