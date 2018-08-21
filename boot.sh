#!/bin/sh

sed -i "s/MYSQL_HOST/${MYSQL_HOST:-localhost}/g" /web/html/app/Config/database.php 
sed -i "s/MYSQL_USER/${MYSQL_USER:-root}/g" /web/html/app/Config/database.php 
sed -i "s/MYSQLPASSWORD/${MYSQL_PASSWORD:-password}/g" /web/html/app/Config/database.php 
sed -i "s/MYSQL_DATABASE/${MYSQL_DATABASE:-orangescrum}/g" /web/html/app/Config/database.php 
sed -i "s/SENDGRID_HOSTNAME/${SENDGRID_HOSTNAME:-ssl://smtp.sendgrid.net}/g" /web/html/app/Config/constants.php
sed -i "s/SENDGRID_PORT/${SENDGRID_PORT:-465}/g" /web/html/app/Config/constants.php
sed -i "s/SENDGRID_KEY/${SENDGRID_KEY:-foo}/g" /web/html/app/Config/constants.php
sed -i "s/SENDGRID_SECRET/${SENDGRID_SECRET:-bar}/g" /web/html/app/Config/constants.php
sed -i "s/APP_FQDN/${APP_FQDN:-localhost}/g" /web/html/app/Config/constants.php
sed -i "s/APP_NOTIFIER_EMAIL/${APP_NOTIFIER_EMAIL:-info@localhost}/g" /web/html/app/Config/constants.php
sed -i "s/APP_SUPPORT_EMAIL/${APP_SUPPORT_EMAIL-:support@localhost}/g" /web/html/app/Config/constants.php
sed -i "s/APP_DEV_EMAIL/${APP_DEV_EMAIL:-support@localhost}/g" /web/html/app/Config/constants.php
shutdown() {
  echo Shutting Down Container

  # running shutdown commands

  # first shutdown any service started by runit
  for _srv in $(ls -1 /etc/service); do
    sv force-stop $_srv
  done

  # shutdown runsvdir command
  kill -HUP $RUNSVDIR
  wait $RUNSVDIR

  # give processes time to stop
  sleep 0.5

  # kill any other processes still running in the container

  for _pid  in $(ps -eo pid | grep -v PID  | tr -d ' ' | grep -v '^1$' | head -n -6); do
    timeout -t 5 /bin/sh -c "kill $_pid && wait $_pid || kill -9 $_pid"
  done
  exit
}

# run pre-deamon tasks
/etc/runit/1

# start all deamons
/etc/runit/2&

RUNSVDIR=$!
echo "Started runsvdir, PID is $RUNSVDIR"
echo "wait for processes to start...."

sleep 5
for _srv in $(ls -1 /etc/service); do
    sv status $_srv
  done


# catch shutdown signals
trap shutdown SIGTERM SIGHUP
wait $RUNSVDIR

shutdown
