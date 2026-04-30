# Pod-lifecycle og graceful shutdown i NAIS

- NAIS injiserer en `preStop`-hook med `sleep 5` før `SIGTERM` sendes til applikasjonen.
- I denne perioden slutter lastbalansereren å rute ny trafikk til poden.
- Readiness-probes er **ikke** involvert i shutdown-flyten i NAIS.
- Å sette readiness=false manuelt i app-kode har derfor ingen effekt og er et anti-mønster.
- Applikasjonen trenger kun å: (a) drenere in-flight requests og (b) avslutte rent.
- Bruk rammeverkets vanlige shutdown-mekanismer (Ktor/Spring/JVM) fremfor egne toggles.
- Ikke senk `terminationGracePeriodSeconds` under default `30` sekunder.
- Lavere grace-periode reduserer tiden appen har til drenering og kontrollert avslutning.
- Kort grace-periode øker risiko for avbrutte kall og uferdig opprydding.
