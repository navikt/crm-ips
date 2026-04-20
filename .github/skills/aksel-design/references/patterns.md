# Mønstre

Disse mønstrene er ment som startpunkter. Tilpass dem til eksisterende arkitektur og komponentmønstre i løsningen.

## Sidecontainer

Bruk `Box` + `VStack` som standard sidecontainer med responsiv padding.

```tsx
import { BodyLong, Box, Heading, VStack } from "@navikt/ds-react";

export function PageContainer(): JSX.Element {
  return (
    <Box as="main" paddingBlock={{ xs: "space-16", md: "space-24" }} paddingInline={{ xs: "space-16", lg: "space-32" }}>
      <VStack gap="space-24">
        <VStack gap="space-8">
          <Heading size="large" level="1">Page title</Heading>
          <BodyLong>Intro text for the page.</BodyLong>
        </VStack>
        <section>Page content</section>
      </VStack>
    </Box>
  );
}
```

## Kortmønster

Bruk `Box` som base for kort. Hold kortene rolige og konsekvente.

```tsx
import { BodyShort, Box, Heading, VStack } from "@navikt/ds-react";

export function StatusCard(): JSX.Element {
  return (
    <Box background="default" borderColor="neutral-subtle" borderRadius="12" borderWidth="1" padding="space-16">
      <VStack gap="space-8">
        <Heading size="small" level="3">Case status</Heading>
        <BodyShort>Waiting for documentation.</BodyShort>
      </VStack>
    </Box>
  );
}
```

## Skjemalayout

Bruk `VStack` for felt og `HStack` for handlingsraden.

```tsx
import { Button, HStack, TextField, VStack } from "@navikt/ds-react";

export function ProfileForm(): JSX.Element {
  return (
    <VStack as="form" gap="space-16">
      <TextField label="First name" autoComplete="given-name" />
      <TextField label="Last name" autoComplete="family-name" />
      <TextField label="Email" autoComplete="email" type="email" />
      <HStack gap="space-8" justify="end" wrap>
        <Button variant="secondary">Cancel</Button>
        <Button>Save</Button>
      </HStack>
    </VStack>
  );
}
```

## Dashboard-rutenett

Bruk `HGrid` til kort og oversikter. La antall kolonner styres av breakpoints.

```tsx
import { Box, HGrid } from "@navikt/ds-react";

export function Dashboard(): JSX.Element {
  return (
    <HGrid columns={{ xs: 1, md: 2, xl: 3 }} gap="space-16">
      <Box padding="space-16" background="neutral-soft">Open tasks</Box>
      <Box padding="space-16" background="neutral-soft">Messages</Box>
      <Box padding="space-16" background="neutral-soft">Deadlines</Box>
    </HGrid>
  );
}
```

## Tospaltet layout

Bruk `HGrid` eller `Stack direction` for tydelig hovedinnhold + sideinnhold.

```tsx
import { Box, HGrid, VStack } from "@navikt/ds-react";

export function TwoColumnLayout(): JSX.Element {
  return (
    <HGrid columns={{ xs: 1, lg: "2fr 1fr" }} gap={{ xs: "space-16", lg: "space-24" }}>
      <VStack gap="space-16">
        <Box padding="space-16" background="default">Main content</Box>
        <Box padding="space-16" background="default">More content</Box>
      </VStack>
      <Box padding="space-16" background="neutral-soft">Sidebar</Box>
    </HGrid>
  );
}
```

## Filterseksjon

Samle filtre i en rolig seksjon med luft og tydelig gruppering.

```tsx
import { Button, HStack, Select, TextField, VStack } from "@navikt/ds-react";

export function FilterSection(): JSX.Element {
  return (
    <VStack gap="space-12" as="section">
      <TextField label="Search" />
      <Select label="Status">
        <option value="all">All</option>
        <option value="open">Open</option>
        <option value="closed">Closed</option>
      </Select>
      <HStack gap="space-8" wrap>
        <Button>Apply filters</Button>
        <Button variant="secondary">Reset</Button>
      </HStack>
    </VStack>
  );
}
```

## Lastertilstander

Bruk en eksplisitt lastetilstand i layouten. Hold høyde og rytme stabil.

