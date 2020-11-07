#!/bin/bash
PROXY=

# AWS CodeDeploy
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ruby
cd /tmp; wget -O install-codedeploy https://aws-codedeploy-ap-northeast-1.s3.amazonaws.com/latest/install
chmod 755 install-codedeploy
sudo ./install-codedeploy auto

if [[ $1 == "--proxy" ]]; then
  sudo tee /etc/codedeploy-agent/conf/codedeployagent.yml <<EOF
---
:log_aws_wire: false
:log_dir: '/var/log/aws/codedeploy-agent/'
:pid_dir: '/opt/codedeploy-agent/state/.pid/'
:program_name: codedeploy-agent
:root_dir: '/opt/codedeploy-agent/deployment-root'
:verbose: false
:wait_between_runs: 1
:proxy_uri: ${PROXY}
:max_revisions: 5
EOF
fi
