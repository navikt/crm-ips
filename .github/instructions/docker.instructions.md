---
description: "Dockerfile-standarder for Nav — Chainguard base images, multi-stage builds og sikkerhet"
applyTo: "**/Dockerfile*, **/.dockerignore"
---

# Docker — Nav

Standarder for Dockerfile i Nav: Chainguard base images, multi-stage builds og sikkerhetspraksis.

Reference: [Chainguard base images — sikkerhet.nav.no](https://sikkerhet.nav.no/docs/verktoy/chainguard-dockerimages)

## Base Images — Chainguard

Nav betaler for [Chainguard base images](https://sikkerhet.nav.no/docs/verktoy/chainguard-dockerimages) med minimale sårbarheter. Bruk disse i stedet for Google Distroless eller fulle OS-images.

### Navs private registry (JVM, Node, Python)

```
europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/<image>:<tag>
```

Tilgjengelige images: `jdk`, `jre`, `node`, `python`, `airflow-core`.

### Gratis Chainguard images (Go, nginx)

```
cgr.dev/chainguard/<image>:<tag>
```

### Tags

- Bruk major version (f.eks. `openjdk-21`, `22-slim`) — Chainguard backporter ikke
- Ikke pin SHA. Sett opp workflow for regelmessig rebuild
- Bruk [digestabot](https://github.com/navikt/digestabot) om du vil pinne SHA med automatiske PR-er

```dockerfile
# ✅ Chainguard fra Navs registry
FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/jre:openjdk-21
FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/node:22-slim

# ✅ Gratis Chainguard for Go og nginx
FROM cgr.dev/chainguard/go:latest
FROM cgr.dev/chainguard/static:latest
FROM cgr.dev/chainguard/nginx:latest

# ⚠️ Google Distroless fungerer, men Chainguard er foretrukket i Nav
FROM gcr.io/distroless/java21-debian12:nonroot

# ❌ Unngå fulle OS-images
FROM ubuntu:22.04
FROM openjdk:21
```

## Multi-Stage Builds

Alle Nav-apper skal bruke multi-stage builds.

### JVM (JAR bygget i CI — single-stage OK)

```dockerfile
FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/jre:openjdk-21
ENV TZ="Europe/Oslo"
COPY build/libs/app.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

### JVM med bygg i Dockerfile (Kotlin/Java)

```dockerfile
FROM gradle:8-jdk21 AS build
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle
RUN gradle dependencies --no-daemon
COPY src ./src
RUN gradle shadowJar --no-daemon

FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/jre:openjdk-21
WORKDIR /app
COPY --from=build /app/build/libs/*-all.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

### Node.js

```dockerfile
FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/node:22-slim
ENV NODE_ENV=production
ENV NPM_CONFIG_CACHE=/tmp
WORKDIR /app
COPY dist dist/
COPY server server/
EXPOSE 8080
CMD ["server/dist/index.js"]
```

### Node.js med bygg i Dockerfile

```dockerfile
FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/node:22-dev AS builder
WORKDIR /app
COPY . /app
RUN npm ci
RUN npm run build

FROM europe-north1-docker.pkg.dev/cgr-nav/pull-through/nav.no/node:22-slim
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build
CMD ["build/server.js"]
```

## Sikkerhet

```dockerfile
# ✅ Chainguard kjører som non-root automatisk — ingen USER nødvendig

# ✅ For andre base images — kjør som non-root
USER nonroot
USER 1001

# ✅ Minimal COPY — aldri COPY hele konteksten til final stage
COPY --from=build /app/build/libs/app.jar .

# ❌ Kopierer secrets, testfiler, .git
COPY . .
```

## .dockerignore

Lag alltid en `.dockerignore`:

```
.git
.github
node_modules
.next
build
target
*.md
docker-compose*.yml
.env*
```

## Layer Caching

```dockerfile
# ✅ Kopier avhengighetsfiler først for bedre caching
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# ❌ Invaliderer cache ved alle filendringer
COPY . .
RUN go mod download && go build
```

## CI — Chainguard-autentisering

Bruk `nais/docker-build-push` i GitHub Actions — den håndterer autentisering mot Navs Chainguard-registry automatisk:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
      - uses: nais/docker-build-push@v0
        id: docker-push
        with:
          team: <myteam>
```

## Grenser

### Alltid
- Chainguard base images fra Navs registry (JVM/Node/Python) eller `cgr.dev` (Go/nginx)
- Multi-stage builds
- `.dockerignore`-fil
- Kopier avhengigheter separat for layer caching
- `nais/docker-build-push` for CI

### Spør først
- Custom base images
- `--privileged` eller ekstra Linux capabilities
- Mounting secrets i build

### Aldri
- `COPY . .` i final stage
- Root-bruker i produksjon
- Secrets i Dockerfile (`ENV SECRET=...`, `ARG PASSWORD=...`)
- `latest`-tag på Nav registry images (bruk spesifikk major version)
- Fulle OS-images (`ubuntu`, `debian`, `openjdk`)
