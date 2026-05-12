# API-sikkerhet — Nav-signal

Generisk API-sikkerhet (CORS-oppsett, CSP/X-Frame-Options/HSTS, Spring `SecurityFilterChain`-boilerplate, rate-limit-filterkode, cookie `Secure/HttpOnly/SameSite`, session fixation, CSRF-teori) er utenfor scope — LLM-en kan dette. Denne referansen dekker kun Nav-spesifikk signal.

## Sporbarhet med Nav-Call-Id

`Nav-Call-Id` må propageres gjennom hele kjeden. Sett headeren ved inngang, legg den i MDC for strukturert logging, og send den videre på alle downstream-kall.

```kotlin
val callId = request.getHeader("Nav-Call-Id") ?: UUID.randomUUID().toString()
MDC.put("call_id", callId)
response.setHeader("Nav-Call-Id", callId)
```

I klientkall til andre Nav-tjenester: sett `Nav-Call-Id` på request, ikke generer en ny. Samme header brukes i accessPolicy-kontekst for audit og feilsøking.

## Nav-Consumer-Id for rate limiting og audit

Ved rate limiting mot interne konsumenter: bruk `Nav-Consumer-Id` som nøkkel før du faller tilbake på IP. Det gir meningsfull begrensning per konsument-app, ikke per Nais-pod.

## accessPolicy er primærmekanismen

CORS, IP-allowlisting og egenvalidering av `Origin` er sekundære. Det primære nettverksforsvaret på Nais-plattformen er `accessPolicy.inbound/outbound`. Se SKILL.md-seksjonen "accessPolicy som first-line defense".

For frontend-tjenester (Wonderwall foran): CSRF-beskyttelse og cookie-innstillinger håndteres normalt av Wonderwall/ingress-laget. Sjekk at appen ikke dobbel-autentiserer eller overstyrer disse.
