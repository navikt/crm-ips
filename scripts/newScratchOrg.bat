echo "Oppretter scratch org"
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

echo "Installerer crm-platform-base ver. 0.148"
call sfdx force:package:install --package 04t7U000000ToQrQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-access-control ver. 0.83"
call sfdx force:package:install --package 04t7U000000TnyOQAS -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-timeline ver. 1.12"
call sfdx force:package:install --package 04t7U000000TnjxQAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-base ver. 1.1"
call sfdx force:package:install --package 04t2o000000ySqpAAE -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-integration ver. 0.74"
call sfdx force:package:install --package 04t7U000000ToLcQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-arbeidsgiver-base ver. 1.219"
call sfdx force:package:install --package 04t7U000000ToNYQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-community-base ver. 0.48"
call sfdx force:package:install --package 04t7U000000ToLwQAK -r -k %3 --wait 10 --publishwait 10

echo "Dytter kildekoden til scratch org'en"
call sfdx force:source:push

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_management

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

echo "Ferdig"
