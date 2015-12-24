#!/bin/sh

. /vagrant/conf/Galaxy.cfg

$DEPLOY_UCR || exit 0

echo "==> ${projectName}: Create custom event type"
curl -s -u admin:admin \
	"http://$UCR_HOSTNAME:8080/eventType/"  \
	-X POST \
	-H "Content-Type: application/json" \
	-H "Accept: application/json" \
	-d @/vagrant/components/DEPLOYER/UCR/sample/newEventTypes.json

echo "==> ${projectName}: Create event"
curl -s -u admin:admin \
	"http://$UCR_HOSTNAME:8080/events/?format=list" \
	-X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json"  \
	-d @/vagrant/components/DEPLOYER/UCR/sample/newEvents.json

echo -e "\n==> ${projectName}: Create Teams"
curl -s -u admin:admin \
  "http://$UCR_HOSTNAME:8080/teams/" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d @/vagrant/components/DEPLOYER/UCR/sample/newTeams.json

echo -e "\n==> ${projectName}: Create Releases"
curl -s -u admin:admin \
  "http://$UCR_HOSTNAME:8080/releases/" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d @/vagrant/components/DEPLOYER/UCR/sample/newReleases.json
  
exit 0