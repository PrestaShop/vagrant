@ECHO OFF
cd /d "%~dp0"

ECHO Leave blank if you don't want to populate parameters.

SET /P PR="Pull request? "
SET /P BRANCH="Branch? (default: develop) "
SET /P PHP_VERSION="PHP version? (7.1 / 7.2 (default) / 7.3 / 7.4) "
SET /P AUTOMATIC_INSTALL="Automatic installation? (0 / 1) "

vagrant up --provision
