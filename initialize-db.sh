#!/usr/bin/env bash

: "${INIT_WAITTIME_IN_S:=240}"

set -e

initfile=/etc/rundeck.init

chmod 1777 /tmp

# chown directories and files that might be coming from volumes
chown -R mysql:mysql /var/lib/mysql
chown -R rundeck:rundeck /etc/rundeck
chown -R rundeck:rundeck /var/rundeck


if [ ! -f "${initfile}" ]; then
   SERVER_URL=${SERVER_URL:-"http://0.0.0.0:4440"}
   RUNDECK_PASSWORD=${RUNDECK_PASSWORD:-$(pwgen -s 15 1)}
   DEBIAN_SYS_MAINT_PASSWORD=${DEBIAN_SYS_MAINT_PASSWORD:-$(pwgen -s 15 1)}

update_user_password () {
   (
   echo "UPDATE mysql.user SET password=PASSWORD('${2}') WHERE user='${1}';"
   echo "FLUSH PRIVILEGES;"
   echo "quit"
   ) |
   mysql
}

   echo "Initializing rundeck - This may take a few minutes"
   if [ ! -f /var/lib/rundeck/.ssh/id_rsa ]; then
       echo "Generating rundeck key"
       sudo -u rundeck ssh-keygen -t rsa -f /var/lib/rundeck/.ssh/id_rsa -N ''
   fi

   /etc/init.d/mysql start

   # Set debian-sys-maint password
   update_user_password debian-sys-maint ${DEBIAN_SYS_MAINT_PASSWORD}
   sed -i 's,password\ \=\ .*,password\ \=\ '${DEBIAN_SYS_MAINT_PASSWORD}',g' /etc/mysql/debian.cnf

   (
   echo "CREATE DATABASE IF NOT EXISTS rundeckdb;"
   echo "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE, CREATE VIEW, ALTER, INDEX, EXECUTE ON rundeckdb.* TO 'rundeck'@'localhost' IDENTIFIED BY '${RUNDECK_PASSWORD}';"
   echo "quit"
   ) |
   mysql
   sleep 5
   /etc/init.d/mysql stop
   sed -i 's,grails.serverURL\=.*,grails.serverURL\='${SERVER_URL}',g' /etc/rundeck/rundeck-config.properties
   sed -i 's,dataSource.dbCreate.*,,g' /etc/rundeck/rundeck-config.properties
   sed -i 's,dataSource.url = .*,dataSource.url = jdbc:mysql://localhost/rundeckdb?autoReconnect=true,g' /etc/rundeck/rundeck-config.properties
   echo "dataSource.username = rundeck" >> /etc/rundeck/rundeck-config.properties
   echo "dataSource.password = ${RUNDECK_PASSWORD}" >> /etc/rundeck/rundeck-config.properties

echo -e "\n\n\n"
echo "==================================================================="
echo "MySQL user 'root' has no password but only allows local connections"
echo "MySQL user 'rundeck' password set to ${RUNDECK_PASSWORD}"
echo "Rundeck public key:"
cat /var/lib/rundeck/.ssh/id_rsa.pub
echo "Server URL set to ${SERVER_URL}"
echo "==================================================================="

touch ${initfile}
fi


echo Creating default admin user and API token
# : "${RD_APITOKEN:=pFLdEn0FVkIIdTHvpbu19Wq3XttqfAj3}"
#/etc/init.d/mysql start
echo "`date +"%d.%m.%Y %T.%3N"` - Starting MySQL"
service mysql start
sleep 5

# Source function library
. /lib/lsb/init-functions
. /etc/rundeck/profile

prog="rundeckd"
DAEMON="${JAVA_HOME:-/usr}/bin/java"
DAEMON_ARGS="${RDECK_JVM} -cp ${BOOTSTRAP_CP} com.dtolabs.rundeck.RunServer /var/lib/rundeck 4440"
rundeckd="$DAEMON $DAEMON_ARGS"

echo "`date +"%d.%m.%Y %T.%3N"` - Starting ${prog} to initialize the database"
/bin/bash -c "$rundeckd" &
PID=$!
echo "`date +"%d.%m.%Y %T.%3N"` - Waiting ${INIT_WAITTIME_IN_S} for ${prog} to finish starting up"
sleep $INIT_WAITTIME_IN_S
echo "`date +"%d.%m.%Y %T.%3N"` - Setting up integration project & job"
/tmp/setup-project.sh || { echo "`date +"%d.%m.%Y %T.%3N"` - Project setup & job import failed" ; exit 1 ; }

echo "`date +"%d.%m.%Y %T.%3N"` - Stopping MySQL"
service mysql stop
echo "`date +"%d.%m.%Y %T.%3N"` - Killing ${prog}"
kill $PID