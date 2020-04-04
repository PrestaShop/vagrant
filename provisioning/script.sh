#!/bin/bash

set -xe

PHP_VERSION=${1:-7.2}
PR=$2
BRANCH=${3:-develop}
AUTOMATIC_INSTALL=${4:-1}
MODULE=$5

PHP_VERSIONS=('7.1' '7.2' '7.3' '7.4')

export DEBIAN_FRONTEND=noninteractive

# Execute command as vagrant user
function execute_command() {
    sudo -E su vagrant -c "${1}"
}

function prepare_apt() {
    apt -y install apt-transport-https lsb-release ca-certificates curl

    # Install php source
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

    # Install nodejs source
    curl -sL https://deb.nodesource.com/setup_10.x | bash -

    # update
    apt update

    apt install -y apache2 vim emacs-nox git unzip default-mysql-server imagemagick make nodejs
    for version in ${PHP_VERSIONS[@]}; do
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
    done
}

function prepare_mysql() {
    # Create database and user
    mysql -u root -e 'CREATE DATABASE prestashop;' || true
    mysql -u root -e "CREATE USER 'prestashop'@'localhost' IDENTIFIED BY 'prestashop';" || true
    mysql -u root -e "GRANT ALL ON *.* TO 'prestashop'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"
}

function prepare_php() {
    # Install all wanted php versions
    for version in ${PHP_VERSIONS[@]}; do
        sed -i 's/^error_reporting = .*/error_reporting = E_ALL/' /etc/php/${version}/apache2/php.ini
        sed -i 's/^display_errors = .*/display_errors = On/' /etc/php/${version}/apache2/php.ini
        sed -i 's/^memory_limit = .*/memory_limit = 512M/' /etc/php/${version}/apache2/php.ini
        a2dismod php${version}
    done

    a2enmod php${PHP_VERSION}
}

function prepare_tools() {
    # Prepare phpmyadmin & gitconfig
    pushd /tmp
    cp gitconfig /root/.gitconfig
    cp phpmyadmin.conf /etc/apache2/conf-available/phpmyadmin.conf
    a2enconf phpmyadmin.conf
    cp 000-default.conf /etc/apache2/sites-available/000-default.conf

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
}

function prepare_apache() {
    # Make sure apache is run by vagrant user
    sed -i "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/" /etc/apache2/envvars
    sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/" /etc/apache2/envvars

    a2enmod rewrite
    a2enmod headers

    # restart apache because of a2enmod commands
    service apache2 restart
}


function prepare_git_repository() {
    # Prepare the git repository backup
    pushd /var/www
    if [ ! -d backup/prestashop ]; then
        mkdir -p backup
        pushd backup
        git clone https://github.com/PrestaShop/PrestaShop.git prestashop
        pushd prestashop
        git config core.fileMode false
        popd
        popd
    fi
    popd
}

function prepare_branch() {
    if [ ! -z "${PR}" ] && [ ! -z "${BRANCH}" ]; then
        execute_command "git pr origin ${PR} ${BRANCH} || (git rebase --abort && git prm origin ${PR} ${BRANCH})"
    elif [ ! -z "${BRANCH}" ]; then
        execute_command "git checkout ${BRANCH} && git pull origin ${BRANCH}"
    fi

    if [ -f composer.json ]; then
        execute_command "php${PHP_VERSION} /usr/local/bin/composer install"
    fi
}


pushd /var/www
if [ -z "${MODULE}" ]; then
    prepare_apt
    prepare_mysql
    prepare_php
    prepare_tools
    prepare_apache
    prepare_git_repository

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
    prepare_branch

    if [ -f Makefile ]; then
        execute_command "make assets"
    fi

    # install PrestaShop
    if [ "${AUTOMATIC_INSTALL}" == "1" ]; then
        execute_command "php${PHP_VERSION} install-dev/index_cli.php --language=en --country=fr --domain=192.168.42.42 --base_uri=prestashop --db_server=127.0.0.1 --db_user=prestashop --db_password=prestashop --db_name=prestashop --db_create=1 --name=prestashop --email=demo@prestashop.com --password=prestashop_demo"
    fi

    popd
else
    pushd html/prestashop/modules
    rm -rf $MODULE
    execute_command "git clone https://github.com/PrestaShop/${MODULE}.git ${MODULE}"

    pushd $MODULE
    if [ "${BRANCH}" == "develop" ]; then
        BRANCH="dev"
    fi

    prepare_branch
    popd
fi

popd
