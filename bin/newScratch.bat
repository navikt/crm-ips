rem Set parameters
set ORG_ALIAS=CRM-IPS
set ORG_DURATION=30

echo Cleaning previous scratch org...
call sf org delete scratch --target-org %ORG_ALIAS% 2>NUL

echo "Oppretter scratch org"
call sf org create scratch --alias %ORG_ALIAS% --set-default --definition-file config/project-scratch-def.json --duration-days %ORG_DURATION% --wait 10

call sf force:org:open --target-org %ORG_ALIAS%

echo "INSTALLERER"
echo "Installerer crm-platform-base 289"
call sf force:package:install --package 04tQC000000yAe1YAE -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-access-control 162"
call sf force:package:install --package 04tQC000000tlPhYAI -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.7.0.."
call sf force:package:install --package 04tQC000000nfmnYAA -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.44.0.."
call sf force:package:install --package 04tQC000000xlvlYAA -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.35.0.."
call sf force:package:install --package 04tQC000000obpBYAQ -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-base 1.1.0.."
call sf force:package:install --package 04t2o000000ySqpAAE -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-flowComponents 0.4.0.."
call sf force:package:install --package 04t7U0000008qz4QAA -r --installation-key %1 --wait 4 --publish-wait 4


echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse-base 0.36.0.."
call sf force:package:install --package 04tQC000000uSXtYAM -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-integration  161"
call sf force:package:install --package 04tQC000000xdbdYAA -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.52.0.."
call sf force:package:install --package 04tQC000000yDDhYAM -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.65.0.."
call sf force:package:install --package 04tQC000000rfOPYAY -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.602.0.."
call sf force:package:install --package 04tQC000000y85xYAA -r --installation-key %1 --wait 10 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 131."
call sf force:package:install --package 04tQC000000xdq9YAA -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-user-notification 0.25.0"
call sf force:package:install --package 04tQC000000tKMHYA2 -r --installation-key %1 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse 0.186.0"
call sf force:package:install --package 04tQC000000y7EjYAI -r --installation-key %1 --wait 5 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.512."
call sf force:package:install --package 04tQC000000yU3FYAU -r --installation-key %1 --wait 10 --publish-wait 10

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren - IPS_management.."
call sf org assign permset -n IPS_management

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Utvidet_oppf_lging_management.."
call sf org assign permset -n IPS_Utvidet_oppf_lging_management

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Config.."
call sf org assign permset -n IPS_Config

echo Inserting test data...
call sf force:data:tree:import -p  dummy-data/Plan.json

echo "************************* FERDIG *********************************"
