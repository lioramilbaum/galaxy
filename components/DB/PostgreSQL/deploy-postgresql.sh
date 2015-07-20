#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_POSTGRES || exit 0

sudo apt-get install postgresql postgresql-contrib

exit 0