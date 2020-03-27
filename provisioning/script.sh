#!/bin/bash

set -xe

PHP_VERSION=${1:-7.2}
PR=$2
BRANCH=${3:-develop}
NO_INSTALL=$4

export DEBIAN_FRONTEND=noninteractive

executeCommand() {
    sudo -E su vagrant -c "${1}"
}

apt -y install apt-transport-https lsb-release ca-certificates curl

# Install php source
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

# Install nodejs source
curl -sL https://deb.nodesource.com/setup_10.x | bash -

# update
apt update

apt install -y apache2 vim emacs-nox git unzip default-mysql-server imagemagick make nodejs

# Create database and user
mysql -u root -e 'CREATE DATABASE prestashop;' || true
mysql -u root -e "CREATE USER 'prestashop'@'localhost' IDENTIFIED BY 'prestashop';" || true
mysql -u root -e "GRANT ALL ON *.* TO 'prestashop'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"


# Install all wanted php versions
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

# Prepare phpmyadmin & gitconfig
pushd /tmp
cp gitconfig /root/.gitconfig
cp phpmyadmin.conf /etc/apache2/conf-available/phpmyadmin.conf
a2enconf phpmyadmin.conf

if [ ! -d /usr/share/phpmyadmin ]; then
    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.4/phpMyAdmin-4.9.4-all-languages.zip
    unzip phpMyAdmin-4.9.4-all-languages.zip
    mv phpMyAdmin-4.9.4-all-languages /usr/share/phpmyadmin
fi
popd

# Prepare composer
if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    chmod +x /usr/local/bin/composer
fi

# Make sure
sed -i "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/" /etc/apache2/envvars
sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/" /etc/apache2/envvars
# restart apache because of a2enmod commands
service apache2 restart

# Prepare the git repository backup
pushd /var/www
if [ ! -d backup/prestashop ]; then
    mkdir backup
    pushd backup
    git clone https://github.com/PrestaShop/PrestaShop.git prestashop
    pushd prestashop
    git config core.fileMode false
    popd
    popd
fi

# Fetch origin
pushd backup/prestashop
git fetch -p
popd

# prepare the new PrestaShop directory
pushd html
rm -rf prestashop
cp -R /var/www/backup/prestashop .
chown -hR vagrant:vagrant ./
chmod -R ug+rwx ./

pushd prestashop

if [ ! -z "${PR}" ] && [ ! -z "${BRANCH}" ]; then
    executeCommand "git pr origin ${PR} ${BRANCH} || (git rebase --abort && git prm origin ${PR} ${BRANCH})"
elif [ ! -z "${BRANCH}" ]; then
    executeCommand "git checkout ${BRANCH}"
fi

if [ -f Makefile ]; then
    executeCommand "make install"
else
    executeCommand "composer install"
fi

# install PrestaShop
if [ -z "${NO_INSTALL}" ]; then
    executeCommand "php${PHP_VERSION} install-dev/index_cli.php --language=en --country=fr --domain=192.168.42.42 --base_uri=prestashop --db_server=127.0.0.1 --db_user=prestashop --db_password=prestashop --db_name=prestashop --db_create=1 --name=prestashop --email=demo@prestashop.com --password=prestashop_demo"
fi

popd

popd