```tsx
import { BodyShort, Box, Loader, VStack } from "@navikt/ds-react";

export function LoadingPanel(): JSX.Element {
  return (
    <Box padding="space-16" background="neutral-soft" aria-busy="true">
      <VStack gap="space-12" align="center">
        <Loader title="Loading" />
        <BodyShort as="div" aria-live="polite">Loading data…</BodyShort>
      </VStack>
    </Box>
  );
}
```

## Feilhåndtering

Vis tydelig feil med både oppsummering og lokal kontekst når skjemaet krever det.

```tsx
import { ErrorSummary, LocalAlert, VStack } from "@navikt/ds-react";

export function ErrorState(): JSX.Element {
  return (
    <VStack gap="space-16">
      <LocalAlert status="error">
        <LocalAlert.Content>We could not save your changes.</LocalAlert.Content>
      </LocalAlert>
      <ErrorSummary heading="Fix these fields before retrying:">
        <ErrorSummary.Item href="#name">Name is required</ErrorSummary.Item>
        <ErrorSummary.Item href="#email">Email is invalid</ErrorSummary.Item>
      </ErrorSummary>
    </VStack>
  );
}
```

## Bleed for full-width sections

Bruk `Bleed` når innhold skal strekke seg utover containerens padding uten å bryte resten av sideoppsettet.

```tsx
import { Bleed, BodyLong, Box } from "@navikt/ds-react";

export function FullWidthSection(): JSX.Element {
  return (
    <Box padding={{ xs: "space-16", md: "space-24" }} background="default">
      <Bleed marginInline={{ xs: "space-16", md: "space-24" }}>
        <Box background="neutral-soft" padding="space-16">
          <BodyLong>Full-width announcement</BodyLong>
        </Box>
      </Bleed>
    </Box>
  );
}
```

## Kvitteringsmønster

Bygg kvitteringer som en tydelig oppsummering med overskrift, nøkkelinformasjon og neste steg.

```tsx
import { BodyLong, BodyShort, Box, Heading, VStack } from "@navikt/ds-react";

export function Receipt(): JSX.Element {
  return (
    <Box background="default" borderColor="neutral-subtle" borderRadius="12" borderWidth="1" padding="space-24">
      <VStack gap="space-16">
        <VStack gap="space-8">
          <Heading size="medium" level="2">Application received</Heading>
          <BodyLong>We have registered your application.</BodyLong>
        </VStack>
        <VStack gap="space-4">
          <BodyShort weight="semibold">Reference number</BodyShort>
          <BodyShort>123456789</BodyShort>
        </VStack>
        <BodyShort>Next step: we will contact you if anything is missing.</BodyShort>
      </VStack>
    </Box>
  );
}
```

## Knapprad

Handlinger skal være enkle å skanne og fungere på små skjermer.

```tsx
import { Button, HStack } from "@navikt/ds-react";

export function ButtonRow(): JSX.Element {
  return (
    <HStack gap="space-8" justify="end" wrap>
      <Button variant="tertiary">Back</Button>
      <Button variant="secondary">Save draft</Button>
      <Button>Continue</Button>
    </HStack>
  );
}
```

## Tag-container

Bruk `HStack` med `wrap` rundt `Tag` når innholdet kan bryte over flere linjer.

```tsx
import { HStack, Tag } from "@navikt/ds-react";

export function TagsContainer(): JSX.Element {
  return (
    <HStack gap="space-8" wrap>
      <Tag size="small">Needs review</Tag>
      <Tag size="small">Approved</Tag>
      <Tag size="small">Missing docs</Tag>
    </HStack>
  );
}
```

## Next.js-integrasjon

Aksel-komponenter fungerer i Next.js (App Router og Pages Router). To ting å være bevisst på:

**1. Bruk `LinkCard` med Next.js `Link`** så forhåndshenting (`prefetch`) og klient-navigering fungerer:

```tsx
import { LinkCard, LinkCardAnchor, LinkCardDescription, LinkCardTitle } from "@navikt/ds-react";
import Link from "next/link";

export function DashboardCard(): JSX.Element {
  return (
    <LinkCard>
      <LinkCardTitle>
        <LinkCardAnchor as={Link} href="/dashboard">Dashboard</LinkCardAnchor>
      </LinkCardTitle>
      <LinkCardDescription>Se statistikk og nøkkeltall.</LinkCardDescription>
    </LinkCard>
  );
}
```

**2. Komponenter med intern state (`Dialog`, `DialogTrigger`, `ExpansionCard`, `Tabs`) er klient-komponenter.** Merk fila eller wrapperen med `"use client"` i App Router:

