#!/bin/bash

if [ -h /usr/bin/php ] 
then
  current_php=`/usr/bin/readlink /usr/bin/php`;
  echo "/usr/bin/php is linked to $current_php";
  while true; do
    read -p "Are you sure you want to remove this link?" yn
    case $yn in
      [Yy]* ) sudo mv /usr/bin/php.orig /usr/bin/php; break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
else
  echo "/usr/bin/php is not a symlink!  You are already using OS php";
  exit 1;
fi

#sudo mv /usr/bin/php /usr/bin/php.orig

#sudo ln -s $php_path /usr/bin/php 
