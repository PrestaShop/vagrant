# PrestaShop Virtual Machine

Easy way to test PrestaShop on a custom branch / pull request and php version.

# Setup

First of all you need two tools to run this project:

- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)


# Usage

- Clone this repository
- Run `vagrant up`
- Choose your interface bridge network if needed
- Wait until the end, first installation will take a long time
- Go to [http://192.168.42.42/prestashop](http://192.168.42.42/prestashop) for the Front Office
- Go to [http://192.168.42.42/prestashop/admin-dev](http://192.168.42.42/prestashop/admin-dev) for the Back Office (login: demo@prestashop.com, password: prestashop_demo)
- Suspend the machine with `vagrant suspend`
- Resume the machine with `vagrant resume`

# Parameters

There are four environment variables you can use to customize your installation


```bash
NO_INSTALL=1 # To don't install PrestaShop, default is ""
PR=123456 # Choose the wanted pull request
BRANCH=1.7.7.x # The based branch, default is "develop"
PHP_VERSION=7.3 # The PHP version, default is "7.2"
```


Example:

```bash
PR=17777 BRANCH="1.7.7.x" PHP_VERSION=7.3 vagrant provision
```

If you use the `NO_INSTALL` parameter, you can still install it manually by reaching [http://192.168.42.42/prestashop/install-dev](http://192.168.42.42/prestashop/install-dev) and use `prestashop` for database, login and password.

Example:

```bash
NO_INSTALL=1 BRANCH="develop" PHP_VERSION=7.3 vagrant provision
```

# Available PHP versions

- 7.1
- 7.2
- 7.3
- 7.4
