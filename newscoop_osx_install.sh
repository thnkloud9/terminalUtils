# TODO - for initial install only
#brew install php55-intl
#brew install mysql
#curl -sS https://getcomposer.org/installer | php
#mv composer.phar /usr/local/bin/composer

# TODO - update /etc/apache2/conf/httpd.conf
# non-raw - http://pastie.org/private/ea5rlz5mjm2vluoh1bhhxw#3-528
# raw - http://pastie.org/pastes/10499671/text?key=ea5rlz5mjm2vluoh1bhhxw
#################################################################################

# TODO - update /etc/apache2/extra/httpd-vhosts.conf
sed '/# START newscoop.dev.conf/,/# END newscoop.dev.conf/d' text 

#<VirtualHost *:80>
#    DocumentRoot "/Library/WebServer/Documents/newscoop/newscoop"
#    SetEnv APPLICATION_ENV "development"
#    ServerName newscoop.dev
#    ServerAlias www.newscoop.dev
#    DirectoryIndex index.php index.html
#    <Directory /Library/WebServer/Documents/newscoop/>
#           AllowOverride All
#           Options Indexes MultiViews FollowSymLinks
#           Require all granted
#    </Directory>
#    ErrorLog "/private/var/log/apache2/error.log"
#    CustomLog "/private/var/log/apache2/access.log" common
#</VirtualHost>

# TODO - shouldwe assume we are in the root dir of the repo?
cd newscoop

# reset newscoop config
sudo rm -rf conf/configuration.php conf/database_conf.php cache/*

mysql -e 'drop database newscoop;' -uroot

chmod 775 plugins
chmod 775 install
chmod 775 cache
chmod 775 images 
chmod 775 public
chmod 775 conf
chmod 775 log

composer self-update
composer install --prefer-dist
sudo ./application/console newscoop:install --fix --database_name newscoop --database_user root --no-client
sudo php upgrade.php
#sudo ./application/console oauth:create-client testclient newscoop.dev newscoop.dev --test
#sudo ./application/console user:create test@example.org testpassword testuser 'Test Name' 'Test Surname' true 1 1
cd ..
sudo php newscoop/scripts/fixer.php

