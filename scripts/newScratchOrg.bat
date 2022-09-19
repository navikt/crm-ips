echo "Oppretter scratch org"
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

echo "Installerer crm-platform-base ver. 0.171"
call sfdx force:package:install --package 04t7U000000TqTEQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-access-control ver. 0.103"
call sfdx force:package:install --package 04t7U000000TqSLQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer 'crm-thread-view' ver. 0.1.0"
call sfdx force:package:install --package 04t7U000000TqVFQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-timeline ver. 1.15"
call sfdx force:package:install --package 04t7U000000TpOcQAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-base ver. 1.1"
call sfdx force:package:install --package 04t2o000000ySqpAAE -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-integration ver. 0.84"
call sfdx force:package:install --package 04t7U000000TqFHQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-arbeidsgiver-base ver. 1.261"
call sfdx force:package:install --package 04t7U000000TqUMQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-community-base ver. 0.73"
call sfdx force:package:install --package 04t7U000000TqRXQA0 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-journal-utilities ver. 0.17.0"
call sfdx force:package:install --package 04t7U000000Tq8BQAS -r -k %3 --wait 10 --publishwait 10

echo "Dytter kildekoden til scratch org'en"
call sfdx force:source:push

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_management

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

echo "Ferdig"