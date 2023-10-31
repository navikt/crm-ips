## CRM-IPS
Jobbsporet is work-oriented follow-up tool.
Interaction between job specialists and a person who wants help to get into work. Expertise in guidance and knowledge of the labor market is essential for a targeted service.
Joppsporet is a tool for job specialists to have an efficient everyday life with planning and documentation of the participant and to use the time as much as possible together with the participant.

## Dependencies

This package is dependant on the following packages

- [crm-platform-base](https://github.com/navikt/crm-platform-base)
- [crm-henvendelse-base](https://github.com/navikt/crm-henvendelse-base)
- [crm-platform-access-control](https://github.com/navikt/crm-platform-access-control)
- [crm-henvendelse](https://github.com/navikt/crm-henvendelse)
- [crm-thread-view](https://github.com/navikt/crm-thread-view)
- [crm-shared-timeline](https://github.com/navikt/crm-shared-timeline)
- [crm-shared-base](https://github.com/navikt/crm-shared-base)
- [crm-shared-flowComponents](https://github.com/navikt/crm-shared-flowComponents)
- [crm-platform-integration](https://github.com/navikt/crm-platform-integration)
- [crm-platform-oppgave](https://github.com/navikt/crm-platform-oppgave)
- [crm-arbeidsgiver-base](https://github.com/navikt/crm-arbeidsgiver-base)
- [crm-community-base](https://github.com/navikt/crm-community-base)
- [crm-journal-utilities](https://github.com/navikt/crm-journal-utilities)

## Installation

1. Install [npm](https://nodejs.org/en/download/)
1. Install [Salesforce DX CLI](https://developer.salesforce.com/tools/sfdxcli)
    - Alternative: `npm install sfdx-cli --global`
1. Clone this repository ([GitHub Desktop](https://desktop.github.com) is recommended for non-developers)
1. Run `npm install` from the project root folder
1. Install [SSDX](https://github.com/navikt/ssdx)
    - **Non-developers may stop after this step**
1. Install [VS Code](https://code.visualstudio.com) (recommended)
    - Install [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
    - **Install recommended plugins!** A notification should appear when opening VS Code. It will prompt you to install recommended plugins.
1. Install [AdoptOpenJDK](https://adoptopenjdk.net) (only version 8 or 11)
1. Open VS Code settings and search for `salesforcedx-vscode-apex`
1. Under `Java Home`, add the following:
    - macOS: `/Library/Java/JavaVirtualMachines/adoptopenjdk-[VERSION_NUMBER].jdk/Contents/Home`
    - Windows: `C:\\Program Files\\AdoptOpenJDK\\jdk-[VERSION_NUMBER]-hotspot`

## Build

To build locally without using SSDX, do the following:

1. If you haven't authenticated a DX user to production / DevHub, run `sfdx auth:web:login -d -a production` and log in
    - Ask `#crm-platform-team` on Slack if you don't have a user
    - If you change from one repo to another, you can change the default DevHub username in `.sfdx/sfdx-config.json`, but you can also just run the command above
1. Create a scratch org, install dependencies and push metadata:

```bash
sfdx force:org:create -f ./config/project-scratch-def.json --setalias scratch_org --durationdays 1 --setdefaultusername
echo y | sfdx plugins:install sfpowerkit@2.0.1
keys="" && for p in $(sfdx force:package:list --json | jq '.result | .[].Name' -r); do keys+=$p":PACKAGE_KEY "; done
sfdx sfpowerkit:package:dependencies:install -u scratch_org -r -a -w 60 -k ${keys}
sfdx force:source:push
sfdx force:org:open
```

## Other

Questions? Ask on #crm-platform-team on Slack.
