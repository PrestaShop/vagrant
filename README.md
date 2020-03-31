# PrestaShop Virtual Machine

Easy way to test PrestaShop on a custom branch / pull request and php version.

# Setup

First of all you need two tools to run this project:

- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

If you're using Windows, we recommend you to download [Git bash](https://git-scm.com/downloads) and execute all commands under this shell.


# Usage

- Clone this repository
- Run `vagrant up`
- Choose your interface bridge network if needed
- Wait until the end, first installation will take a long time
- Go to [http://192.168.42.42/prestashop](http://192.168.42.42/prestashop) for the Front Office
- Go to [http://192.168.42.42/prestashop/admin-dev](http://192.168.42.42/prestashop/admin-dev) for the Back Office (login: demo@prestashop.com, password: prestashop_demo)
- Suspend the machine with `vagrant suspend`
- Resume the machine with `vagrant resume`

## Shortcuts

For OSX and Linux users, you can execute the `run.sh`.

# Parameters

There are four environment variables you can use to customize your installation

```bash
AUTOMATIC_INSTALL=0 # To don't install PrestaShop, default is "1"
PR=123456 # Choose the wanted pull request
BRANCH=1.7.7.x # The based branch, default is "develop"
PHP_VERSION=7.3 # The PHP version, default is "7.2"
```

Example:

```bash
PR=17777 BRANCH="1.7.7.x" PHP_VERSION=7.3 vagrant provision
```

If you use the `AUTOMATIC_INSTALL` parameter to disable the installation, you are still able to reach [http://192.168.42.42/prestashop/install-dev](http://192.168.42.42/prestashop/install-dev) to perform a custom installation.

Example:

```bash
AUTOMATIC_INSTALL=0 BRANCH="develop" PHP_VERSION=7.3 vagrant provision
```

# Available PHP versions

- 7.1
- 7.2
- 7.3
- 7.4

# Database information

phpMyAdmin is available at [http://192.168.42.42/phpmyadmin](http://192.168.42.42/phpmyadmin).

Database name: `prestashop`
Login: `prestashop`
Password: `prestashop`

