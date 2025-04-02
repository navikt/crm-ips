echo "Oppretter scratch org"
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

echo "Installerer crm-platform-base ver. 0.265"
call sfdx force:package:install --package 04tKB000000YD8fYAG -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-access-control ver. 0.160"
call sfdx force:package:install --package 04tKB000000YBLfYAO -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-thread-view' ver. 0.5.0"
call sfdx force:package:install --package 04tKB000000Y8nqYAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-reporting ver. 0.41"
call sfdx force:package:install --package 04tKB000000YAWDYA4 -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-timeline ver. 1.29"
call sfdx force:package:install --package 04tKB000000Y8znYAC -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-base ver. 1.1"
call sfdx force:package:install --package 04t2o000000ySqpAAE -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-flowComponents 0.4.0.."
call sfdx force:package:install --package 04t7U0000008qz4QAA -r -k %3 --wait 10 --publishwait 10

echo "Installer crm-henvendelse-base ver. 0.31.0"
call sfdx force:package:install --package 04tKB000000Y9AdYAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-integration ver. 0.153"
call sfdx force:package:install --package 04tKB000000YCcTYAW -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-journal-utilities ver. 0.43.0"
call sfdx force:package:install --package 04tKB000000Y9WtYAK -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-platform-oppgave ver. 0.64"
call sfdx force:package:install --package 04tKB000000YB09YAG -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-arbeidsgiver-base ver. 1.537"
call sfdx force:package:install --package 04tKB000000YD99YAG -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-community-base ver. 0.120"
call sfdx force:package:install --package 04tKB000000YBG5YAO -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-shared-user-notification ver. 0.24"
call sfdx force:package:install --package 04t7U000000Y4jZQAS -r -k %3 --wait 10 --publishwait 10

echo "Installerer crm-henvendelse' ver. 0.165.0"
call sfdx force:package:install --package 04tKB000000YBxcYAG -r -k %3 --wait 10 --publishwait 10

edho "Installer crm-ips ver 0.484.0"
call sfdx force:ackage:install --package 04tKB000000YD73YAG -r -k %3  --wait 10 --publishwait 10

echo "Dytter kildekoden til scratch org'en"
call sfdx force:source:push

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_management

echo "Tildeler tilatelsessett til brukeren"
call sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

echo "Ferdig"
