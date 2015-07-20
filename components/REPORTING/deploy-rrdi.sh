#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_RRDI || exit 0

/vagrant/components/utilities/packageGet.py IBM/CLM/RRDI-repo-Linux64-5.0.2GA.zip
unzip /vagrant/RRDI-repo-Linux64-5.0.2GA.zip -d /tmp/RRDI > /dev/null

sudo apt-get install -y libpam0g:i386 libstdc++6:i386 libaio1 binutils
sudo ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/libpam.so.0

/vagrant/components/utilities/packageGet.py IBM/DB2/ibm_data_server_client_linuxx64_v10.5.tar.gz
mkdir /tmp/DB2
tar -zxvf /vagrant/ibm_data_server_client_linuxx64_v10.5.tar.gz -C /tmp/DB2 > /dev/null
sudo /tmp/DB2/client/db2setup

sudo apt-get install -y libmotif-dev:i386

echo "==> ${projectName}: Installing Rational® Reporting for Development Intelligence (RRDI)"
sudo /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.rational.rrdi.20_5.0.2000.rrdi502-I20141110_1550  -repositories /tmp/RRDI/repository.xml -acceptLicense
if [ $? -ne 0 ]; then
	exit 1
fi

sudo /opt/IBM/RRDI/setup/tool/JazzTeamServer/server/server.startup

exit 0