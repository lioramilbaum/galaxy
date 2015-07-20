#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_RLKS || exit 0

/vagrant/components/utilities/packageGet.py IBM/RLKS_8.1.4_FOR_LINUX_X86_ML.zip
unzip /vagrant/RLKS_8.1.4_FOR_LINUX_X86_ML.zip -d /tmp/RLKS > /dev/null

echo "==> ${projectName}: Installing IBM Rational License Key Server"
sudo /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.rational.license.key.server.linux.x86_8.1.4000.20130823_0513 -repositories RLKS/RLKSSERVER_SETUP_LINUX_X86/disk1/diskTag.inf -acceptLicense
if [ $? -ne 0 ]; then
   exit 1
fi

exit 0