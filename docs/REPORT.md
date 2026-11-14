# Ready72 final report

## What is built

- **Flutter app** (Android, web, iOS/macOS targets generated) implementing the eight artboard screens plus Tracking, Home and Settings.
- **Design system** matching the artboard: white, #111 text, #6B6B6B secondary, #E4E4E4 hairlines, Inter 300/400/500 bundled locally, 42 px welcome, 38 px headlines, square corners, 52 px black button, 10–11 px tracked labels, 390 px-first layout, 44 px touch targets, 220 ms quiet transitions that respect reduced motion.
- **English and Lithuanian** from ARB files; the Lithuanian pass fixed the broken Pack title, gendered group labels, currency position, declensions and welcome wrap.
- **Domain logic**: carry limits (LT72 one-fifth + age caps + needs reduction), Essential/Comfort optimiser, shared household kit, shared-load distribution, calorie and water targets, subscription totals, growth projection, review/expiry reminders, order splitting.
- **Guardrails** with 16 checkable rules, including carried-litres water and food upper bound.
- **Consent before processing**: the raw needs text is kept in memory on the Needs screen and parsed only after **Agree and build**. No network call is made. The privacy notice now says what the build actually does.
- **Needs parser** with negation ("no pets", "not diabetic", "nėra augintinių"), clause attribution, Lithuanian inflections, pet word boundaries and a clarification for ambiguous pregnancy.
- **Packing flow**: per-person checklist, live weight/limit, expiry and reminder dates, community advice, completion state → Home.
- **Order flow**: store split, total, simulated place-order confirmation, tracking timeline with stable dates/codes.
- **Home and Settings**: per-person weight summary, plan/order/pack entries, resume on relaunch, language, privacy, export/delete, honest prototype note.
- **Reminders**: local OS notifications scheduled after consent for the 60/14-day expiry checks and the annual review; permission is requested only when reminders are enabled.
- **Wow layer**: Grab-and-go emergency screen with 112, shelter screen with official PAGD list and map search, printable/shareable per-person checklist (A4 PDF through the system print dialog), animated carry-limit bars, the full LT72 screen with item-level in-plan/from-home/gap badges, fixed store routing with real “open store”/“copy list” actions, and offline web caching after the first load.
- **Example family** on Welcome, so the live demo does not depend on typing twelve fields.

## Demo family numbers

Jonas 34 / 82 kg, Rūta 32 / 64 kg, Mia 2 / 13 kg, Ona 71 / 62 kg (insulin), dog.

| Tier | Total | Weight | Dropped | Blockers |
| --- | ---: | ---: | ---: | ---: |
| Essential | **€350.79** | 29.84 kg | 0 | 0 |
| Comfort | **€472.66** | 33.44 kg | 0 | 0 |

Per person, Comfort: Jonas 14.9/15 kg, Rūta 11.6/12.8 kg, Mia 0.21/0.39 kg, Ona 6.7/7.4 kg. Calories: 6290/6290/3240/5840.

This is 15–23% above the artboard (€286/€412) because the artboard did not price every durable. It is within the audited band and far below the pre-fix €747/€1,235.

## Fixes since the audit

- Crash for a children-only household with a pet removed; no force-unwraps in the pet pool.
- Water guardrail now checks carried litres and purification, not category presence; 1.5 L bottles for adults/seniors, 0.5 L for children/toddlers.
- Diet checks apply to food/medication only; vegan and vegetarian households have no false allergen blockers.
- Toddlers get toddler meals/snacks, no adult expedition meals, nuts or seeds; calories capped near target.
- Per-person first-aid/hygiene kits replaced by a shared household kit; durable prices corrected to budget estimates; Comfort is a warmth add-on, not a full wardrobe/tent.
- Negation, multi-person attribution, pet substrings and Lithuanian inflections fixed.
- Internal copy ("unverified", "simulated", "mock", "offline parser") removed from consumer screens; one honest note lives in Settings → About.
- Hidden wordmark-back replaced by a 44 px back chevron; sticky CTA; progress hairline; Pack completion and Home.
- Privacy notice corrected; AI is not called; consent version and local delete are enforced; v1 demo seed is migrated away.
- App icons, splash, Android backup rules, web metadata, macOS network entitlement and CI workflow added.

## Price provenance

Prices come from public Lithuanian listings. Sixteen Barbora rows were checked live on 2026-11-13 with a Puppeteer/Chromium pass (18 search queries, 144 rows) and marked `verified: true`. The raw snapshot is `docs/price_snapshots/barbora_2026-11-13.json`. Decathlon returned 403, so 0 Decathlon prices are live. Remaining rows are catalogue estimates. The UI no longer labels individual rows as verified/unverified; the prototype disclaimer lives in Settings.

## AI status

`lib/services/deepseek_client.dart` is implemented with JSON mode, timeouts, retries, a consent gate and replay. It is only called when the consent record contains an `ai` purpose; this build has no UI that grants that purpose, so **the demo never sends health text anywhere**. The deterministic on-device parser is what runs. A production build should proxy the key server-side and add an explicit AI consent.

## What is mocked or not built

| Area | Status |
| --- | --- |
| Catalogue prices | 16 Barbora rows verified; the rest are estimates |
| Decathlon prices | 0 verified |
| Checkout | Mocked; no payment or store order |
| Delivery / tracking | Simulated and persisted locally |
| Subscription | Local state; no charge or replacement schedule |
| AI live call | Not exercised; client exists but is not called |
| Backend / auth / sync | None |
| Push notifications | Local OS notifications for expiry/review; no remote push |
| Reddit pipeline | 13 manual samples |
| Offline web cache | Custom cache-first service worker; works offline after the first load |
| Checklist PDF | A4 PDF generated with bundled Inter, opens the system print dialog |
| Shelter data | Official PAGD page plus map search; no live nearest-shelter dataset |
| Release signing | Release keystore configured locally; APK is release-signed |

## Hosted demo

https://pijussad.github.io/ready72/

## Verification

- `flutter test` → **67 functional tests + 1 golden set, 0 failed**.
- `flutter analyze` → no issues.
- `flutter build web` → succeeded.
- `flutter build apk --release` → succeeded and verified with the release certificate.
- Demo widget test covers Welcome → example family → Family → Needs → Consent → Plan → Order → store sheet → place order → Tracking → Subscribe → Pack.
- Regression tests cover the child+pet crash, vegan/vegetarian blockers, water litres, toddler food, parser negation, multi-person sentences, Lithuanian inflections, demo price band and zero dropped items.

## Known limitations

1. Children-only households cannot physically carry 72 hours of food and water within their limits. Child share is now 15% (still below LT72’s 20% ceiling), and the plan shows a prominent “no adult” warning plus honest gaps instead of overloading a child.
2. A single 72-hour bag is tight for large Comfort kits; Comfort is intentionally a warmth add-on and tells the user to bring sleeping gear from home.
4. The release keystore and `android/key.properties` are local and not committed; back them up before store submission.
5. Notifications are local OS notifications; there is no remote push server.
5. There is no hosted demo URL or release-signing key in the repo.
6. The parser is deterministic and intentionally conservative; unusual phrasing can still need a clarification.
