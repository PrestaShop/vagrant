#!/bin/bash

set -xe

PHP_VERSION=${1:-7.2}
PR=$2
BRANCH=$3

export DEBIAN_FRONTEND=noninteractive

apt -y install apt-transport-https lsb-release ca-certificates curl
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt update

apt install -y apache2 vim emacs-nox git unzip default-mysql-server imagemagick make

mysql -u root -e 'CREATE DATABASE prestashop;' || true
mysql -u root -e "CREATE USER 'prestashop'@'localhost' IDENTIFIED BY 'prestashop';" || true
mysql -u root -e "GRANT ALL ON *.* TO 'prestashop'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

for version in '7.1' '7.2' '7.3' '7.4'; do
    apt install -y \
    libapache2-mod-php${version} \
    php${version} \
    php${version}-bcmath \
    php${version}-bz2 \
    php${version}-cli \
    php${version}-common \
    php${version}-curl \
    php${version}-fpm \
    php${version}-gd \
    php${version}-imagick \
    php${version}-intl \
    php${version}-json \
    php${version}-ldap \
    php${version}-mbstring \
    php${version}-mysql \
    php${version}-opcache \
    php${version}-pgsql \
    php${version}-readline \
    php${version}-xdebug \
    php${version}-xml \
    php${version}-xsl \
    php${version}-zip
    a2dismod php${version}
done

a2enmod php${PHP_VERSION}
a2enmod rewrite

pushd /tmp
mv phpmyadmin.conf /etc/apache2/conf-available/phpmyadmin.conf
a2enconf phpmyadmin.conf

if [ ! -d /usr/share/phpmyadmin ]; then
    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.4/phpMyAdmin-4.9.4-all-languages.zip
    unzip phpMyAdmin-4.9.4-all-languages.zip
    mv phpMyAdmin-4.9.4-all-languages /usr/share/phpmyadmin
fi
popd

if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    chmod +x /usr/local/bin/composer
fi

service apache2 restart

pushd /var/www/html
if [ ! -d prestashop ]; then
    git clone https://github.com/PrestaShop/PrestaShop.git prestashop
fi

pushd prestashop
git checkout .
git reset --hard HEAD
git fetch -p

if [ ! -z "$BRANCH" ]; then
    git checkout $BRANCH
fi

make install || composer install
popd

chown -hR www-data:www-data prestashop
popd
