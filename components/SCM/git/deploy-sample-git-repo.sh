#!/bin/sh

. /vagrant/conf/Galaxy.cfg

cd ~git && mkdir -p repos/sample-repo.git
cd ~git/repos/sample-repo.git && git init
git config --local user.name "Liora Milbaum"
git config --local user.email "liora@lmb.co.il"
echo "Hello World" > hello.txt
git add --all
git commit -m "Initial project version" 

chown -R git:git ~git

exit 0