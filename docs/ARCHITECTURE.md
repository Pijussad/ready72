# Architecture

```text
Household (names, ages, weights)
        │
        ▼
CarryLimits ──────────────► per-person kg ceiling
        │
Needs text ── consent ───► NeedsParser (negation, per-person)
        │
        ▼
PlanOptimizer
  ├─ personal kit (backpack, layers, medicine, documents)
  ├─ shared household kit (first aid, hygiene)
  ├─ food/water pool (age-aware, calorie/litre targets)
  ├─ pets (only if a household pet was parsed)
  └─ Comfort add-on (warmth; only uses spare capacity)
        │
        ▼
PlanGuardrails (16 rules) ──► PlanResult (bags, grams, euros, gaps)
        │
        ├─ OrderSplitter ──► store groups, shipments, tracking
        ├─ PackProgress ──► checklists, expiry
        └─ SubscriptionQuote / growth projection
```

## Layers

- `lib/models` — immutable data: household, needs, products, plans, orders, pack.
- `lib/domain` — deterministic logic: carry limits, parser, optimiser, guardrails, growth.
- `lib/data` — catalogue, LT72 transcription, community advice.
- `lib/services` — app state, storage, consent, optional AI client.
- `lib/screens` — one file per screen; no domain logic in widgets.
- `lib/widgets` — AppScreen, sticky footer, buttons, check lines, privacy sheet.
- `lib/l10n` — ARB source and generated localisations.
- `lib/theme` — colours, type scale, route transition.

## Data flow

`AppState` is a `ChangeNotifier` above `MaterialApp`. Screens read it through `AppScope`. The optimiser builds Essential and Comfort once per change; the selected tier drives Order, Pack and Home. Storage writes a local JSON snapshot after consent. Raw needs text is not parsed or persisted before consent.

## Extension points

- Replace `Catalogue` prices with a retailer feed; keep `verified` provenance.
- Replace `OrderSplitter` mock with a checkout adapter.
- Add a serverless proxy for the DeepSeek key before enabling live AI.
- Add local notifications for the reminder dates already computed.
