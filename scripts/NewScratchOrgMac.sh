 #!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --alias $1 --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

sf force:org:open --target-org $1

echo "INSTALLERER"
echo "Installerer crm-platform-base 0.274.0"
sf force:package:install --package 04tQC000000ovHdYAI -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-access-controll 0.161.0"
sf force:package:install --package 04tQC000000octJYAQ -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.7.0.."
sf force:package:install --package 04tQC000000nfmnYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.41.0.." 
sf force:package:install --package 04tKB000000YAWDYA4 -r --installation-key $3 --wait 4 --publish-wait 8

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.35.0"
sf force:package:install --package 04tQC000000obpBYAQ -r --installation-key $3 --wait 4 --publish-wait 4

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
echo "Installerer crm-henvendelse base 0.33.0.."
sf force:package:install --package 04tQC000000o3KTYAY -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-integrasjon 0.157.0"
sf force:package:install --package 04tQC000000ocN3YAI -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.47.0.."
sf force:package:install --package 04tQC000000o4A5YAI -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.64.0"
sf force:package:install --package 04tKB000000YB09YAG -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.575.0"
sf force:package:install --package 04tQC000000ovpVYAQ -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 0.128.0"
sf force:package:install --package 04tQC000000ocOfYAI -r --installation-key $3 --wait 4 --publish-wait 4

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
echo "Installerer crm-ips 0.504.0"
sf force:package:install --package 04tQC000000p9ndYAA -r --installation-key $3 --wait 4 --publish-wait 4

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