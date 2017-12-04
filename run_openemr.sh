#!/bin/sh
set -e

auto_setup() {
    CONFIGURATION="server=${MYSQL_HOST} rootpass=${MYSQL_ROOT_PASS} loginhost=%"
    if [ "$MYSQL_ROOT_USER" != "" ]; then
        CONFIGURATION="${CONFIGURATION} root=${MYSQL_ROOT_USER}"
    fi
    if [ "$MYSQL_USER" != "" ]; then
        CONFIGURATION="${CONFIGURATION} login=${MYSQL_USER}"
    fi
    if [ "$MYSQL_PASS" != "" ]; then
        CONFIGURATION="${CONFIGURATION} pass=${MYSQL_PASS}"
    fi
    if [ "$MYSQL_DATABASE" != "" ]; then
        CONFIGURATION="${CONFIGURATION} dbname=${MYSQL_DATABASE}"
    fi
    if [ "$OE_USER" != "" ]; then
        CONFIGURATION="${CONFIGURATION} iuser=${OE_USER}"
    fi
    if [ "$OE_PASS" != "" ]; then
        CONFIGURATION="${CONFIGURATION} iuserpass=${OE_PASS}"
    fi

    chmod -R 600 /var/www/localhost/htdocs/openemr_for_build
    php /var/www/localhost/htdocs/openemr_for_build/auto_configure.php -f ${CONFIGURATION} || return 1

    echo "OpenEMR configured."
    CONFIG=$(php -r "require_once('/var/www/localhost/htdocs/openemr_for_build/sites/default/sqlconf.php'); echo \$config;")
    if [ "$CONFIG" == "0" ]; then
        echo "Error in auto-config. Configuration failed."
        exit 2
    fi
}

CONFIG=$(php -r "require_once('/var/www/localhost/htdocs/openemr_for_build/sites/default/sqlconf.php'); echo \$config;")
if [ "$CONFIG" == "0" ] &&
   [ "$MYSQL_HOST" != "" ] &&
   [ "$MYSQL_ROOT_PASS" != "" ] &&
   [ "$MANUAL_SETUP" != "yes" ]; then

    echo "Running quick setup!"
    while ! auto_setup; do
        echo "Couldn't set up. Any of these reasons could be what's wrong:"
        echo " - You didn't spin up a MySQL container or connect your OpenEMR container to a mysql instance"
        echo " - MySQL is still starting up and wasn't ready for connection yet"
        echo " - The Mysql credentials were incorrect"
        sleep 1;
    done
    echo "Setup Complete!"
fi

if [ "$CONFIG" == "1" ]; then
    echo "Setting user 'www' as owner of openemr/ and setting file/dir permissions to 400/500"
    #set all directories to 500
    find . -type d -print0 | xargs -0 chmod 500
    #set all file access to 400
    find . -type f -print0 | xargs -0 chmod 400

    #chmod 700 /var/www/localhost/htdocs/run_openemr.sh
    cp /var/www/localhost/htdocs/openemr_for_build/sites/default/sqlconf.php /var/www/localhost/htdocs/openemr/sites/default/sqlconf.php
    cp /var/www/localhost/htdocs/openemr_for_build/interface/modules/zend_modules/config/application.config.php /var/www/localhost/htdocs/openemr/interface/modules/zend_modules/config/application.config.php

    # can delete openemr_for_build now

    cd /var/www/localhost/htdocs/openemr

    echo "Default file permissions and ownership set, allowing writing to specific directories"
    # Set file and directory permissions
    chmod 600 interface/modules/zend_modules/config/application.config.php
    find sites/default/documents -type d -print0 | xargs -0 chmod 700
    find sites/default/edi -type d -print0 | xargs -0 chmod 700
    find sites/default/era -type d -print0 | xargs -0 chmod 700
    find sites/default/letter_templates -type d -print0 | xargs -0 chmod 700
    find interface/main/calendar/modules/PostCalendar/pntemplates/cache -type d -print0 | xargs -0 chmod 700
    find interface/main/calendar/modules/PostCalendar/pntemplates/compiled -type d -print0 | xargs -0 chmod 700
    find gacl/admin/templates_c -type d -print0 | xargs -0 chmod 700

    chmod -R 777 interface/main/calendar/
    chmod -R 777 sites/

    echo "Removing remaining setup scripts"
    #remove all setup scripts
    rm -f acl_setup.php
    rm -f acl_upgrade.php
    rm -f setup.php
    rm -f sql_upgrade.php
    rm -f ippf_upgrade.php
    rm -f gacl/setup.php
    echo "Setup scripts removed, we should be ready to go now!"
fi
# ensure the auto_configure.php script has been removed
rm -f /var/www/localhost/htdocs/openemr_for_build/auto_configure.php

echo "Starting cron daemon!"
crond
echo "Starting apache!"
/usr/sbin/httpd -D FOREGROUND
