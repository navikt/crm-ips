echo "Oppretter scratch org"
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

echo "Installerer crm-platform-base ver. 0.173"
call sfdx force:package:install --package 04t7U000000TqfeQAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-access-control ver. 0.104"
call sfdx force:package:install --package 04t7U000000TqXkQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-thread-view' ver. 0.1.0"
call sfdx force:package:install --package 04t7U000000TqVFQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-timeline ver. 1.18"
call sfdx force:package:install --package 04t7U000000TqbDQAS -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-base ver. 1.1"
call sfdx force:package:install --package 04t2o000000ySqpAAE -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-integration ver. 0.86"
call sfdx force:package:install --package 04t7U000000TqfjQAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-arbeidsgiver-base ver. 1.266"
call sfdx force:package:install --package 04t7U000000TqgrQAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-community-base ver. 0.75"
call sfdx force:package:install --package 04t7U000000TqevQAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-journal-utilities ver. 0.16.0"
call sfdx force:package:install --package 04t7U000000Tq6AQAS -r -k %3 --wait 10 --publishwait 10

echo "Dytter kildekoden til scratch org'en"
call sfdx force:source:push

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_management

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

echo "Ferdig"