#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_WAS || exit 0

/vagrant/components/utilities/packageGet.py IBM/WAS/WAS_V8.5.5_1_OF_3.zip
/vagrant/components/utilities/packageGet.py IBM/WAS/WAS_V8.5.5_2_OF_3.zip
/vagrant/components/utilities/packageGet.py IBM/WAS/WAS_V8.5.5_3_OF_3.zip
unzip /vagrant/WAS_V8.5.5_1_OF_3.zip -d /tmp/WAS > /dev/null
unzip /vagrant/WAS_V8.5.5_2_OF_3.zip -d /tmp/WAS > /dev/null
unzip /vagrant/WAS_V8.5.5_3_OF_3.zip -d /tmp/WAS > /dev/null

echo "==> ${projectName}: Installing WAS"
sudo /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.BASE.v85_8.5.5000.20130514_1044 -repositories /tmp/WAS/disk1/diskTag.inf -acceptLicense
if [ $? -ne 0 ]; then
	exit 1
fi

exit 0