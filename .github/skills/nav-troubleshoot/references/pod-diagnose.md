# Pod-diagnose — CrashLoopBackOff, ImagePullBackOff, Pending

Diagnostiske trær og kommando-referanse for pod-problemer på Nais.

## Steg 1: Status

```bash
# Oversikt over pods for appen
kubectl get pods -n {namespace} -l app={app-name} -o wide

# Detaljert pod-info
kubectl describe pod -n {namespace} {pod-name}

# Nais app-status
kubectl get app -n {namespace} {app-name} -o yaml | grep -A 20 status
```

## Steg 2: Logs

```bash
# Siste logs
kubectl logs -n {namespace} -l app={app-name} --tail=100

# Logs fra forrige krasj (viktig ved CrashLoopBackOff)
kubectl logs -n {namespace} {pod-name} --previous --tail=100

# Følg logs i sanntid
kubectl logs -n {namespace} -l app={app-name} -f --tail=10

# Filtrer på feilmeldinger
kubectl logs -n {namespace} -l app={app-name} --tail=500 \
  | grep -i "error\|exception\|fatal\|panic"
```

## Steg 3: Events

```bash
# Pod-events (scheduling, pulling, started, failed)
kubectl get events -n {namespace} --sort-by='.lastTimestamp' | grep {app-name}

# Namespace-events (bredere)
kubectl get events -n {namespace} --sort-by='.lastTimestamp' | tail -20
```

## Steg 4: Ressurser

```bash
# Aktuelt ressursforbruk
kubectl top pod -n {namespace} -l app={app-name}

# Ressurs-requests vs limits
kubectl get pod -n {namespace} {pod-name} \
  -o jsonpath='{.spec.containers[0].resources}'
```

## CrashLoopBackOff — vanlige Nav-spesifikke årsaker

| Log-output | Årsak | Løsning |
|-----------|-------|---------|
| `OOMKilled` | For lite minne | Øk `resources.limits.memory` i NAIS-manifest |
| `java.lang.OutOfMemoryError` | Java heap for liten | Sett `-Xmx` eller øk memory-limit (heap typisk 75 % av limit) |
| `Connection refused: localhost:5432` | Database ikke klar / Cloud SQL proxy-feil | Sjekk `gcp.sqlInstances` i manifest og Flyway-migrasjon |
| `AZURE_APP_CLIENT_ID not set` | Manglende env-var fra NAIS | Sett `azure.application.enabled: true` i manifest |
| `TOKEN_X_CLIENT_ID not set` | TokenX ikke aktivert | Sett `tokenx.enabled: true` |
| `KAFKA_BROKERS not set` | Kafka ikke konfigurert | Sett `kafka.pool: nav-dev/nav-prod` i manifest |
| Port-mismatch (readiness fails) | App lytter på feil port | `spec.port` må matche appens faktiske port |
| `No such file or directory` | Feil Dockerfile COPY | Verifiser at build-artefakt kopieres riktig |

## ImagePullBackOff

```bash
# Sjekk image-navn og tag
kubectl describe pod -n {namespace} {pod-name} | grep -A 2 Image
```

Vanlige årsaker:
- Feil image-tag (build mislyktes eller GitHub Actions-runnet har ikke pusht ferdig)
- GAR-autentisering feilet (workload identity, service account)
- Image finnes ikke i Google Artifact Registry

## Pending (pod starter aldri)

```bash
kubectl describe pod -n {namespace} {pod-name} | grep -A 5 Conditions
kubectl describe pod -n {namespace} {pod-name} | grep -A 10 Events
```

Vanlige årsaker:
- Ikke nok ressurser i klusteret (sjekk `FailedScheduling`)
- PersistentVolumeClaim ikke bundet
- Node-selektor matcher ikke

## Diagnostisk tre

```
Pod feiler
├── Status = Pending?
│   └── Se "Pending"-seksjon (scheduling, kvoter, PVC)
├── Status = ImagePullBackOff / ErrImagePull?
│   └── Se "ImagePullBackOff"-seksjon (tag, GAR, workload identity)
├── Status = CrashLoopBackOff?
│   ├── Last exit code = 137 (OOMKilled)? → øk memory limit
│   ├── Log viser "... not set" (env-var)? → manifest mangler feature-flag
│   │   (azure/tokenx/idporten/kafka/gcp.sqlInstances — se `nais-manifest`)
│   ├── Log viser "Connection refused :5432"? → se database-diagnose.md
│   ├── Log viser auth-relatert feil? → se auth-diagnose.md
│   └── Ukjent? → `kubectl logs --previous` og søk i logs
└── Status = Running men readiness fails?
    ├── Readiness-endepunkt svarer ikke → sjekk `readiness.path` vs. appens rute
    ├── App lytter på annen port enn `spec.port`
    └── App tar lang tid å starte → øk `initialDelay`
```
