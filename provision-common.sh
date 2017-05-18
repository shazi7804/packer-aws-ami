#!/bin/bash

sudo apt-get -y update
sudo apt-get -y dist-upgrade

# AWS EC2 Run
cd /tmp; wget https://amazon-ssm-ap-northeast-1.s3.amazonaws.com/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# AWS agent
cd /tmp; wget -O install-awsagent https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install
sudo bash install-awsagent

# Time zone
sudo ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
