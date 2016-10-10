sudo openssl genrsa -out /etc/apache2/server.key 2048
sudo openssl genrsa -out /etc/apache2/ssl/localhost.key 2048
sudo openssl rsa -in /etc/apache2/ssl/localhost.key -out /etc/apache2/ssl/localhost.key.rsa
