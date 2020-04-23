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

If you don't care about parameters and only want to follow instruction, you can execute the `run.sh` for OSX and Linux users, and if you're running under Windows use `run.bat`.

## Parameters

You can use to customize your installation:

| Parameter         | Description                                                           | Default value |
|-------------------|-----------------------------------------------------------------------|---------------|
| AUTOMATIC_INSTALL | Set to "0" if you don't want to install PrestaShop while provisioning | 1             |
| PR                | Choose the wanted pull request to test                                |               |
| BRANCH            | The based branch                                                      | develop       |
| PHP_VERSION       | The PHP version for the current environment                           | 7.2           |


Example:

```bash
PR=17777 BRANCH="1.7.7.x" PHP_VERSION=7.3 vagrant provision
```

If you use the `AUTOMATIC_INSTALL` parameter to disable the installation, you are still able to reach [http://192.168.42.42/prestashop/install-dev](http://192.168.42.42/prestashop/install-dev) to perform a custom installation.

Example:

```bash
AUTOMATIC_INSTALL=0 BRANCH="develop" PHP_VERSION=7.3 vagrant provision
```

## Install and test a module


| Parameter         | Description                              | Default value |
|-------------------|------------------------------------------|---------------|
| MODULE            | Which module you want to clone and test  | 1             |
| PR                | Choose the wanted pull request to test   |               |
| BRANCH            | The based branch                         | dev           |


Example:

```bash
MODULE=ps_facetedsearch BRANCH=dev PR=42 vagrant provision
```
### Shortcuts

If you still don't care about parameters, run the `install-modules.sh` or `install-modules.bat` for Windows users.


# Environments

## Available PHP versions

- 7.1
- 7.2
- 7.3
- 7.4

## PrestaShop

- Username: `demo@prestashop.com`
- Password: `prestashop_demo`

## MySQL

phpMyAdmin is available at [http://192.168.42.42/phpmyadmin](http://192.168.42.42/phpmyadmin).

- MySQL Host: `127.0.0.1`
- Database name: `prestashop`
- Username: `prestashop`
- Password: `prestashop`
- Port: `3306`

## SSH

You can login into the virtual machine with `vagrant ssh`

