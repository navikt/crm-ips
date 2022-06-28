echo "Oppretter scratch org"
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

echo "Installerer crm-platform-base ver. 0.153"
call sfdx force:package:install --package 04t7U000000TpC2QAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-integration ver. 0.78"
call sfdx force:package:install --package 04t7U000000Tp4DQAS -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-access-control ver. 0.94"
call sfdx force:package:install --package 04t7U000000TpJrQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-timeline ver. 1.14"
call sfdx force:package:install --package 04t7U000000TpG4QAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-base ver. 1.1"
call sfdx force:package:install --package 04t2o000000ySqpAAE -r -k %3 --wait 10 --publishwait 10


echo "Installerer crm-arbeidsgiver-base ver. 1.234"
call sfdx force:package:install --package 04t7U000000TpGOQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-community-base ver. 0.63"
call sfdx force:package:install --package 04t7U000000Tp7WQAS -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-journal-utilities ver. 0.13.0"
call sfdx force:package:install --package 04t7U000000ToHfQAK -r -k %3 --wait 10 --publishwait 10

echo "Dytter kildekoden til scratch org'en"
call sfdx force:source:push

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_management

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

echo "Ferdig"
