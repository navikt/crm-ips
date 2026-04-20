# Komponenter

Oppslagsverk for vanlige Aksel-komponenter brukt i Nav-frontend. Eksemplene er bevisst korte og skrevet i TSX.

## Box

Bruk `Box` for innpakning, padding, bakgrunn, border og radius.

**Nyttige props**
- `padding`, `paddingInline`, `paddingBlock`
- `background`
- `borderRadius`
- `borderWidth`
- `borderColor`

```tsx
import { BodyShort, Box } from "@navikt/ds-react";

export function SettingsCard(): JSX.Element {
  return (
    <Box
      background="default"
      borderColor="neutral-subtle"
      borderRadius="12"
      borderWidth="1"
      padding={{ xs: "space-16", md: "space-24" }}
    >
      <BodyShort>Settings content</BodyShort>
    </Box>
  );
}
```

## VStack

Bruk `VStack` for vertikal layout med tydelig rytme.

**Nyttige props**
- `gap`
- `align`
- `as`

```tsx
import { BodyShort, Heading, VStack } from "@navikt/ds-react";

export function SummarySection(): JSX.Element {
  return (
    <VStack gap="space-12" as="section">
      <Heading size="medium" level="2">Summary</Heading>
      <BodyShort>Short explanation</BodyShort>
      <BodyShort>Another row of content</BodyShort>
    </VStack>
  );
}
```

## HStack

Bruk `HStack` for rader, actions og små grupper av innhold.

**Nyttige props**
- `gap`
- `align`
- `justify`
- `wrap`

```tsx
import { Button, HStack } from "@navikt/ds-react";

export function Actions(): JSX.Element {
  return (
    <HStack gap="space-8" justify="end" wrap>
      <Button variant="secondary">Cancel</Button>
      <Button variant="primary">Save</Button>
    </HStack>
  );
}
```

## HGrid

Bruk `HGrid` når du trenger responsive kolonner.

**Nyttige props**
- `columns`
- `gap`
- `align`

```tsx
import { Box, HGrid } from "@navikt/ds-react";

export function DashboardGrid(): JSX.Element {
  return (
    <HGrid columns={{ xs: 1, md: 2, xl: 3 }} gap={{ xs: "space-12", md: "space-24" }}>
      <Box padding="space-16" background="neutral-soft">Card A</Box>
      <Box padding="space-16" background="neutral-soft">Card B</Box>
      <Box padding="space-16" background="neutral-soft">Card C</Box>
    </HGrid>
  );
}
```

## Button

Bruk Aksel `Button` for standard handlinger.

**Nyttige props**
- `variant`: `primary`, `secondary`, `tertiary`
- `size`: `medium` (default), `small`, `xsmall` — merk: `large` finnes ikke
- `loading`
- `icon`, `iconPosition`

```tsx
import { Button, HStack } from "@navikt/ds-react";

export function SubmitRow(): JSX.Element {
  return (
    <HStack gap="space-8">
      <Button variant="primary">Submit</Button>
      <Button variant="secondary">Preview</Button>
      <Button variant="tertiary">Back</Button>
      <Button data-color="danger">Delete</Button>
    </HStack>
  );
}
```

## TextField

Bruk `TextField` for enlinjefelt.

**Nyttige props**
- `label`
- `description`
- `error`
- `autoComplete`
- `type`

```tsx
import { TextField } from "@navikt/ds-react";

export function EmailField(): JSX.Element {
  return (
    <TextField
      autoComplete="email"
      description="We will send updates to this address."
      error={undefined}
      label="Email"
      type="email"
    />
  );
}
```

## Select

Bruk `Select` når brukeren skal velge én verdi fra en kort liste.

**Nyttige props**
- `label`
- `description`
- `error`
- `children` med `<option>`

```tsx
import { Select } from "@navikt/ds-react";

export function CountrySelect(): JSX.Element {
  return (
    <Select label="Country">
      <option value="">Choose a country</option>
      <option value="no">Norway</option>
      <option value="se">Sweden</option>
      <option value="dk">Denmark</option>
    </Select>
  );
}
```

## Checkbox

Bruk `Checkbox` for uavhengige valg. Bruk `CheckboxGroup` for relaterte valg.

```tsx
import { Checkbox, CheckboxGroup } from "@navikt/ds-react";

export function FruitCheckboxes(): JSX.Element {
  return (
    <CheckboxGroup legend="Choose fruits" description="Select one or more options.">
      <Checkbox value="apple">Apple</Checkbox>
      <Checkbox value="orange" description="Seasonal option">Orange</Checkbox>
      <Checkbox value="banana">Banana</Checkbox>
    </CheckboxGroup>
  );
}
```

