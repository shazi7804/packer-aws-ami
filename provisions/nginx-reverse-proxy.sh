#!/bin/bash
SITE=template.com
SOURCE=www.mobile01.com
PORT=443


# nginx
sudo apt-get install DEBIAN_FRONTEND=noninteractive nginx nginx-extras -y

sudo tee /etc/nginx/nginx.conf <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
        worker_connections 2048;
        multi_accept off;
}

http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        server_tokens off;
        server_names_hash_bucket_size 64;
        server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;
        gzip_disable "msie6";
        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
EOF

sudo tee /etc/nginx/conf.d/proxy.conf <<EOF
# Proxy Settings with ram cache
proxy_buffering on;
proxy_cache_valid any 10m;
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=general-cache:10m inactive=1m max_size=5g;
proxy_temp_path /var/cache/nginx/tmp;
proxy_cache_lock on;
proxy_cache_use_stale updating;
proxy_bind 0.0.0.0;
EOF

sudo tee /etc/nginx/conf.d/security.conf <<EOF
# Security setting
# DDos attack defense, max 10 request/sec
limit_req_zone \$binary_remote_addr zone=one:50m rate=10r/s;

# XSS attack defense
add_header X-XSS-Protection "1; mode=block";

# clickjacking iframe defense
add_header X-Frame-Options "SAMEORIGIN" always;

# MIME-type sniffing
add_header X-Content-Type-Options nosniff;
EOF

sudo tee /etc/nginx/conf.d/user-agent-block.conf <<EOF
map \$http_user_agent \$block_agent{
        default         0;
        ~^$             1;
        ~*malicious     1;
        ~*backdoor      1;
        ~*netcrawler    1;
        ~*Antivirx      1;
        ~*Arian         1;
        ~*wordpress     1;
        ~*joomla        1;
        ~*nagios        1;
        ~*wget          1;
        ~*curl          1;
        ~*bot           1;
        -               1;
}
EOF

sudo tee /etc/nginx/conf.d/sites-available/${SOURCE}.conf <<EOF
upstream backend {
    server \${SOURCE}:\${PORT}   weight=1 fail_timeout=5s;
}

server {
  listen 80;
  server_name \${SITE};

  if ( \$block_agent = 1 ) {
    return 444;
  }

  location / {
    proxy_pass https://backend;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_read_timeout 3s;
    proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
  }
}
EOF

sudo tee /var/www/html/index.html <<EOF
Hello welcome !!
EOF

sudo ln -fs /etc/nginx/conf.d/sites-available/${SOURCE}.conf /etc/nginx/conf.d/sites-enabled/
sudo systemctl enable nginx

