#!/bin/bash
# Set the variables for your environment

vpc_dns="169.254.169.253"

# Install updates and dependencies
yum install unbound bind-utils -y

# Write Unbound configuration file with values from variables
tee /etc/unbound/unbound.conf <<EOF
server:
    interface: 0.0.0.0
    access-control: 0.0.0.0/0 allow
    prefetch: yes
    prefetch-key: yes
    rrset-roundrobin: yes
forward-zone:
    name: "."
    forward-addr: ${vpc_dns}
EOF


# Check unbound configuration
unbound-checkconf
systemctl enable unbound
systemctl start unbound.service