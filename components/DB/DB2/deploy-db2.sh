#!/bin/sh

. /vagrant/conf/Galaxy.cfg

mkdir /tmp/DB2
tar -zxvf /vagrant/install/DB2_10.5.0.3_limited_Lnx_x86-64.tar.gz -C /tmp/DB2 > /dev/null

sudo apt-get install -y libpam0g:i386 libstdc++6:i386 libaio1 binutils
sudo ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/libpam.so.0
sudo /tmp/DB2/server_r/db2setup -r /vagrant/components/DB/DB2/db2server.rsp

echo "==> ${projectName}: Creating JTS Database"
sudo useradd -m -g db2iadm1 db2jts
echo db2jts:db2jts | sudo chpasswd
sudo su - db2jts -c "/opt/ibm/db2/V10.5/bin/db2 create database JTS using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating CCM Database"
sudo useradd -m -g db2iadm1 db2ccm
echo db2ccm:db2ccm | sudo chpasswd
sudo su - db2ccm -c "/opt/ibm/db2/V10.5/bin/db2 create database CCM using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating QM Database"
sudo useradd -m -g db2iadm1 db2qm
echo db2qm:db2qm | sudo chpasswd
sudo su - db2qm -c "/opt/ibm/db2/V10.5/bin/db2 create database QM using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating RM Database"
sudo useradd -m -g db2iadm1 db2rm
echo db2rm:db2rm | sudo chpasswd
sudo su - db2rm -c "/opt/ibm/db2/V10.5/bin/db2 create database RM using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating RELM Database"
sudo useradd -m -g db2iadm1 db2relm
echo db2relm:db2relm | sudo chpasswd
sudo su - db2relm -c "/opt/ibm/db2/V10.5/bin/db2 create database RELM using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating LQE Database"
sudo useradd -m -g db2iadm1 db2lqe
echo db2lqe:db2lqe | sudo chpasswd
sudo su - db2lqe -c "/opt/ibm/db2/V10.5/bin/db2 create database LQE using codeset UTF-8 territory en PAGESIZE 32768"

echo "==> ${projectName}: Creating DCC Database"
sudo useradd -m -g db2iadm1 db2dcc
echo db2dcc:db2dcc | sudo chpasswd
sudo su - db2dcc -c "/opt/ibm/db2/V10.5/bin/db2 create database DCC using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating GC Database"
sudo useradd -m -g db2iadm1 db2gc
echo db2gc:db2gc | sudo chpasswd
sudo su - db2gc -c "/opt/ibm/db2/V10.5/bin/db2 create database GC using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating LDX Database"
sudo useradd -m -g db2iadm1 db2ldx
echo db2ldx:db2ldx | sudo chpasswd
sudo su - db2ldx -c "/opt/ibm/db2/V10.5/bin/db2 create database LDX using codeset UTF-8 territory en PAGESIZE 32768"

echo "==> ${projectName}: Creating DW Database"
sudo useradd -m -g db2iadm1 db2dw
echo db2dw:db2dw | sudo chpasswd
sudo su - db2dw -c "/opt/ibm/db2/V10.5/bin/db2 create database DW using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating RICM Database"
sudo useradd -m -g db2iadm1 db2cm
echo db2cm:db2cm | sudo chpasswd
sudo su - db2cm -c "/opt/ibm/db2/V10.5/bin/db2 -tvf /vagrant/components/DB/DB2/RICM.sql"

echo "==> ${projectName}: Creating CSM Database"
sudo useradd -m -g db2iadm1 db2csm
echo db2csm:db2csm | sudo chpasswd
sudo su - db2csm -c "/opt/ibm/db2/V10.5/bin/db2 create database CSM using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating VVC Database"
sudo useradd -m -g db2iadm1 db2vvc
echo db2vvc:db2vvc | sudo chpasswd
sudo su - db2vvc -c "/opt/ibm/db2/V10.5/bin/db2 create database VVC using codeset UTF-8 territory en PAGESIZE 16384"

echo "==> ${projectName}: Creating DM Database"
sudo useradd -m -g db2iadm1 db2dm
echo db2dm:db2dm | sudo chpasswd
sudo su - db2dm -c "/opt/ibm/db2/V10.5/bin/db2 create database DM using codeset UTF-8 territory en PAGESIZE 16384"

exit 0