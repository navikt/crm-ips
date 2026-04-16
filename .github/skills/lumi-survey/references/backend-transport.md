## Fase 5: Backend-endepunkt

Widgeten sender tilbakemelding til DITT backend, som utveksler token og videresender til Lumi API.

### 5a. Detekter backend-type

Basert på kartleggingen i Fase 1, implementer riktig mønster:

### Node.js backend (Next.js API route, Express, TanStack Start server function)

```tsx
import { getToken, requestOboToken } from "@navikt/oasis";

// I din API route handler (tilpass til rammeverket):
export async function POST(request: Request) {
  const token = getToken(request);
  if (!token) return new Response("Unauthorized", { status: 401 });

  const obo = await requestOboToken(token, process.env.LUMI_AUDIENCE!);
  if (!obo.ok) return new Response("Token exchange failed", { status: 502 });

  const body = await request.json();

  // Endepunkt settes via LUMI_FEEDBACK_PATH (se Fase 6a)
  const response = await fetch(`${process.env.LUMI_API_HOST}${process.env.LUMI_FEEDBACK_PATH}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${obo.token}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) return new Response("Lumi API error", { status: response.status });
  return new Response(null, { status: 204 });
}
```

### Kotlin backend (Ktor / Spring Boot BFF)

```kotlin
// Ktor route-eksempel
post("/api/lumi/feedback") {
    val userToken = call.request.authorization()?.removePrefix("Bearer ")
        ?: return@post call.respond(HttpStatusCode.Unauthorized)

    // Token-utveksling via Texas sidecar
    val identityProvider = System.getenv("LUMI_IDENTITY_PROVIDER") // "tokenx" eller "azuread"
    val oboResponse = httpClient.post("http://localhost:3000/api/v1/token/exchange") {
        contentType(ContentType.Application.Json)
        setBody(mapOf(
            "identity_provider" to identityProvider,
            "target" to System.getenv("LUMI_AUDIENCE"),
            "user_token" to userToken,
        ))
    }

    val oboToken = oboResponse.body<TokenResponse>().access_token
    val payload = call.receiveText()

    // Endepunkt settes via LUMI_FEEDBACK_PATH (se Fase 6a)
    val feedbackPath = System.getenv("LUMI_FEEDBACK_PATH")
    val lumiResponse = httpClient.post("${System.getenv("LUMI_API_HOST")}${feedbackPath}") {
        contentType(ContentType.Application.Json)
        bearerAuth(oboToken)
        setBody(payload)
    }

    call.respond(lumiResponse.status)
}
```

### 5b. Endepunkt per auth-type

| Auth-type | `LUMI_FEEDBACK_PATH` |
|-----------|----------------------|
| TokenX | `/api/tokenx/v1/feedback` |
| AzureAD | `/api/azure/v1/feedback` |
