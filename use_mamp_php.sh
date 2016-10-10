#!/bin/bash

echo "Enter fully qualified path to your desired PHP binary (example: /Applications/MAMP/bin/php/php5.5.18/bin/php):"
read php_path

sudo mv /usr/bin/php /usr/bin/php.orig
sudo ln -s $php_path /usr/bin/php 


#sudo ln -s /Applications/MAMP/bin/php/php5.5.18/bin/php /usr/local/bin/php
sudo mv /usr/local/bin/php /usr/local/bin/php.orig
sudo ln -s $php_path /usr/local/bin/php
