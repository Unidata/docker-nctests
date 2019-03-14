#!/bin/bash
#
# Bootstrap a CDash installation.  The mysql data will live in /vagrant/mysql.
# Assume we are using a Ubuntu machine for the dashboard.
#
apt-get update

export DEBIAN_FRONTEND=noninteractive

#apt-get -y upgrade
apt-get -y -q install apache2 mysql-server php5 php5-mysql php5-xsl php5-curl php5-gd unzip git htop

#####
# Set the proper timezone.
#####
#echo "US/Mountain" | tee /etc/timezone
#dpkg-reconfigure --frontend noninteractive tzdata

#####
# Install CDash, configure mysql
#####

HTMLDIR="/var/www"

# Some linux distros use /var/www/html
if [ -d "/var/www/html" ]; then
    HTMLDIR="/var/www/html"
fi

cd $HTMLDIR

echo '<?php' > $HTMLDIR/info.php
echo 'phpinfo();' >> $HTMLDIR/info.php
echo '?>' >> $HTMLDIR/info.php


###
# Check out and configure CDash, if need be.
###
if [ ! -f $HTMLDIR/CDash ]; then
    # Stop mysql for the time being.
    # stop mysql
    git clone https://github.com/Kitware/CDash.git CDash

    # Configure MySQL
    # Add cdash database, user.
    mysql -u root -e "create user 'cdash'@'%'"
    mysql -u root -e "grant all on *.* to 'cdash'@'%'"
    mysql -u root -e "create database cdash"


    # If there is a default database file,
    # import it into the database.
    # Otherwise, create a script that lives in /home/vagrant
    # that can be used to export the database file.
    if [ -f /vagrant/default_cdash_database.sql.gz ]; then
	echo "Importing pre-existing database."
	gunzip < /vagrant/default_cdash_database.sql.gz | mysql -u root cdash
    else
	# Create a script for easy export of database, once it's been configured.
	echo "You must configure a default database for use with CDash."
	echo "Once created, run the script in /home/vagrant to"
	echo "export it."
	echo ""
    fi
    SQLSCRIPT="/home/vagrant/mysql_export.sh"
    echo '#!/bin/bash' > $SQLSCRIPT
    echo 'set -x' >> $SQLSCRIPT
    echo "mysqldump -u root cdash | gzip > /home/vagrant/default_cdash_database.sql.gz" >> $SQLSCRIPT
    echo "mv /home/vagrant/default_cdash_database.sql.gz /vagrant" >> $SQLSCRIPT
    echo "echo Finished." >> $SQLSCRIPT
    chmod 755 $SQLSCRIPT
    chown vagrant:vagrant $SQLSCRIPT

    apache2ctl restart
fi

chmod -R 777 $HTMLDIR/CDash

apache2ctl restart

exit 0