## Radio

Bruk `RadioGroup` + `Radio` når brukeren må velge nøyaktig én verdi.

```tsx
import { Radio, RadioGroup } from "@navikt/ds-react";

export function DeliveryChoice(): JSX.Element {
  return (
    <RadioGroup legend="Delivery" description="Choose one option.">
      <Radio value="standard">Standard</Radio>
      <Radio value="express" description="Delivered faster">Express</Radio>
      <Radio value="pickup">Pickup</Radio>
    </RadioGroup>
  );
}
```

## Dialog

Bruk `Dialog`-komposisjon for modal eller drawer-lignende UI. `position="center"` gir modal, mens `position="right"`, `"left"`, `"bottom"` eller `"fullscreen"` dekker sheet/drawer-mønstre.

**Nyttige byggesteiner**
- `Dialog`
- `DialogTrigger`
- `DialogPopup`
- `DialogHeader`, `DialogTitle`, `DialogDescription`
- `DialogBody`, `DialogFooter`
- `DialogCloseTrigger`

```tsx
import {
  Button,
  Dialog,
  DialogBody,
  DialogCloseTrigger,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogPopup,
  DialogTitle,
  DialogTrigger,
} from "@navikt/ds-react";

export function EditDrawer(): JSX.Element {
  return (
    <Dialog>
      <DialogTrigger>
        <Button>Edit profile</Button>
      </DialogTrigger>
      <DialogPopup position="right" width="medium">
        <DialogHeader>
          <DialogTitle>Edit profile</DialogTitle>
          <DialogDescription>Update your personal information.</DialogDescription>
        </DialogHeader>
        <DialogBody>
          Form content goes here.
        </DialogBody>
        <DialogFooter>
          <DialogCloseTrigger>
            <Button variant="secondary">Close</Button>
          </DialogCloseTrigger>
          <Button>Save</Button>
        </DialogFooter>
      </DialogPopup>
    </Dialog>
  );
}
```

## LinkCard

Bruk `LinkCard` når hele kortet skal fungere som navigasjon.

**Nyttige byggesteiner**
- `LinkCard`
- `LinkCardTitle`
- `LinkCardAnchor`
- `LinkCardDescription`
- `LinkCardFooter`
- `LinkCardIcon`

```tsx
import {
  LinkCard,
  LinkCardAnchor,
  LinkCardDescription,
  LinkCardFooter,
  LinkCardTitle,
  Tag,
} from "@navikt/ds-react";

export function NavigationCard(): JSX.Element {
  return (
    <LinkCard>
      <LinkCardTitle>
        <LinkCardAnchor href="/applications">Applications</LinkCardAnchor>
      </LinkCardTitle>
      <LinkCardDescription>
        See status, missing documents and recent changes.
      </LinkCardDescription>
      <LinkCardFooter>
        <Tag size="small">Updated today</Tag>
      </LinkCardFooter>
    </LinkCard>
  );
}
```

## Table

Bruk `Table` når du trenger tabell med tydelig struktur. `stickyHeader` er nyttig i lange lister.

**Nyttige props**
- `stickyHeader`
- `zebraStripes`
- `size`
- `sort`, `onSortChange`

```tsx
import { Table } from "@navikt/ds-react";

const rows = [
  { name: "Anna", status: "Approved" },
  { name: "Bjørn", status: "Pending" },
];

export function ApplicationsTable(): JSX.Element {
  return (
    <Table stickyHeader zebraStripes>
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell scope="col">Name</Table.HeaderCell>
          <Table.HeaderCell scope="col">Status</Table.HeaderCell>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {rows.map((row) => (
          <Table.Row key={row.name}>
            <Table.HeaderCell scope="row">{row.name}</Table.HeaderCell>
            <Table.DataCell>{row.status}</Table.DataCell>
          </Table.Row>
        ))}
      </Table.Body>
    </Table>
  );
}
```

## Show / Hide

Bruk `Show` og `Hide` for breakpoint-styrt innhold i stedet for egen CSS når mulig.

**Nyttige props**
- `above`
- `below`
- `asChild`

```tsx
import { BodyShort, Hide, Show } from "@navikt/ds-react";

export function ResponsiveCopy(): JSX.Element {
  return (
    <>
      <Show below="md">
        <BodyShort>Compact mobile copy</BodyShort>
      </Show>
      <Hide below="md">
        <BodyShort>Expanded desktop copy with more context</BodyShort>
      </Hide>
    </>
  );
}
```

## LocalAlert

