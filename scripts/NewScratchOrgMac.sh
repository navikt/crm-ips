 #!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --alias $1 --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

sf force:org:open --target-org $1

echo "INSTALLERER"
echo "Installerer crm-platform-base 0.260.0"
sf force:package:install --package 04tKB000000YAbJYAW -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-access-controll 0.159.0"
sf force:package:install --package 04tKB000000YAHGYA4 -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.5.0.."
sf force:package:install --package 04tKB000000Y8nqYAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.41.0.." 
sf force:package:install --package 04tKB000000YAWDYA4 -r --installation-key $3 --wait 4 --publish-wait 8

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.29.0"
sf force:package:install --package 04tKB000000Y8znYAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-base 1.1.0.."
 sf force:package:install --package 04t2o000000ySqpAAE -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-flowComponents 0.4.0.."
sf force:package:install --package 04t7U0000008qz4QAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse base 0.31.0.."
sf force:package:install --package 04tKB000000Y9AdYAK -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-integrasjon 0.150.0"
sf force:package:install --package 04tKB000000YAb4YAG -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.43.0.."
sf force:package:install --package 04tKB000000Y9WtYAK -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.63.0"
sf force:package:install --package 04tKB000000Y5H7YAK -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.518.0"
sf force:package:install --package 04tKB000000YB0dYAG -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 0.119.0"
sf force:package:install --package 04tKB000000Y0CZYA0 -r --installation-key $3 --wait 4 --publish-wait 4


echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren - IPS_management.."
sf force:user:permset:assign --perm-set-name IPS_management

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Utvidet_oppf_lging_management.."
sf force:user:permset:assign --perm-set-name IPS_Utvidet_oppf_lging_management

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Config.."
sf force:user:permset:assign --perm-set-name IPS_Config

echo "************************* FERDIG *********************************"