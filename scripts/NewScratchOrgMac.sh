 #!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --alias $1 --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

sf force:org:open --target-org $1

echo "Installerer crm-platform-base 0.295.0"
sf package install --package 04tQC0000012bu9YAA -r --installation-key $3 --wait 4 --publish-wait 4

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
echo "Installerer platform-access-controll 0.169.0"
sf package install --package 04tQC0000013mh3YAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-thread-view 0.8.0.."
sf package install --package 04tQC0000011athYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-platform-reporting 0.44.0.." 
sf package install --package 04tQC000000xlvlYAA -r --installation-key $3 --wait 4 --publish-wait 8

echo ""
echo "Installerer crm-shared-timeline 1.42.0"
sf package install --package 04tQC00000133C5YAI -r --installation-key $3 --wait 4 --publish-wait 4

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
echo "Installerer crm-platform-integration 0.168.0"
sf package install --package 04tQC0000014FG1YAM --no-prompt --installation-key $3  --wait 30 --publish-wait 30

echo ""
echo "Installerer crm-journal-utilities 0.55.0.."
sf package install --package 04tQC0000012pVhYAI -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-platform-oppgave 0.67.0"
sf package install --package 04tQC0000012qwPYAQ -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-arbeidsgiver-base 1.649.0"
sf package install --package 04tQC0000015BWvYAM -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-community-base 0.139.0"
sf package install --package 04tQC0000012syDYAQ -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-shared-user-notification 0.27.0"
sf package install --package 04tQC0000012h6jYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-henvendelse 0.196.0"
sf package install --package 04tQC0000013NNhYAM -r --installation-key $3 --wait 4 --publish-wait 4

echo ""
echo "Installerer crm-ips 0.525.0.3"
sf package install --package 04tQC0000015YWjYAM -r --installation-key $3 --wait 4 --publish-wait 4

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
sf apex run --file ./apex/createTestData.apex

echo "************************* FERDIG *********************************"