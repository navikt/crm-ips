 #!/bin/bash

# Oppretter scratch org
sfdx force:org:create -f config/project-scratch-def.json --setalias $1 --durationdays $2 --setdefaultusername --json --loglevel fatal  --wait 10

# Installer crm-platform-base ver. 0.173
sfdx force:package:install --package 04t7U000000TqfeQAC -r -k $3 --wait 10 --publishwait 10

# Installer crm-platform-access-control ver. 0.104
sfdx force:package:install --package 04t7U000000TqXkQAK -r -k $3 --wait 10 --publishwait 10

#Installer crm-thread-view 0.1.0
sfdx force:package:install --package 04t7U000000TqVFQA0 -r -k $3 --wait 10 --publishwait 10

# Installer crm-shared-timeline 1.18.0
sfdx force:package:install --package 04t7U000000TqbDQAS -r -k $3 --wait 10 --publishwait 10

# Installer crm-shared-base1.1.0
sfdx force:package:install --package 04t2o000000ySqpAAE -r -k $3 --wait 10 --publishwait 10

# Installer crm-platform-integration ver. 0.86
sfdx force:package:install --package 04t7U000000TqfjQAC -r -k $3 --wait 10 --publishwait 10

# Installer crm-arbeidsgiver-base 1.266.0
sfdx force:package:install --package 04t7U000000TqgrQAC -r -k $3 --wait 10 --publishwait 10

# Installer crm-community-base ver. 0.75
sfdx force:package:install --package 04t7U000000TqevQAC -r -k $3 --wait 10 --publishwait 10

# Installer crm-journal-utilities 0.17.0
sfdx force:package:install --package 04t7U000000Tq8BQAS -r -k $3 --wait 10 --publishwait 10

# Installer crm-ips 0.278.0
sfdx force:package:install --package 04t7U000000TqzUQAS -r -k $3 --wait 10 --publishwait 10


# Dytt kildekoden til scratch org'en
sfdx force:source:push

# Tildel tilatelsessett til brukeren
sfdx force:user:permset:assign --permsetname IPS_management

# Tildel tilatelsessett til brukeren
sfdx force:user:permset:assign --permsetname IPS_Utvidet_oppf_lging_management

# Opprett testdata
# må gjøres en gang

# Ferdig