```tsx
"use client";

import { Button, Dialog, DialogPopup, DialogTrigger } from "@navikt/ds-react";

export function EditButton(): JSX.Element {
  return (
    <Dialog>
      <DialogTrigger>
        <Button>Edit</Button>
      </DialogTrigger>
      <DialogPopup>{/* ... */}</DialogPopup>
    </Dialog>
  );
}
```

**3. SSR-considerations**: Aksel-komponenter rendrer server-side uten problemer. CSS-importen (`@import "@navikt/ds-css"`) bør ligge i `app/layout.tsx` (App Router) eller `pages/_app.tsx` (Pages Router) slik at den inkluderes i den kritiske stilen.

**4. Sidecontainer med max-width**: Standard Nav-mønster er å wrappe sideinnhold i en max-width-container:

```tsx
import { Box, VStack } from "@navikt/ds-react";

export default function Page(): JSX.Element {
  return (
    <main style={{ maxWidth: "1128px", margin: "0 auto" }}>
      <Box
        paddingBlock={{ xs: "space-16", md: "space-24" }}
        paddingInline={{ xs: "space-16", md: "space-32" }}
      >
        <VStack gap={{ xs: "space-16", md: "space-24" }}>
          {/* Sideinnhold */}
        </VStack>
      </Box>
    </main>
  );
}
```

## Stablede systemmeldinger

Vis flere `LocalAlert`-er over hverandre når systemet har flere aktive meldinger — bruk `VStack` for konsistent rytme.

```tsx
import { LocalAlert, VStack } from "@navikt/ds-react";

type Message = { id: string; status: "info" | "warning" | "error" | "success"; text: string };

export function SystemMessages({ messages }: { messages: Message[] }): JSX.Element {
  return (
    <VStack gap="space-8">
      {messages.map(({ id, status, text }) => (
        <LocalAlert key={id} status={status}>
          <LocalAlert.Content>{text}</LocalAlert.Content>
        </LocalAlert>
      ))}
    </VStack>
  );
}
```

## Skip-link for tastaturnavigasjon

Gi tastaturbrukere en måte å hoppe over repeterende navigasjon. Skip-linken skal være synlig ved fokus, ellers skjult.

```tsx
import { Link } from "@navikt/ds-react";

export function SkipLink(): JSX.Element {
  return (
    <Link href="#main-content" className="skip-link">
      Hopp til hovedinnhold
    </Link>
  );
}

// I layout/page:
// <SkipLink />
// <nav>…</nav>
// <main id="main-content">…</main>
```

CSS-mønster for skip-link som kun vises ved fokus:

```css
.skip-link {
  position: absolute;
  inset-block-start: 0;
  inset-inline-start: 0;
  transform: translateY(-100%);
  padding: var(--a-space-8) var(--a-space-16);
  background: var(--ax-bg-default);
  color: var(--ax-text-neutral);
}

.skip-link:focus {
  transform: translateY(0);
}
```

## Fokushåndtering ved feil

Flytt fokus til første feilfelt eller til `ErrorSummary` ved validering. Brukeren skal ikke måtte lete.

```tsx
import { ErrorSummary, TextField, VStack } from "@navikt/ds-react";
import { useEffect, useRef } from "react";

export function FormWithFocus({ errors }: { errors: Record<string, string> }): JSX.Element {
  const summaryRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (Object.keys(errors).length > 0) {
      summaryRef.current?.focus();
    }
  }, [errors]);

  return (
    <VStack gap="space-16">
      {Object.keys(errors).length > 0 && (
        <ErrorSummary ref={summaryRef} heading="Fix these fields:" tabIndex={-1}>
          {Object.entries(errors).map(([field, message]) => (
            <ErrorSummary.Item key={field} href={`#${field}`}>{message}</ErrorSummary.Item>
          ))}
        </ErrorSummary>
      )}
      <TextField id="name" label="Name" error={errors.name} />
      <TextField id="email" label="Email" error={errors.email} />
    </VStack>
  );
}
```

## Valg mellom mønstrene

- Side eller seksjon → `Sidecontainer`
- Oppsummering eller statusboks → `Kortmønster`
- Skjema → `Skjemalayout` + `Feilhåndtering`
- Oversikter → `Dashboard-rutenett` eller `Tospaltet layout`
- Banner eller fremhevet stripe → `Bleed`
- Ferdigstilt steg → `Kvitteringsmønster`
