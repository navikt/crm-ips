 #!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --alias $1 --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

sf force:org:open --target-org $1

echo "Installerer crm-platform-base 0.291.0"
sf package install --package 04tQC0000011Ey1YAE -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer platform-access-controll 0.163.0"
sf package install --package 04tQC0000010m7JYAQ -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-thread-view 0.8.0.."
sf package install --package 04tQC0000011athYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-platform-reporting 0.44.0.." 
sf package install --package 04tQC000000xlvlYAA -r --installation-key $3 --wait 4 --publish-wait 8

echo ""
echo "Installerer crm-shared-timeline 1.40.0"
sf package install --package 04tQC0000011mzhYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-shared-base 1.1.0.."
 sf package install --package 04t2o000000ySqpAAE -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-shared-flowComponents 0.4.0.."
sf package install --package 04t7U0000008qz4QAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-henvendelse-base 0.36.0.."
sf package install --package 04tQC000000uSXtYAM -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer platform-data-model 0.1.2"
sf package install --package 04tQC000000oHLpYAM --no-prompt --wait 4 --publish-wait 4 

echo ""
echo "INSTALLERER custom-metadata-dao"
sf package install --package 04tQC000000oHKDYA2 --no-prompt --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER custom-permission-helper 0.1.2"
sf package install --package 04tQC000000oGw2YAE --no-prompt --wait 4 --publish-wait 4

echo "Installer feature-toggle ver. 0.1.3"
sf package install --package 04tQC000000oHP3YAM --no-prompt --wait 30 --publish-wait 30

echo ""
echo "Installerer crm-platform-integration 0.165.0"
sf package install --package 04tQC0000010MKvYAM --no-prompt --installation-key $3  --wait 30 --publish-wait 30

echo ""
echo "Installerer crm-journal-utilities 0.53.0.."
sf package install --package 04tQC0000010AhxYAE -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-platform-oppgave 0.65.0"
sf package install --package 04tQC000000rfOPYAY -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-arbeidsgiver-base 1.616.0"
sf package install --package 04tQC0000012WT3YAM -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-community-base 0.132.0"
sf package install --package 04tQC000000zCibYAE -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-shared-user-notification 0.25.0"
sf package install --package 04tQC000000tKMHYA2 -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-henvendelse 0.190.0"
sf package install --package 04tQC0000011b1lYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-ips 0.517.0"
sf package install --package 04tQC0000012WUfYAM -r --installation-key $3 --wait 4 --publish-wait 4

# Assign permission sets
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren - IPS_management.."
sf org assign permset --name IPS_management 

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Utvidet_oppf_lging_management.."
sf org assign permset --name IPS_Utvidet_oppf_lging_management 

echo ""
echo "TILDELER"
echo "Tildel tilatelsessett til brukeren IPS_Config.."
sf org assign permset --name IPS_Config


# Opprett testdata
echo ".. Oppretter testdata.."
sf apex run --file ./scripts/apex/createTestData.apexapex/createTestData.apex

echo "************************* FERDIG *********************************"