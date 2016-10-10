# install dependencies
apt-get update
apt-get install git
apt-get install apache2
apt-get install mysql-server
apt-get install php5-cli php5-curl php5-mysql php5-gd php5-intl
apt-get install libapache2-mod-php5
apt-get install imagemagick

# TODO: copy newscoop vhost
cat > /etc/apache2/sites-enabled/newscoop.conf <<EOF
<VirtualHost *:80>
      DocumentRoot /var/www/newscoop
      ServerName docker.newscoop
      ServerAlias docker.newscoop
      DirectoryIndex index.php index.html
      <Directory /var/www/newscoop>
                Options -Indexes +FollowSymLinks -MultiViews
                AllowOverride All
                Order allow,deny
                Allow from all
                Require all granted
      </Directory>
</VirtualHost>
EOF

a2ensite newscoop.conf
a2enmod rewrite php5

# install newscoop
cd /var/www
git clone https://github.com/sourcefabric/Newscoop.git newscoop
cd /var/www/newscoop
git checkout v4.3

apt-get install curl
cd /var/www/newscoop/newscoop
curl -s https://getcomposer.org/installer | php
php composer.phar install  --no-dev

# update permissions
chown -R www-data /var/www/newscoop
chgrp -R www-data /var/www/newscoop
