#!/usr/bin/env bash

# Variables path
php_config_file="/etc/php5/apache2/php.ini"
xdebug_config_file="/etc/php5/mods-available/xdebug.ini"
mysql_config_file="/etc/mysql/my.cnf"
apache_config_file="/etc/apache2/apache2.conf"
host_document_root="/home/vagrant"
apache_document_root="/var/www/html"
apache_ports_config_file="/etc/apache2/ports.conf"
project_folder_name='public'

# Variables env
DBNAME=vagrant
DBUSER=vagrant
DBPASSWD=vagrant

echo "Start installation"

echo "Update paket"
apt-get -qq update
apt-get -qq upgrade

sudo add-apt-repository ppa:ondrej/php5-5.6
echo "Update"
apt-get update

echo "Install base pakets"
apt-get -y install curl build-essential python-software-properties git

echo "Update"
apt-get update

echo "--- Install Apache2 ---"
apt-get install -y apache2

echo "--- Install MySql ---"
echo "mysql-server mysql-server/root_password password ${DBPASSWD}" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get -y install mysql-server-5.5 mysql-client phpmyadmin

mysql -uroot -p${DBPASSWD} -e "CREATE DATABASE ${DBNAME}"
mysql -uroot -p${DBPASSWD} -e "grant all privileges on $DBNAME.* to '${DBUSER}'@'localhost' identified by '${DBPASSWD}'"

echo "--- Install repos ---"
#add-apt-repository ppa:ondrej/php5

#uncomment to install NodeJS
#add-apt-repository ppa:chris-lea/node.js

apt-get -qq update

echo "--- Install PHP ---"
apt-get install -y php5 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql mc
php5enmod mcrypt

#echo "--- Установка и конфигурация xDebug ---"
#apt-get install -y php5-xdebug

#cat << EOF | sudo tee -a ${xdebug_config_file}
#xdebug.scream=1
#xdebug.cli_color=1
#xdebug.show_local_vars=1
#EOF

echo "--- Enable mod-rewrite ---"
a2enmod rewrite

echo "--- Inatall root dir---"
sudo rm -rf ${apache_document_root}
sudo ln -fs ${host_document_root}/${project_folder_name} ${apache_document_root}

#mkdir -p /home/vagrant/php/sessions/
#chown -R www-data:www-data /home/vagrant/php/

echo "--- Settings php.ini and apache2.conf ---"
sed -i "s/error_reporting =.*/error_reporting = E_ALL/" ${php_config_file}
sed -i "s/display_errors =.*/display_errors = On/" ${php_config_file}
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 128M/" ${php_config_file}
sed -i "s/post_max_size =.*/post_max_size = 256M/" ${php_config_file}
sed -i "s/;mbstring.func_overload =.*/mbstring.func_overload = 2/" ${php_config_file}
sed -i "s/;mbstring.internal_encoding =.*/mbstring.internal_encoding = UTF-8/" ${php_config_file}
sed -i "s/short_open_tag =.*/short_open_tag = on/" ${php_config_file}
#sed -i "s/;session.save_path =.*/session.save_path = \/home\/vagrant\/php\/sessions/" ${php_config_file}
# Date Timezone
echo "---Date Timezone----"
sed -i "s/;date.timezone =.*/date.timezone = UTC/" ${php_config_file}
# opCache
echo "---opCache----"
sed -i "s/.*opcache.enable=.*/opcache.enable=1/" ${php_config_file}
sed -i "s/.*opcache.fast_shutdown=.*/opcache.fast_shutdown=1/" ${php_config_file}
sed -i "s/.*opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" ${php_config_file}
sed -i "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=100000/" ${php_config_file}
sed -i "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" ${php_config_file}
sed -i "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" ${php_config_file}

#uncomment to work with Boris
#echo "--- Работа с Boris---"
#sed -i "s/disable_functions = .*//" /etc/php5/cli/php.ini

sudo sed -i 's/AllowOverride None/AllowOverride All/g' ${apache_config_file}

a2enconf phpmyadmin

echo "--- Restart Apache2 ---"
service apache2 restart

echo "--- Reastart mysql ---"
service mysql restart

#echo "--- Установка composer ---"
#uncomment to install coomposer
#curl --silent https://getcomposer.org/installer | php
#mv composer.phar /usr/local/bin/composer

#echo "--- Установка NodeJS и NPM ---"
#uncomment to install NodeJS NPM
#apt-get -y install nodejs
#curl --silent https://npmjs.org/install.sh | sh

#echo "--- Установка Gulp, Bower ---"
#uncomment to install Gulp and Bower
#npm install -g gulp bower

#echo "--- Обновление компонентов проекта ---"
#uncomment to update packages
#cd /vagrant
#sudo -u vagrant -H sh -c "composer install"
#cd /vagrant/client
#sudo -u vagrant -H sh -c "npm install"
#sudo -u vagrant -H sh -c "bower install -s"
#sudo -u vagrant -H sh -c "gulp"

#uncomment to setting timezone
#echo "Setting Timezone to $1"
#sudo ln -sf /usr/share/zoneinfo/$1 /etc/localtime