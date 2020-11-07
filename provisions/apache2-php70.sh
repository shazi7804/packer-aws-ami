#!/bin/bash

sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install apache2 libapache2-mod-fastcgi \
       php7.0-{cli,common,fpm,mysql,mongodb,mcrypt,gd,json,bcmath,mbstring,xml,xmlrpc,zip,soap,sqlite3,curl,opcache,readline}  -y
sudo a2dismod mpm_event
sudo a2enmod mpm_worker actions rewrite
sudo touch /usr/lib/cgi-bin/php7.fcgi \
    && sudo chown www-data:www-data /usr/lib/cgi-bin/php7.fcgi
sudo tee /etc/apache2/mods-available/fastcgi.conf << EOF
<IfModule mod_fastcgi.c>
  AddHandler php7.fcgi .php
  Action php7.fcgi /php7.fcgi
  Alias /php7.fcgi /usr/lib/cgi-bin/php7.fcgi
  FastCgiExternalServer /usr/lib/cgi-bin/php7.fcgi -socket /var/run/php/php7.0-fpm.sock -pass-header Authorization -idle-timeout 360
  <Directory /usr/lib/cgi-bin>
    Require all granted
  </Directory>
</IfModule>
EOF

sudo mkdir -p /var/www/htdocs/public
sudo tee /var/www/htdocs/public/index.php <<EOF
<?php
  phpinfo();
?>
EOF

sudo tee /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
  DocumentRoot /var/www/htdocs/public

  <Directory /var/www/htdocs/public>
    AllowOverride All
    Order allow,deny
    allow from all
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
sudo systemctl enable {apache2,php7.0-fpm}
