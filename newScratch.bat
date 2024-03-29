echo "Oppretter scratch org"
call sf org create scratch --alias %1 --set-default --definition-file config/project-scratch-def.json --duration-days %2 --wait 10

call sf force:org:open --target-org %1


echo "INSTALLERER"
echo "Installerer platform-base 217.."
call sf force:package:install --package 04t7U000000Y3VbQAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-access-controll 125.."
call sf force:package:install --package 04t7U000000Y3V7QAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.2.0.."
call sf force:package:install --package 04t7U000000TqvIQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-reporting 0.37.0.."
call sf force:package:install --package 04t7U000000Y2VoQAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.22.0.."
call sf force:package:install --package 04t7U000000Y2OEQA0 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-base 1.1.0.."
call sf force:package:install --package 04t2o000000ySqpAAE -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse-base 0.18.0.."
call sf force:package:install --package 04t7U000000LPPAQA4 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-integration  109.."
call sf force:package:install --package 04t7U000000Y36BQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-flowComponents 0.4.0.."
call sf force:package:install --package 04t7U0000008qz4QAA -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.26.0.."
call sf force:package:install --package 04t7U0000000RlpQAE -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.50-0.."
call sf force:package:install --package 04t7U000000Y2mGQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.403.0.."
call sf force:package:install --package 04t7U000000Y3aMQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 101."
call sf force:package:install --package 04t7U000000Y3I7QAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.442.9 beta.."
call sf force:package:install --package 04t7U000000Y3eJQAS -r --installation-key %3 --wait 10 --publish-wait 10

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
