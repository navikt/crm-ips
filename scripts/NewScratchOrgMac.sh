 #!/bin/bash

if [ -z "$1" ]; then
    echo "Feil: Org-alias mangler. Bruk: $0 <alias> <duration-days> <installation-key>\n"
    exit 1
fi

echo "Sletter org med alias $1 hvis den finnes"
sf org delete scratch --target-org "$1" --no-prompt || true


echo "\nOppretter scratch org"
sf org create scratch --alias "$1" --set-default --definition-file ../config/project-scratch-def.json --duration-days $2 --wait 10

echo "\nInstallerer platform-data-model 0.1.49.3"
sf package install --package 04tQC000001KcyDYAS --no-prompt --wait 10 --publish-wait 4 

echo "\nInstallerer custom-metadata-dao 0.1.49.3"
sf package install --package 04tQC000001KczpYAC --no-prompt --wait 10 --publish-wait 4

echo "\nInstallerer custom-permission-helper 0.1.49.3"
sf package install --package 04tQC000001KcwbYAC --no-prompt --wait 10 --publish-wait 4

echo "Installer feature-toggle ver. 0.1.50.3"
sf package install --package 04tQC000001Kd4fYAC --no-prompt --wait 30 --publish-wait 30

echo "Installer record-type-cache ver. 0.1.17.3"
sf package install --package 04tQC000001Kd33YAC --no-prompt --wait 10 --publish-wait 4

echo "\nInstallerer crm-platform-base 0.308.0.1"
sf package install --package 04tQC000001UGhtYAG -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-platform-access-control 0.178.0.2"
sf package install --package 04tQC000001WWfJYAW  -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-thread-view 0.8.0.1"
sf package install --package 04tQC0000011athYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-platform-reporting 0.47.0.2" 
sf package install --package 04tQC000001WtgjYAC -r --installation-key $3 --wait 4 --publish-wait 8

echo "\nInstallerer crm-shared-timeline 1.45.0"
sf package install --package 04tQC000001GPWXYA4 -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-shared-base 1.1.0.1"
 sf package install --package 04t2o000000ySqpAAE -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-shared-flowComponents 0.4.0.3"
sf package install --package 04t7U0000008qz4QAA -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-henvendelse-base 0.38.0.2"
sf package install --package 04tQC000001So7lYAC -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-platform-integration 0.173.0.1"
sf package install --package 04tQC000001Ms4PYAS --no-prompt --installation-key $3  --wait 30 --publish-wait 30

echo "\nInstallerer crm-journal-utilities 0.55.0.1"
sf package install --package 04tQC0000012pVhYAI -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-platform-oppgave 0.84.0"
sf package install --package 04tQC000001UvwLYAS -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-shared-user-notification 0.27.0.2"
sf package install --package 04tQC0000012h6jYAA -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-community-base 0.145.0.1"
sf package install --package 04tQC000001MXeHYAW -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-henvendelse 0.202.0.1"
sf package install --package 04tQC000001TjKXYA0 -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nInstallerer crm-arbeidsgiver-base 1.715.0"
sf package install --package 04tQC000001Y90HYAS -r --installation-key $3 --wait 4 --publish-wait 4

echo "\nDeployer metadata.."
sf project deploy start --target-org "$1" --wait 10

# Assign permission sets
echo "\nGir brukeren tilgangen til IPS_management.."
sf org assign permset --name IPS_management 

echo "\nGir brukeren tilgangen IPS_Utvidet_oppf_lging_management.."
sf org assign permset --name IPS_Utvidet_oppf_lging_management 

echo "\nGir brukeren tilatelsessettet IPS_Config.."
sf org assign permset --name IPS_Config

# Opprett testdata
echo "\n.. Oppretter testdata.."
sf apex run --file ./apex/createTestData.apex

echo "\nÅpner orgen i nettleseren.."
sf force:org:open --target-org "$1"

echo "\n************************* FERDIG *********************************"
