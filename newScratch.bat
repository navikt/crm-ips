echo "Oppretter scratch org"
call sf org create scratch --alias %1 --set-default --definition-file config/project-scratch-def.json --duration-days %2 --wait 10

call sf force:org:open --target-org %1


echo "INSTALLERER"
echo "Installerer platform-base 198.."
call sf force:package:install --package 04t7U000000LPIYQA4 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-access-controll 115.."
call sf force:package:install --package 04t7U000000Y2LoQAK -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-thread-view 0.2.0.."
call sf force:package:install --package 04t7U000000TqvIQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-timeline 1.21.0.."
call sf force:package:install --package 04t7U0000004dytQAA -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-base 1.1.0.."
call sf force:package:install --package 04t2o000000ySqpAAE -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-henvendelse base 0.18.0.."
call sf force:package:install --package 04t7U000000LPPAQA4 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-integrasjon 102.."
call sf force:package:install --package 04t7U000000Y25vQAC -r --installation-key %3 --wait 4 --publish-wait 4

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
echo "Installerer crm-platform-oppgave 0.49-0.."
call sf force:package:install --package 04t7U000000D2SOQA0 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.346.0.."
call sf force:package:install --package 04t7U000000Y2MDQA0 -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer platform-community-base 93."
call sf force:package:install --package 04t7U000000Y26AQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.425.0.."
call sf force:package:install --package 04t7U000000Y2M8QAK -r --installation-key %3 --wait 10 --publish-wait 10

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