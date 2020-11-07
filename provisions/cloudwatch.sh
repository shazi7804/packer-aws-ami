#!/bin/bash
PROXY=
LOG_STREAM_NAME="{instance_id}-{hostname}"

# AWS cloudwatch
sudo tee /tmp/awslogs.conf <<EOF
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/syslog]
datetime_format = %b %d %H:%M:%S
file = /var/log/syslog
buffer_duration = 5000
log_stream_name = ${LOG_STREAM_NAME}
initial_position = start_of_file
log_group_name = /var/log/syslog

[/var/log/auth.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/auth.log
buffer_duration = 5000
log_stream_name = ${LOG_STREAM_NAME}
initial_position = start_of_file
log_group_name = /var/log/auth.log

EOF

# apache2 log
if dpkg -l | grep apache2; then
  sudo tee -a /tmp/awslogs.conf <<EOF
[/var/log/apache2/access.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/apache2/access.log
buffer_duration = 5000
log_stream_name = ${LOG_STREAM_NAME}
initial_position = start_of_file
log_group_name = /var/log/apache2/access.log

[/var/log/apache2/error.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/apache2/error.log
buffer_duration = 5000
log_stream_name = ${LOG_STREAM_NAME}
initial_position = start_of_file
log_group_name = /var/log/apache2/error.log
EOF
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python2.7
cd /tmp; wget -O install-cloudwatch https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
chmod 755 install-cloudwatch
sudo python2.7 ./install-cloudwatch -n --configfile=/tmp/awslogs.conf --region ap-northeast-1

if [[ $1 == "--proxy" ]]; then
  sudo tee /var/awslogs/etc/proxy.conf <<EOF
HTTP_PROXY=${PROXY}
HTTPS_PROXY=${PROXY}
NO_PROXY=169.254.169.254
EOF
fi

sudo systemctl enable awslogs