> Alert er deprecated (nov 2025). Bruk `LocalAlert`, `GlobalAlert`, `InlineMessage` eller `InfoCard`.

Bruk `LocalAlert` for statusmeldinger og tydelige tilbakemeldinger.

**Nyttige byggesteiner**
- `LocalAlert`
- `LocalAlert.Header`, `LocalAlert.Title`
- `LocalAlert.Content`

**Nyttige props**
- `status`: `info`, `success`, `warning`, `error`

```tsx
import { LocalAlert } from "@navikt/ds-react";

export function SaveConfirmation(): JSX.Element {
  return (
    <LocalAlert status="success">
      <LocalAlert.Header>
        <LocalAlert.Title>Lagret</LocalAlert.Title>
      </LocalAlert.Header>
      <LocalAlert.Content>Endringene dine er lagret.</LocalAlert.Content>
    </LocalAlert>
  );
}
```

## Heading, BodyShort, BodyLong

Bruk Aksel-typografi konsekvent.

**Nyttige props**
- `Heading`: `level`, `size`
- `BodyShort`: `size`, `weight`
- `BodyLong`: `size`, `weight`

```tsx
import { BodyLong, BodyShort, Heading, VStack } from "@navikt/ds-react";

export function CopyBlock(): JSX.Element {
  return (
    <VStack gap="space-8">
      <Heading size="medium" level="2">Section title</Heading>
      <BodyShort weight="semibold">Short key message</BodyShort>
      <BodyLong>
        Longer explanatory copy that should be easy to scan and read.
      </BodyLong>
    </VStack>
  );
}
```

## Loader og Skeleton

Bruk `Loader` for aktive ventesituasjoner og `Skeleton` for innhold som laster med kjent form.

**Nyttige props**
- `Loader`: `size` (`xsmall`, `small`, `medium`, `large`, `xlarge`, `2xlarge`, `3xlarge`), `title`, `variant`
- `Skeleton`: `variant` (`rectangle`, `circle`, `text`), `width`, `height`

```tsx
import { BodyShort, Loader, Skeleton, VStack } from "@navikt/ds-react";

export function CardLoading(): JSX.Element {
  return (
    <VStack gap="space-8">
      <Skeleton variant="rectangle" width="100%" height="40px" />
      <Skeleton variant="text" width="80%" />
      <Skeleton variant="text" width="60%" />
    </VStack>
  );
}

export function PageLoader(): JSX.Element {
  return (
    <VStack justify="center" align="center" marginBlock="space-40">
      <Loader size="3xlarge" title="Laster" />
      <BodyShort aria-live="polite">Loading data…</BodyShort>
    </VStack>
  );
}
```

## ExpansionCard

Bruk `ExpansionCard` når innhold kan foldes ut for å redusere kognitiv belastning på siden. Støtter `data-color` for semantisk farging.

**Nyttige byggesteiner**
- `ExpansionCard`
- `ExpansionCard.Header`, `ExpansionCard.Title`, `ExpansionCard.Description`
- `ExpansionCard.Content`

```tsx
import { BodyLong, ExpansionCard, HStack } from "@navikt/ds-react";

export function PaymentDetails(): JSX.Element {
  return (
    <ExpansionCard aria-label="Utbetalingsdetaljer" data-color="accent" size="small">
      <ExpansionCard.Header>
        <ExpansionCard.Title as="h4">
          <HStack align="center" wrap={false} justify="space-between">
            Utbetaling mars 2026
          </HStack>
        </ExpansionCard.Title>
      </ExpansionCard.Header>
      <ExpansionCard.Content>
        <BodyLong>Detaljer om beløp og trekk.</BodyLong>
      </ExpansionCard.Content>
    </ExpansionCard>
  );
}
```

## ErrorSummary

Bruk `ErrorSummary` øverst i skjema når du må samle flere valideringsfeil.

```tsx
import { ErrorSummary } from "@navikt/ds-react";

export function FormErrors(): JSX.Element {
  return (
    <ErrorSummary heading="You must fix these errors before continuing:">
      <ErrorSummary.Item href="#name">Name is required</ErrorSummary.Item>
      <ErrorSummary.Item href="#email">Enter a valid email</ErrorSummary.Item>
    </ErrorSummary>
  );
}
```

## Praktiske valg

- `Box` når du trenger ramme, padding eller bakgrunn
- `VStack`/`HStack` når du trenger rytme og rekkefølge
- `HGrid` når layouten faktisk er todelt eller flerkolonne
- `Dialog` når fokus skal flyttes inn i et kontrollert overlay
- `LocalAlert` og `ErrorSummary` for eksplisitt state-håndtering
