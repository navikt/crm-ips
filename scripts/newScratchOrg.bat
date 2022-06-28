echo "Oppretter scratch org"
call sfdx force:org:create -f config\project-scratch-def.json --setalias Ronning68 --durationdays 20 --setdefaultusername --json --loglevel fatal  --wait 10

echo "Installerer crm-platform-base ver. 0.157"
call sfdx force:package:install --package 04t7U000000TpVEQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-integration ver. 0.79"
call sfdx force:package:install --package 04t7U000000TpVTQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-access-control ver. 0.95"
call sfdx force:package:install --package 04t7U000000TpVTQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-timeline ver. 1.15"
call sfdx force:package:install --package 04t7U000000TpOcQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-base ver. 1.1"
call sfdx force:package:install --package 04t2o000000ySqpAAE -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-arbeidsgiver-base ver. 1.234"
call sfdx force:package:install --package 04t7U000000TpGOQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-community-base ver. 0.64"
call sfdx force:package:install --package 04t7U000000TpSZQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-journal-utilities ver. 0.15.0"
call sfdx force:package:install --package 04t7U000000TpOhQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-ips ver. 0.208.0"
call sfdx force:package:install --package 04t7U000000TptVQAS -r -k %3 --wait 10 --publishwait 10

echo "Dytter kildekoden til scratch org'en"
call sfdx force:source:push

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_management

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

echo "Ferdig"
