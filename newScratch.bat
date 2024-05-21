echo "Oppretter scratch org"
call sf org create scratch --alias %1 --set-default --definition-file config/project-scratch-def.json --duration-days %2 --wait 10

call sf force:org:open --target-org %1


echo "INSTALLERER"
echo "Installerer platform-base 218.."
call sf force:package:install --package 04t7U000000Y3esQAC -r --installation-key %3 --wait 4 --publish-wait 4

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
echo "Installerer crm-platform-reporting 0.38.0.."
call sf force:package:install --package 04t7U000000Y3yYQAS -r --installation-key %3 --wait 4 --publish-wait 4

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
echo "Installerer crm-platform-integration  110.."
call sf force:package:install --package 04t7U000000Y3pWQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-shared-flowComponents 0.4.0.."
call sf force:package:install --package 04t7U0000008qz4QAA -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-journal-utilities 0.29.0.."
call sf force:package:install --package 04t7U000000Y3zWQAS -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-platform-oppgave 0.53-0.."
call sf force:package:install --package 04t7U000000Y3r3QAC -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-arbeidsgiver-base 1.420.0.."
call sf force:package:install --package 04t7U000000Y471QAC -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-community-base 108."
call sf force:package:install --package 04t7U000000Y46wQAC -r --installation-key %3 --wait 4 --publish-wait 4

echo ""
echo "INSTALLERER"
echo "Installerer crm-ips 0.450.0.."
call sf force:package:install --package 04t7U000000Y46SQAS -r --installation-key %3 --wait 10 --publish-wait 10

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
