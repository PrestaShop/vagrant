@ECHO OFF
cd /d "%~dp0"

ECHO Leave blank if you don't want to install module or populate parameters.

:loop
SET /P MODULE="Module name? "

if "%MODULE%" == "" GOTO exit

SET /P PR="Pull request? "
SET /P BRANCH="Branch? (default: dev) "

vagrant up --provision

GOTO loop

:exit

