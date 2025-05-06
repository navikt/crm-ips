echo "Oppretter scratch org"
call sf org create scratch --alias %1 --set-default --definition-file config/project-scratch-def.json --duration-days %2 --wait 10

call sf force:org:open --target-org %1


echo "INSTALLERER"
echo "Installerer crm-platform-base 268"
call sf force:package:install --package 04tQC000000jJ6XYAU -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-access-control 160"
call sf force:package:install --package 04tKB000000YBLfYAO -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.5.0.."
call sf force:package:install --package 04tKB000000Y8nqYAC -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.41.0.."
call sf force:package:install --package 04tKB000000YAWDYA4 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.31.0.."
call sf force:package:install --package 04tQC000000jE3dYAE -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-base 1.1.0.."
call sf force:package:install --package 04t2o000000ySqpAAE -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-flowComponents 0.4.0.."
call sf force:package:install --package 04t7U0000008qz4QAA -r --installation-key %3 --wait 4 --publish-wait 4


echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse-base 0.31.0.."
call sf force:package:install --package 04tKB000000Y9AdYAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-integration  154"
call sf force:package:install --package 04tQC000000ierNYAQ -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.43.0.."
call sf force:package:install --package 04tKB000000Y9WtYAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.64.0.."
call sf force:package:install --package 04tKB000000YB09YAG -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.559.0.."
call sf force:package:install --package 04tQC000000jX6HYAU -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 121."
call sf force:package:install --package 04tQC000000ieEfYAI -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-user-notification 0.24.0"
call sf force:package:install --package 04tKB000000YBG5YAO -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse 0.169.0"
call sf force:package:install --package 04tQC000000ieWPYAY -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.490."
call sf force:package:install --package 04tQC000000jnfhYAA -r --installation-key %3 --wait 10 --publish-wait 10

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren - IPS_management.."
call sfdx force:user:permset:assign --perm-set-name IPS_management

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Utvidet_oppf_lging_management.."
call sfdx force:user:permset:assign --perm-set-name IPS_Utvidet_oppf_lging_management

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Config.."
call sfdx force:user:permset:assign --perm-set-name IPS_Config

echo "************************* FERDIG *********************************"
