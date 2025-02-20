 #!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --alias $1 --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

sf force:org:open --target-org $1

echo "INSTALLERER"
echo "Installerer crm-platform-base 0.258.0"
sf force:package:install --package 04tKB000000Y8p3YAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-access-controll 0.156.0"
sf force:package:install --package 04tKB000000Y8phYAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.5.0.."
sf force:package:install --package 04tKB000000Y8nqYAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.39.0.." 
sf force:package:install --package 04tKB000000Y5GEYA0 -r --installation-key $3 --wait 4 --publish-wait 8

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.28.0"
sf force:package:install --package 04tKB000000Y87DYAS -r --installation-key $3 --wait 4 --publish-wait 4

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
echo "Installerer crm-henvendelse base 0.28.0.."
sf force:package:install --package 04tKB000000Y8nMYAS -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-integrasjon 0.146.0"
sf force:package:install --package 04tKB000000Y7c4YAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.42.0.."
sf force:package:install --package 04tKB000000Y8nvYAC -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.63.0"
sf force:package:install --package 04tKB000000Y5H7YAK -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.500.0"
sf force:package:install --package 04tKB000000Y8rTYAS -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 0.119.0"
sf force:package:install --package 04tKB000000Y0CZYA0 -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.476.0.."
sf force:package:install --package 04tKB000000Y8rTYAS -r --installation-key $3 --wait 10 --publish-wait 10

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