# Ready72

Ready72 builds a personal 72-hour emergency bag plan for every person in a household, keeps every bag within what that person can carry, and keeps the bag fresh over time.

This is the Flutter implementation of the approved artboard in `Ready72 – App Design.html`.

## Run it

Requires Flutter 3.44+ (Dart 3.12).

```bash
flutter pub get
flutter run          # phone, Chrome, or macOS
```

One command after the first checkout:

```bash
make start
```

Other commands:

```bash
make test      # unit, widget, guardrail and consent tests
make analyze
make web       # web build in build/web
```

The app starts empty: no prefilled names, ages, weights or needs text. Tap **Try an example family** on Welcome for the demo household. The fixtures live in the test suite and the example-family shortcut, not in a new user's state.

## What is real

- Carry-limit logic (LT72 one-fifth rule, age caps, needs-based reduction), plan optimiser, shared-load distribution, subscription totals, growth projection and expiry reminders are deterministic Dart.
- Guardrails check every generated plan: food, carried litres, critical categories, weight, allergens, diets, age, catalogue identity, shelf life, quantities, needs mapping and no medicine doses.
- Consent gating is real: raw needs text is not parsed or persisted before **Agree and build**. After consent everything is computed on the device.
- The demo family gets **Essential €351 / 29.8 kg** and **Comfort €473 / 33.4 kg**, both with **0 items dropped** and **0 blockers**.
- A household with a pet and no adult no longer crashes; it gets an honest gap.
- **Grab-and-go** emergency screen with 112, official PAGD shelter link, printable/PDF checklist, animated carry-limit bars, the 82-item LT72 list and real store open/copy actions.
- **Offline after first load** on web through a custom service worker; no analytics and no camera permission.
- **Printable A4 checklist** generated in-app and opened in the system print dialog.
- **Local notifications** for expiry checks and annual review, scheduled only after consent.
- **16 Barbora prices** were checked live on 13 Nov 2026. Raw snapshot: `docs/price_snapshots/barbora_2026-11-13.json`; details: `docs/BARBORA_NOTES.md`. Every other price is a catalogue estimate and is marked as such internally.
- English and Lithuanian, 66 functional tests plus a golden screen set, `flutter analyze` clean.

## What is mocked or not built

| Area | Status |
| --- | --- |
| Catalogue prices | 16 Barbora rows verified; the rest are estimates |
| Decathlon prices | 0 verified; automated access returned 403 |
| Ordering / checkout | Mocked; "Place order" confirms a simulated order |
| Delivery dates/statuses | Simulated and persisted locally |
| Subscription payment | Mocked; cancel is local |
| AI needs extraction | Client exists behind `--dart-define`; not called in this build, so the privacy notice is true |
| Backend / SQLite / Prisma | No first-party backend; `shared_preferences` stores a local snapshot |
| Push notifications | Local OS notifications for 60/14-day expiry checks and annual bag review; no remote push |
| Checklist export | Copy to clipboard plus a generated A4 PDF via the system print dialog |
| Shelter data | Official PAGD page and map search; no live nearest-shelter dataset |
| Reddit pipeline | 13 manually paraphrased samples; no OAuth app |
| PWA offline cache | Custom cache-first service worker; the app shell works offline after the first load |
| Release signing | Release keystore configured locally; APK is release-signed |

## Privacy

No server receives health text in this build. There is no first-party analytics, no logging of needs text, and no request before consent. The privacy notice (in-app, EN/LT) explains consent, local storage, export and one-action deletion. Production target is EU-hosted infrastructure.

## Documentation

- `HACKATHON_WIN_PLAN.md` — the audit and the remaining work.
- `docs/ARCHITECTURE.md` — how the pieces fit.
- `docs/RESEARCH.md` — LT72, carry weight, calories, water and growth sources.
- `docs/BARBORA_NOTES.md` — Barbora/Decathlon structure and live checks.
- `docs/price_snapshots/barbora_2026-11-13.json` — raw 18-query, 144-row scrape.
- `docs/GUARDRAILS.md` — every rule, evidence, repair and test evidence.
- `docs/REPORT.md` — verification, metrics and limitations.
- `docs/DEMO_SCRIPT.md` — the 3-minute demo path.

Live demo: https://pijussad.github.io/ready72/
