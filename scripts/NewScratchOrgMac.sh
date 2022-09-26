 #!/bin/bash

# Oppretter scratch org
sfdx force:org:create -f config/project-scratch-def.json --setalias $1 --durationdays $2 --setdefaultusername --json --loglevel fatal  --wait 10

# Installer crm-platform-base ver. 0.169
sfdx force:package:install --package 04t7U000000TqIuQAK -r -k $3 --wait 10 --publishwait 10

# Installer crm-platform-access-control ver. 0.101
sfdx force:package:install --package 04t7U000000TpqbQAC -r -k $3 --wait 10 --publishwait 10

# Installer crm-shared-timeline 1.15.0
sfdx force:package:install --package 04t7U000000TpOcQAK --installationkey navcrm

# Installer crm-shared-base1.1.0
sfdx force:package:install --package 04t2o000000ySqpAAE --installationkey navcrm

# Installer crm-platform-integration ver. 0.78
sfdx force:package:install --package 04t7U000000Tp4DQAS -r -k $3 --wait 10 --publishwait 10

# Installer crm-arbeidsgiver-base 1.248.0
sfdx force:package:install --package 04t7U000000TqCwQAK --installationkey navcrm

# Installer crm-community-base ver. 0.71
sfdx force:package:install --package 04t7U000000TqLFQA0 -r -k $3 --wait 10 --publishwait 10

# Installer crm-journal-utilities 0.17.0
sfdx force:package:install --package 04t7U000000Tq8BQAS --installationkey navcrm

# Installer crm-ips 0.236.0
sfdx force:package:install --package 04t7U000000TqWNQA0 --installationkey navcrm

# Dytt kildekoden til scratch org'en
sfdx force:source:push

# Tildel tilatelsessett til brukeren
sfdx force:user:permset:assign --permsetname IPS_management

# Tildel tilatelsessett til brukeren
sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

# Opprett testdata
# må gjøres en gang

# Ferdig