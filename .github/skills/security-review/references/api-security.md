# API-sikkerhet — Nav-signal

Generisk API-sikkerhet (CORS-oppsett, CSP/X-Frame-Options/HSTS, Spring `SecurityFilterChain`-boilerplate, rate-limit-filterkode, cookie `Secure/HttpOnly/SameSite`, session fixation, CSRF-teori) er utenfor scope — LLM-en kan dette. Denne referansen dekker kun Nav-spesifikk signal.

## Sporbarhet med Nav-Call-Id

`Nav-Call-Id` må propageres gjennom hele kjeden. Sett headeren ved inngang, legg den i MDC for strukturert logging, og send den videre på alle downstream-kall.

```kotlin
val callId = request.getHeader("Nav-Call-Id") ?: UUID.randomUUID().toString()
MDC.put("call_id", callId)
response.setHeader("Nav-Call-Id", callId)
```

I klientkall til andre Nav-tjenester: sett `Nav-Call-Id` på request, ikke generer en ny. Headeren brukes for korrelasjon, audit og feilsøking på tvers av tjenester. Den er ikke koblet til `accessPolicy`, som er Nais sin nettverkskontroll.

## Nav-Consumer-Id for rate limiting og audit

Ved rate limiting mot interne konsumenter: bruk `Nav-Consumer-Id` som nøkkel før du faller tilbake på IP. Det gir meningsfull begrensning per konsument-app, ikke per Nais-pod.

## accessPolicy er primærmekanismen

CORS, IP-allowlisting og egenvalidering av `Origin` er sekundære. Det primære nettverksforsvaret på Nais-plattformen er `accessPolicy.inbound/outbound`. Se SKILL.md-seksjonen "accessPolicy som first-line defense".

For frontend-tjenester (Wonderwall foran): CSRF-beskyttelse og cookie-innstillinger håndteres normalt av Wonderwall/ingress-laget. Sjekk at appen ikke dobbel-autentiserer eller overstyrer disse.

## Utvalgte OWASP API Top 10:2023-signaler for Nav

Bruk tabellen som en rask sjekk ved review. Den viser et utvalg av signaler og erstatter ikke Nav-vurderingene i SKILL.md eller trusselmodellen.

| OWASP API | Typisk Nav-signal | Sjekk i praksis |
|-----------|-------------------|-----------------|
| API1 Broken Object Level Authorization | Bruker eller ansatt kan slå opp ressurs med ID de ikke eier | Verifiser eierskap/sakstilhørighet, ikke bare at tokenet er gyldig |
| API2 Broken Authentication | Feil issuer/audience eller manglende `azp`-sjekk | Sjekk JWT-validering, pre-authorized apps og riktig auth-mekanisme |
| API3 Broken Object Property Level Authorization | API returnerer eller aksepterer felter klienten ikke skal se eller styre | Whitelist DTO-felter, ikke eksponer interne felter eller masseoppdatering ukritisk |
| API4 Unrestricted Resource Consumption | Kostbare kall kan spammes eller tømme CPU/minne | Sjekk paginering, payload-grenser, rate limiting og dyre business-flyter |
| API5 Broken Function Level Authorization | Vanlige brukere når admin- eller saksbehandlerfunksjoner | Sjekk rollegrenser, gruppesjekker og egne grener for kode 6/7 og egen ansatt |
| API7 SSRF | API henter videre URL eller host fra input | Begrens outbound med `accessPolicy`, whitelist hoster og valider destinasjon |
| API8 Security Misconfiguration | Åpen ingress, feil `accessPolicy`, debug-endepunkt eller feil CORS | Sjekk manifest, ingress, interne endepunkter og at Wonderwall/NAIS ikke overstyres |
| API10 Unsafe Consumption of APIs | Tredjeparts-API stoles på mer enn eget input | Valider svar, timeouts, retry-strategi og dataminimering mot eksterne kall |
