 #!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --alias $1 --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

sf force:org:open --target-org $1

echo "INSTALLERER"
echo "Installerer crm-platform-base 0.271.0"
sf force:package:install --package 04tQC000000m0LtYAI -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-access-controll 0.160.0"
sf force:package:install --package 04tKB000000YBLfYAO -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.6.0.."
sf force:package:install --package 04tKB000000YEDVYA4 -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.41.0.." 
sf force:package:install --package 04tKB000000YAWDYA4 -r --installation-key $3 --wait 4 --publish-wait 8

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.32.0"
sf force:package:install --package 04tQC000000kTYTYA2 -r --installation-key $3 --wait 4 --publish-wait 4

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
echo "Installerer crm-platform-integrasjon 0.155.0"
sf force:package:install --package 04tQC000000lBhZYAU -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.43.0.."
sf force:package:install --package 04tKB000000Y9WtYAK -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.64.0"
sf force:package:install --package 04tKB000000YB09YAG -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.561.0"
sf force:package:install --package 04tQC000000kCSnYAM -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 0.121.0"
sf force:package:install --package 04tQC000000ieEfYAI -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-user-notification 0.24.0"
sf force:package:install --package 04t7U000000Y4jZQAS -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse 0.171.0"
sf force:package:install --package 04tQC000000lJDiYAM -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.500.0-beta1"
sf force:package:install --package 04tQC000000m7K9YAI -r --installation-key $3 --wait 4 --publish-wait 4

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