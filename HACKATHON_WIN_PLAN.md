# Ready72: what to change to win the hackathon

> **Implementation status (13 Nov 2026):** the P0 engine, parser, privacy, copy, Lithuanian, flow, Home/Settings, Pack completion, order confirmation, grab-and-go emergency screen, printable/PDF checklist, shelter screen with official list + map search, item-level LT72 in-plan/from-home/gap badges, fixed store routing with real store actions, offline cache, fit animation, local OS notifications, no-adult capacity warning, tests, icons/splash, Android/web metadata, CI and docs are implemented. The barcode scanner was removed by request (no camera permission, no ML Kit). Demo output is now **Essential €350.79 / Comfort €472.66**, both 0 dropped and 0 blockers, with 66 functional tests passing. Hosted web demo is live at https://pijussad.github.io/ready72/. Still manual: native-speaker sign-off and the live pitch rehearsal (script and backup video prepared). The release keystore is configured locally (not committed). See `docs/REPORT.md` for the verification.


Audit date: 13 Nov 2026. Scope: every file in `lib/`, `test/`, `docs/`, `android/`, `ios/`, `web/`, `macos/`, the approved artboard `Ready72 – App Design.html`, the current APK, and real optimiser output for the demo family plus 20+ edge-case households.

Original audit finding: the engine, guardrails and tests were good, but the output, copy and end of the flow were not demo-ready. The app showed a €1,235 plan that dropped 56 items, rows labelled "unverified" and "simulated", broken Lithuanian, and a Pack screen with no ending. The artboard promised €412, a compact kit and a calm, finished product.

Baseline at audit time (before the fixes below): `flutter test` 54/54 pass, `flutter analyze` clean, release APK built (debug-signed then; now release-signed). Current state: 66 functional tests + 1 golden set pass; see the status note at the top.

---

## 0. How to read this file

- **P0** blocks winning: a judge would see it in a 3-minute demo, or it can crash or mislead.
- **P1** costs points: visible on a second look, in Q&A, or in the repo.
- **P2** is polish: do it if time remains.
- Every item has an ID (for example `ENG-03`), the location, what is wrong, the fix, and how we know it is done ("Done when").
- Effort: **S** < 1 h, **M** 1–3 h, **L** 3–8 h.
- Section 14 is the order of work. Section 15 is the demo script to rehearse. Section 16 is judge Q&A prep.

### Judging criteria (assumed, confirm with the organisers)

The brief is not in the repo. Most civic/tech hackathons score some mix of:

| Criterion | What judges look for | Where we stand now |
| --- | --- | --- |
| Problem & impact | Real problem, clear user, measurable change | Good story (LT72, carry weight), not quantified on screen |
| Innovation | Something others don't do | Per-person carry limit + guardrails is unique, but invisible in the UI |
| Execution / tech | Works live, no crashes, real data | Works, but plan output looks wrong; crash for child + pet |
| Design / UX | Polished, coherent, finished | Strong design system; flow ends abruptly; internal copy leaks |
| Feasibility / business | Who pays, how it scales | Subscription exists; €1,235 price kills the business story |
| Presentation | Clear 3-minute demo | Script exists; numbers in it fight the artboard |

**Action:** get the real judging rubric and the exact demo time limit, then re-weight Section 14.

---

## 1. The 12 changes that matter most

If only one day is left, do these, in this order.

1. **Make the plan price and contents believable** (ENG-01, ENG-02, ENG-06). Target Essential ≈ €280–350 and Comfort ≈ €400–550 for the demo family, 0 dropped items, no adult meals for a toddler.
2. **Fix the crash**: household with only children and a pet (ENG-04).
3. **Remove all internal copy from consumer screens**: "unverified", "catalogue snapshot", "simulated", "mocked", "offline parser", "DeepSeek" (UX-01).
4. **Add "Try demo household" on Welcome**, so the live demo does not depend on typing 12 fields (UX-02).
5. **Give the flow an ending**: Pack completion state → "Your bags are ready" home screen with resume, settings and restart (UX-03, UX-04).
6. **Show the core idea on the Plan screen**: per-person weight bars ("Jonas 13.2 / 15 kg"), coverage chips and a short "why this limit" line (UX-10).
7. **Fix Lithuanian**: Welcome headline wraps to 4 lines, "Krepšys / Ona", "Ona · Senjoras", hard-coded "€" (L10N-01..05).
8. **Fix the needs parser on negation and multiple people**: "No pets" must not buy dog food; "Jonas has diabetes and Rūta is pregnant" must not make both pregnant (AI-01, AI-02).
9. **Fix water**: the water guardrail passes with zero litres; children can never carry water (ENG-03).
10. **Make the privacy story true**: the notice says no server receives health text, which is false when DeepSeek is on; health text is parsed before consent (PRIV-01, PRIV-02).
11. **Ship a hosted web demo + signed APK + git repo with CI** (OPS-01..04). Judges click links.
12. **Rewrite the demo script and fix stale docs** (DOC-01, Section 15).

---

## 2. Plan engine and output (`lib/domain`, `lib/data`)

### Demo family, actual output today

Household: Jonas 34 / 75 kg, Rūta 32 / 64 kg, Mia 2 / 13 kg, Ona 71 / 62 kg (insulin), dog.

| Tier | App | Artboard | Ratio |
| --- | ---: | ---: | ---: |
| Essential | **€747.14**, 30.13 kg, 68 lines | **€286** | 2.6× |
| Comfort | **€1,234.88**, 35.51 kg, 94 lines, **56 dropped** | **€412** | 3.0× |

Where the money goes:

- Essential: durables are **€568.75 (76%)**. Each adult/senior gets their own €54.99 backpack, €36.99 first-aid kit, €24.99 headlamp, €12.99 med pouch, €14.99 hygiene kit, €12.99 document pouch.
- Comfort: durables are **€1,040.54 (84%)**; clothing alone is **€605.80 (49%)**.
- The largest prices are **unverified Decathlon fixtures** (tent €119.99, spare shoes €69.99, sleeping bag €59.99, backpack €54.99, rain jacket €49.99).
- Weight: water is 11 kg of 30–35 kg. Comfort fills **99.7%** of the family's total capacity, leaving no room for the family's own documents, phone or keys.

### P0

**ENG-01 — Price is 2.6–3× the artboard.** `lib/domain/plan_optimizer.dart` (personal kit `:211-322`), `lib/data/catalogue.dart`. **M–L**
- Fix:
  1. Introduce a **shared household kit**: one first-aid kit, one radio, one power bank, one water filter, one hygiene kit per 2 people, one document pouch per family. Assign shared items to the strongest carrier.
  2. Per person keep only: backpack, emergency blanket, headlamp (adults), personal medicine, clothing layer.
  3. Use realistic budget prices for durables (backpack ~€25–30, first aid ~€15–20, headlamp ~€8–12, document pouch ~€5) and verify them (CAT-02).
  4. Make **Comfort = Essential + warmth/sleep add-on** (fleece, hat/gloves, sleeping bag for adults), as the artboard subtitle says: "72 hours, extra warmth". It is not a full wardrobe plus camping gear.
- Done when: demo family Essential €250–350, Comfort €380–550, Comfort − Essential ≈ €100–200; a test asserts these ranges.

**ENG-02 — Comfort drops 56 items, including the tent, stove, radio, power bank and sleeping bags, while small luxury items fit.** `plan_optimizer.dart:692-737` (`_distribute` is greedy by unit). **M**
- Fix: pack by priority tier. If a high-priority item does not fit, do not let lower-priority items take its space. Cap target fill at ~85–90% so there is headroom for documents, phone and keys. Remove items from the Comfort pool that cannot realistically fit (tent for a family whose total capacity is 35 kg).
- Done when: demo Comfort has **0 dropped**; no bag above 90% fill; a test asserts `dropped.isEmpty` for the demo family in both tiers.

**ENG-03 — Water logic is unsafe.** **M**
- `lib/domain/guardrails.dart:91-99`: `water-mandatory` passes when the plan has only purification tablets (they are `LCategory.water`). A one-senior plan has **0 litres** and passes.
- `plan_optimizer.dart:759-760`: a 0.5 kg bottle is rejected for every child, so children-only households carry no water; seniors cannot carry 1.5 L and get no fallback to 0.5 L.
- Fix: guardrail checks **carried litres per person** (≥ 1 L/day × 3 days for adults, scaled for children), not category presence. `_waterPool` falls back 1.5 L → 0.5 L; children ≥ 6 may carry 0.5 L within their limit. Allocate water and food before optional kit.
- Done when: tests for a one-senior, children-only and one-adult-plus-baby household all have > 0 L water or an explicit, user-visible gap.

**ENG-04 — Crash: children-only or baby-only household with a pet.** `plan_optimizer.dart:519` `_strongestAdult(request)!`. The Consent screen also stays stuck on "Building your bags…" because `app_state.dart:176` does not catch it. **S**
- Fix: no force-unwrap. Fall back to the oldest child who can carry the item, or record a `pets` gap. Wrap plan building in try/catch and show an error state with a Back button.
- Done when: regression tests for `[child 8 + dog]`, `[baby + dog]`, `[senior + dog]` pass without exceptions.

**ENG-05 — Vegan/vegetarian households always fail the allergen blocker.** `lib/models/product.dart:103-122` applies diet checks to backpacks, tents and first-aid kits; `guardrails.dart:119-137` reports ~30 false blockers, each twice (beneficiary + carrier when they are the same person). **S**
- Fix: apply diet and allergen checks only to food, formula and medicine categories; dedupe people.
- Done when: `vegan` and `vegetarian` eval families have `blockersFired == 0`.

**ENG-06 — Toddlers and babies get adult expedition meals and ~2× calories.** `plan_optimizer.dart:386-428`, `catalogue.dart:24` (`meal-chicken` has `ageMin: 0`). Mia (2) gets 3,910/3,000 kcal including chicken-rice meals, seed mix and nut mix (choking hazard under 4). A newborn gets 5,960/3,000 kcal. Baby food is added twice (personal kit + food pool: 12 jars). **S–M**
- Fix: age ≤ 3 gets formula/baby food/toddler-safe snacks only. Set `ageMin: 4` on expedition meals; no whole nuts or seeds under 4. Stop at 100–110% of target calories. Add only one baby-food source.
- Done when: Mia's bag has no adult meals, nuts or seeds; a guardrail `food-upper-bound` (≤ 125%) passes for every eval family.

### P1

**ENG-07 — Food is chosen by kcal/kg, not cost or realism.** `plan_optimizer.dart:406-428`. Picks meal-chicken ×4, seeds ×7, peanut butter, nut mix. Oats (€0.78/1000 kcal) and noodles (€0.79) are never chosen. Rank by a blend of €/kcal, kg/kcal and variety; cap each product at 2–3 units per person; include at least one ready-to-eat item per person per day. **M**

**ENG-08 — Wrong items for wrong people** (`plan_optimizer.dart:273-322`, `:573-604`). **M**
- Sanitary pads go to every adult, including Jonas; never to girls 12–14. Make it an opt-in need ("periods") or household-level.
- Toddler gets no rain or warm layer and no sleeping solution; 4–5-year-olds get no sleeping bag or mat.
- Coffee/tea only for the first adult.
- Dried fruit is tagged `lowSugar` and goes to diabetic Ona. Fix the tag; exclude it for `lowSugar`.
- Spare shoes, compass and sewing kit are adult-only; seniors get none.

**ENG-09 — LT72 list is transcribed but never used.** `lib/data/lt72.dart:40` (82 rows) has zero references. `criticalCategories` (`:132-142`) misses tools, communication, children and pets. **M**
- Fix: map each critical LT72 row to a catalogue product or an explicit "you already own this" item (ID copies, cash, keys, phone charger). Add missing catalogue rows: cash envelope, ID copies, spare keys, tourniquet, plasters, antiseptic, gloves, soap/wipes, duct tape, paracord, candle, heat packs, pet water.
- Done when: a test asserts every LT72 "critical" row is covered or appears in the "bring from home" list. **Show this on screen** as "LT72 coverage 31/31" (UX-10). It is one of the strongest proofs we can show.

**ENG-10 — Coverage is satisfied by proxies.** Backpacks are categorised `clothing` (`catalogue.dart:998, 1024, 1042`), so a plan with zero clothes passes "clothing"; a document pouch passes "documents". Recategorise backpacks as `bags` and check coverage on real content. **S**

**ENG-11 — Non-stable sorting.** `plan_optimizer.dart:124-129, 632-640, 698-703`, `lib/models/order.dart:60-61`. Dart `List.sort` is not guaranteed stable. Add `product.id`/`carrierId` tie-breakers. **S**

**ENG-12 — Decathlon delivery is 5 days.** `lib/models/product.dart:18-30`. For a "72-hour readiness" story, show "arrives in 5 days" honestly or prefer click-and-collect/next-day. **S**

**ENG-13 — Diapers/formula for a child aged 4+ create an unrepairable blocker** (`catalogue.dart` ageMax 3, `guardrails.dart:280-288`). Add larger sizes or downgrade to a warning: "Not in catalogue — bring your own". **S**

**ENG-14 — Allergen data is thin.** Many foods have empty `allergens` (chicken meal, canned meat, seeds, baby food). For a health product, declare conservatively and add a contract test that every food row has an explicit allergen list (empty only if verified). **M**

### P2

- **ENG-15** `formatWeight` shows 14.98 kg as "15" (`lib/utils/format.dart:22-26`), so a bag reads "15 / 15 kg", which looks like "at the limit". Show one decimal and round **down** for loads.
- **ENG-16** Duplicate lines in one bag (Rūta: three `water-15` lines, `med-pouch ×2`). Merge by carrier+product for display; show "for Jonas, Ona".
- **ENG-17** The dropped list repeats entries ("Toilet paper ×1" three times). Group and count.
- **ENG-18** `price-range` guardrail accepts €25–€2,500 per person. Tighten.
- **ENG-19** `quantity-sane` allows 12 jars. Cap per product per 72 h.
- **ENG-20** Growth clothing size off-by-one (`growth.dart:106-109`, `<` vs `<=`); month overflow on Jan 31 (`growth.dart:41`).
- **ENG-21** `PackEntry.copyWith` cannot clear `expiry`/`barcode`/`packedAt` (`lib/models/pack.dart:21-36`). Unchecking keeps `packedAt`.
- **ENG-22** Empty household throws in `PlanOptimizer.build` (`:497`). Return an empty plan.
- **ENG-23** Delivery statuses are assigned by sorted index (`order.dart:91-100`). Adding a store changes statuses.
- **ENG-24** Dead code: `Person.canCarrySharedLoad`, `isDependent`, `AppConfig.medicationBufferDays` (documented as "14-day buffer", never used), `Lt72Item.groups/conditional`, `StorageService.clear`, `DeepSeekClient.configured`, `formatMoneyDecimal`, `formatDayMonth`. Wire or delete.
- **ENG-25** Subscription: child €5 > adult €4 with no explanation. Either explain it on screen ("includes new backpack as they grow") or adjust.

---

## 3. Needs understanding (parser + AI) (`lib/domain/needs_parser.dart`, `lib/services/deepseek_client.dart`)

### P0

**AI-01 — Negation is ignored.** Verified outputs:

| Input | Parsed today |
| --- | --- |
| "No allergies, not diabetic." | Jonas: diabetes, low sugar, cooling |
| "We do not have a dog." / "No pets." / "Nėra augintinių." | pet → buys dog food, leash, bowl |
| "Rūta is not pregnant." | Rūta pregnant → carry limit lowered |
| "Ona is not allergic to nuts." | nut allergy |

Fix: a negation window (`no, not, without, none, free of, don't, doesn't` / `ne, nėra, neturi, neserga, be`) within ~3 tokens of the keyword; clause splitting. **M**

**AI-02 — One sentence assigns every condition to every named person.** "Jonas has diabetes and Rūta is pregnant" → both diabetic and pregnant. Split clauses on `and, but, ,, ;, ir, bet, o` and attribute each to the nearest name. **M**

**AI-03 — Substring matching invents pets.** `needs_parser.dart:42-54, 273-288`: "competition", "carpet", "vacation", "petroleum", "dogmatic" → pet/cat/dog. Use word boundaries (`\bdog\b`), drop the bare `pet` keyword or require "have a pet/augintinis". **S**

### P1

**AI-04 — Ambiguous needs are applied to a guess.** "I am pregnant." → Jonas (male adult) pregnant. The clarification is static text and cannot be answered (`needs_screen.dart:38-45`). Fix: hold ambiguous needs in a pending list and show **name chips** ("Who is this for? [Jonas] [Rūta] [Ona]"); block Continue until resolved or dismissed. **M**

**AI-05 — Lithuanian inflections missed.** "aukštą kraujospūdį", "diabetą", "astmos", "epilepsijos", "nėščios", "veganai". Normalise diacritics and strip common case endings (`-as -ą -o -os -ų -ui -iai -ė -ės`) before matching. Add an LT test table with 30+ phrases. **M**

**AI-06 — AI result replaces the deterministic result.** `app_state.dart:165-170` sets `_needs = aiNeeds`; AI output does not derive `lowSugar`, `cooling` and `glutenFree`, so a partial AI answer could give chocolate to a diabetic. Always run `NeedsParser` first, merge AI additions from an allowlist, then re-derive flags. **S**

**AI-07 — Prompt injection and unbounded input.** `deepseek_client.dart:53-65, 100-129`. Wrap user text in delimiters, state in the system prompt that it is untrusted data, cap input at ~1,000 characters, cap response size, allowlist `clarifying_questions[].detail`. **S**

**AI-08 — Up to ~80 s silent wait.** 3 retries × 25 s, including 400/401/403 (`deepseek_client.dart:69-98`). Retry only timeouts/5xx/429, total budget ≤ 12 s, then fall back with a visible note. Show a spinner and Cancel on Consent. **S**

**AI-09 — Show what was understood.** The user types health info and gets no confirmation. After parsing, show a quiet per-person summary: "Ona · insulin, keep cool · low sugar". `needsParsed` already exists in ARB, unused. This is a **demo wow moment**: type a sentence and watch chips appear under each name. **M**

**AI-10 — Decide the AI story for the pitch.** Options:
1. Ship with a server-side proxy and an EU-hosted model (see PRIV-03), demo it live, keep the offline parser as fallback.
2. Present it as "on-device understanding, no health data leaves your phone" and drop DeepSeek from the build.

Option 2 is the stronger privacy story and removes demo risk. **Pick one before the pitch.** Do not show "Offline parser…" text either way (UX-01).

---

## 4. Catalogue, prices and stores (`lib/data/catalogue.dart`, `lib/models/product.dart`)

**CAT-01 (P0) — Stores do not match the artboard.** Artboard: Maxima 14 / €158, Rimi 11 / €104, Eurovaistinė 6 / €86, Decathlon 3 / €64. App: Barbora 71 lines, Decathlon 31 / €760.69, Rimi **1 line / €1.99**. Show "Barbora (Maxima)" as the label, move groceries/hygiene to Rimi so the split looks real, and keep Decathlon to 3–6 durable items. **S–M**

**CAT-02 (P1) — Verify the prices that drive the total.** Only 16 Barbora rows are verified; every big-ticket item is a fixture. Re-run the scraper for the 15 most expensive rows (Decathlon via a browser session or manual check, Eurovaistinė first-aid kits, Rimi hygiene). Record source, date and URL. **M**

**CAT-03 (P1) — All Decathlon links point to the same backpack category page** (`catalogue.dart:459, 497, 783, …, 1486`). A judge who taps "tent" lands on backpacks. Use real product URLs or hide the link. **S**

**CAT-04 (P1) — Barcodes are all synthetic** (`4770000000…`, 88/88), including verified products. Scanning any real product in a shop returns "not found". Put the real EANs from `docs/price_snapshots/barbora_2026-11-13.json` on the 16 verified rows, and **bring 3 real products to the demo** whose barcodes match. If a code is unknown, offer search by name. **S–M**

**CAT-05 (P2) — Lithuanian product names have errors**: "Vistiena su ryziais" → "ryžiais" (`catalogue.dart:14`); "Kelioninė higienos priemonių rinkinys" → "Kelioninis" (`:693`). Run a full LT name pass.

**CAT-06 (P2)** — Add "bring from home" items (ID copies, cash, keys, chargers, prescriptions) at €0, so the plan matches LT72 without buying them.

---

## 5. UI and UX, screen by screen (`lib/screens`, `lib/widgets`)

### Cross-cutting P0

**UX-01 — Internal/prototype copy on consumer screens.** **S**
- `needs_screen.dart:88` "Offline parser…" / "DeepSeek is configured…"
- `plan_screen.dart:142`, `order_screen.dart:152` "Catalogue snapshot · some prices are unverified."
- `order_screen.dart:67-72` "29 catalogue prices are unverified."
- `order_screen.dart:236-239` "Verified price / Unverified price" on every row
- `order_screen.dart:75`, `tracking_screen.dart:34, 46` "simulated for this prototype"
- `subscribe_screen.dart:106` "Payment is mocked. No charge is made."
- Fix: remove all of these. Add **one** "About this prototype" entry in Settings (UX-04) that states it honestly. Keep price provenance in the docs, not in the UI.

**UX-02 — No demo shortcut.** The app starts empty (as requested), so the live demo needs 12 typed fields plus a sentence. Add a quiet secondary link on Welcome: **"Try with an example family"**. It fills Jonas/Rūta/Mia/Ona + needs text, and the user can still edit everything. Empty start stays the default. **S**

**UX-03 — No resume; every relaunch starts at Welcome.** `app.dart:50` hardcodes `initialRoute: '/welcome'`, though state is restored. Persist the current step; on relaunch with a plan, open **Home** (UX-04). **M**

**UX-04 — No home, no settings, no ending.** Pack is a dead end; privacy, export, delete and language are reachable only from the Consent screen's privacy sheet. Add:
- **Home / "Your bags"** after Pack: per-person cards (packed x/y, kg/limit), next review date, next expiry, subscription status, "Edit family", "Restart".
- A **settings entry** (top-right on every screen after consent): language, privacy notice, export, delete all, about this prototype.
- **M–L**. This turns a linear demo into a product.

**UX-05 — Header.** The wordmark is "Ready72", not **READY72** as in the artboard, and it is secretly the back button (≈34 px tap target, no affordance) (`common.dart:91-106`). Always render READY72; add a separate 44×44 back chevron on pushed screens. **S**

**UX-06 — Primary CTA scrolls away** on long screens (Plan, Order) (`common.dart:36-63`). Pin the 52 px button to the bottom safe area, as the artboard shows. **S**

**UX-07 — No progress indicator.** Only "01"…"07". Add a 1 px progress hairline under the header filling 1/7 … 7/7. Fix duplicate "05" on Tracking (`tracking_screen.dart:22`). **S**

### Welcome

- **W-1 (P0)** The LT headline wraps to 4 lines: "Būkite pasiruošę." measures 343.6 px in a 304 px column at 46 px. The 46 px size is also outside the 38–42 px system (`design.dart:28-35`). Use 42 px and shorter LT copy ("Būkite pasiruošę. / Neškite mažiau." at 40 px fits, or "Pasiruoškite. / Neškite mažiau.").
- **W-2 (P1)** Add a 3-line "how it works" strip under the subtitle: "1 Tell us who · 2 We fit each bag to what they can carry · 3 Order and keep it fresh".
- **W-3 (P1)** Language toggle tap target ≈38 px (`common.dart:500-501`). Make it 44 px.
- **W-4 (P2)** Use the empty space for the brand: a single fine-line illustration of four bags in size order (largest to smallest) instantly explains "carry less".

### 01 Family

- **F-1 (P1)** Errors are plain text under the list, not tied to fields, not announced (`family_screen.dart:62-68`). Mark the field (underline in red/black-bold), add `Semantics(liveRegion: true)`, focus the first invalid field.
- **F-2 (P1)** Remove is instant with no undo; after consent it silently rebuilds plans (`:192-202`). Add an undo snackbar.
- **F-3 (P1)** Column headers have fixed widths: "AMŽIUS" needs 46.4 px in a 42 px column; "WEIGHT KG" wraps at text scale > 1.0. Use flexible widths shared by header and rows; replace fixed 44 px rows with min-height.
- **F-4 (P1)** No visible "Add person". Show a "+ Add person" quiet link instead of relying on the magic blank row.
- **F-5 (P2)** Autofocus the first name, `TextCapitalization.words`, tap outside to dismiss the keyboard, keep the CTA above the keyboard.
- **F-6 (P2)** Add a per-row role hint after age is typed: "Adult · up to 15 kg", "Toddler · carries 0.4 kg". This shows the core idea on the first screen.
- **F-7 (P2)** Disposing controllers inside `setState` (`:196-198`) can race a focused field; dispose after the frame.

### 02 Needs

- **N-1 (P0)** Hint chips look like buttons but do nothing (`needs_screen.dart:94-110`). Make them insert a template ("Mia is allergic to…") or style them as plain captions.
- **N-2 (P0)** The clarification question cannot be answered. Add name chips (AI-04).
- **N-3 (P1)** Live parsed summary per person (AI-09).
- **N-4 (P1)** Parsing on every keystroke rebuilds the whole `MaterialApp` (`app.dart:35-37` + `needs_screen.dart:74-77`). Debounce 300 ms; move `ListenableBuilder` below `MaterialApp`.
- **N-5 (P1)** Health text is processed before consent (PRIV-01). Either move the consent explanation before this screen or parse only after Agree.
- **N-6 (P2)** `AppTextArea` has no semantic label or max length (`common.dart:311-340`).

### 03 Consent

- **C-1 (P0)** "Your details stay on this device until you agree" (`app_en.arb:87`) implies they leave afterwards. Replace with what is true (see PRIV-02).
- **C-2 (P1)** Busy state is only text; add a spinner, a 12 s budget and Cancel (AI-08).
- **C-3 (P1)** Checkboxes have no checked semantics (`common.dart:398-422`).
- **C-4 (P1)** Disabled CTA contrast 4.19:1 at 11 px (`common.dart:158, 173-175`) fails AA. Use a darker label or an outline style.
- **C-5 (P1)** Returning after consent shows "Agree and send" again and re-records consent. Show "Consent given on 13 Nov · Continue" instead.
- **C-6 (P1)** Unchecking the required box after consent does not withdraw consent. Either disable editing or treat it as withdrawal with a confirmation.
- **C-7 (P2)** The privacy notice lacks controller identity, contact, retention period and consent version.

### 04 Plan

- **P-1 (P0)** Price/contents (ENG-01/02). Default tier is Comfort (`app_state.dart:33`), so the judge first sees €1,234.88 and "56 items were dropped".
- **P-2 (P0)** "Some essentials did not fit within the carry limits" appears for any blocker, even when the cause is food or coverage (`plan_screen.dart:120-126`). Show the actual reason.
- **P-3 (P1)** **Show the bags.** Per person: name, a thin weight bar "13.2 / 15 kg", item count; tap to see contents. This is the product's core idea and it is currently invisible on the decision screen.
- **P-4 (P1)** Coverage strip: "Water · Food · First aid · Light · Warmth · Documents · Medicine ✓", "LT72 critical items 31/31".
- **P-5 (P1)** Prices: show whole euros on the cards (€412), as the artboard does. Show cents only in the order detail.
- **P-6 (P1)** "ORDER · €412" opens a review screen, not an order. Rename to "Review order · €412", or add a confirm step on Order (O-3).
- **P-7 (P2)** "No plan yet. Go back and try again." has no back button (`:73-74`). Add a button.
- **P-8 (P2)** Unguarded `comfortPlan!` / `essentialPlan!` (`:80, :89`).

### 05 Order

- **O-1 (P0)** Stores, counts and amounts (CAT-01).
- **O-2 (P0)** Internal copy (UX-01).
- **O-3 (P1)** No order placement step. Add **"Place order · €412"** → a short confirmation ("Order placed. 4 deliveries, first on Tue 17 Nov") → then tracking. Make payment look real (a Stripe-test-style sheet) without charging.
- **O-4 (P1)** No total on the screen. Add "Total €412" above the CTA.
- **O-5 (P1)** The store sheet renders 71 rows in a `SingleChildScrollView` (`order_screen.dart:108-161`). Use `DraggableScrollableSheet` + `ListView.builder`; group by person.
- **O-6 (P2)** The `north_east` icon suggests an external link but opens internal tracking (`:206-213`). Use a chevron.
- **O-7 (P2)** Every delivery row opens the same full tracking list (`:63-64`). Open that shipment.

### Tracking

- **T-1 (P1)** Codes and dates regenerate on every relaunch (`models/order.dart:54`; order not persisted). Persist the order and shipments.
- **T-2 (P1)** "EUROVAISTINE" without diacritic in codes (`tracking_screen.dart:67-68`). Use an ASCII store code (EVA) or keep the name separate.
- **T-3 (P2)** Add ETA per shipment and a "your family is ready by Fri 20 Nov" line. That is the outcome the user cares about.
- **T-4 (P2)** "Back to order" uses `maybePop`, which does nothing on a cold start.

### 06 Subscribe

- **S-1 (P0)** "Cancel anytime" with no cancel action (`subscribe_screen.dart:104`; `AppState` has no `cancelSubscription`). Add Manage/Cancel.
- **S-2 (P1)** Overflow at 1.5× text: fixed `height: 60` rows (`:44-74`). Use min-height; ellipsis on subtitles.
- **S-3 (P1)** "NOT NOW" still shows when subscribed (`:108-111`).
- **S-4 (P1)** Say what the subscription does, with dates: "Next food swap: May 2027 · Mia's next backpack: Sep 2027". The growth engine already computes this; use it.
- **S-5 (P2)** LT currency format: `formatMoney` gives "412 €" but ARB hard-codes "€5 / mėn." (`app_lt.arb:159, 166, 174`).

### 07 Pack

- **K-1 (P0)** LT title "Krepšys / Ona" (L10N-02).
- **K-2 (P0)** No completion state. When all items are checked: check animation, haptic, "Ona's bag is ready", next person / Home.
- **K-3 (P1)** Rows overflow when an expiry date is set: 9 px at 1.3×, 37 px at 2.0× (`pack_screen.dart:224, 239`). Use min-height.
- **K-4 (P1)** Progress line not uppercase; the artboard reads "5 OF 12 · 4.1 / 9 KG" (`:89-97`). Count units, not lines.
- **K-5 (P1)** Empty manual barcode silently does nothing (`:452-454`, `:164`). Validate; rename the CTA to "Find item".
- **K-6 (P1)** Scanner: no permission-denied state, no `errorBuilder`, no frame, no torch, no success overlay; accepts any QR (`barcode_scanner_screen.dart:25-37`). Close button unlabeled (`:43-60`). No `AnnotatedRegion` for the status bar on black.
- **K-7 (P2)** Stock Material date picker breaks the square design (`:360-368`). Theme it.
- **K-8 (P2)** Double spacer 20+14 px (`:112-114`).
- **K-9 (P2)** `packPersonId` not persisted; the selected bag resets on relaunch.
- **K-10 (P2)** "Open an item's menu" hint, but the affordance is a `⋯` icon. Say "Tap ⋯".

### App-wide polish (P2 unless noted)

- **UX-08 (P1)** App icon: two cropped "72" glyphs on black; favicon unreadable; no Android adaptive/round icon; blank iOS launch image; plain white Android splash. Make one centred mark, adaptive icon and a branded splash (`flutter_launcher_icons`, `flutter_native_splash`).
- **UX-09 (P1)** Android dark mode: `values-night` launch theme is black, so the app flashes black → white. Force light (`ThemeMode.light` + light night styles) or support dark mode properly.
- **UX-10 (P1)** Signature visual: the **carry-limit bar** used consistently on Family (hint), Plan (per-person), Pack (live). One visual = the whole idea.
- **UX-11** No haptics anywhere; `NoSplash` removes pressed feedback on most `InkWell`s (`design.dart:119-121`). Add a subtle pressed state and haptics on check/complete.
- **UX-12** `QuietLink` never uppercases ("Privacy notice", "Not now"), unlike the artboard.
- **UX-13** URL launch failures are silent (`plan_screen.dart:146-152`, `order_screen.dart:245-251`, `pack_screen.dart:133-141`).
- **UX-14** Unused ARB keys show unfinished features: `addPerson`, `needsParsed`, `criticalCovered`, `reducedCapacity`, `scanUnavailable`, `deleted`, `validationTitle`, `genericError`, `menu`, `viewProduct`, `privacyLinkHint`. Wire or delete.
- **UX-15** No delete confirmation feedback (`deleted` unused, `privacy_sheet.dart:110-112`). Export copies health data to the clipboard with no warning (`:46-58`).
- **UX-16** Web: no URL routing/restoration/unknown route (`app.dart:50-55`). Refresh on `/#/pack` lands on Welcome. Use `go_router` with guards.

---

## 6. Lithuanian language (`lib/l10n/app_lt.arb`)

All 175 keys exist in both languages. Quality issues a Lithuanian judge will see immediately:

| ID | Key / location | Now | Fix |
| --- | --- | --- | --- |
| L10N-01 (P0) | `welcomeTitle1/2` | 4-line wrap | Size 40–42 px, shorter copy, test at 360 px |
| L10N-02 (P0) | `packTitleName` + `pack_screen.dart:75-78` | "Krepšys / Ona" | "Krepšys · Ona" (no declension needed) |
| L10N-03 (P0) | `adult` / `senior` | "Suaugęs" / "Senjoras" under Rūta and Ona | Neutral: "Suaugusio amžiaus" / "Senjoro amžiaus" |
| L10N-04 (P1) | `forPerson`, `removeNamed`, `barcodeMatched` | "Skirta Ona", "Pašalinti Ona", "Rasta {item}" | "Skirta: {name}", "Pašalinti: {name}", "Atpažinta: {item}" |
| L10N-05 (P1) | `perMonth`, `totalPerMonth`, `subscribeCta` | "€5 / mėn." | Use `formatMoney` → "5 € / mėn." |
| L10N-06 (P1) | `formatWeight` | "4.1 kg" | "4,1 kg" in LT |
| L10N-07 (P1) | `needsPlaceholder` | "Močiutei Onai yra diabetas…" | "Močiutė Ona serga cukriniu diabetu ir vartoja insuliną." |
| L10N-08 (P1) | `consentBody` | case/gender errors | "Tai apima jautrius sveikatos duomenis. Juos tvarkome tik šiam tikslui." |
| L10N-09 (P1) | `agreeAndSend` | "Sutinku ir siųsti" | "Sutinku ir siunčiu" |
| L10N-10 (P1) | `hintGlasses`, `condMobility` | "judėjimas" (movement) | "judumo apribojimai" |
| L10N-11 (P1) | `privacyBody` | "hakdatono", "saugomi vietoje", "neprofiluojame" | "hakatono", "saugomi šiame įrenginyje", "nekuriame profilių" |
| L10N-12 (P2) | `familyTitle1` | "Kam kraunate" | "Kam ruošiate" |
| L10N-13 (P2) | `subscribeBody` | "perrinkti" | "perpakuoti" |
| L10N-14 (P2) | `catChildren`, `catPets` | "Vaikams", "Augintiniams" | "Vaikų reikmenys", "Augintinių reikmenys" |
| L10N-15 (P2) | `ownItem` | "Savo" | "Jūsų daiktas" |
| L10N-16 (P2) | `waterNote` | "likusį vandenį reikia išvalyti" | "…likusiam vandeniui – valymo priemonės." |
| L10N-17 (P2) | `advice.dart:135` | "Užrašykite kiekvieno vardo…" | "Užrašykite kiekvieno asmens vardą ant jo kuprinės." |
| L10N-18 (P2) | `deleteBody`, `expiryHint`, `itemDetails`, `familyHelper`, `aiOffline` | awkward phrasing | See the audit table in the review notes; have a native speaker do one pass |

**Done when:** a native speaker has read every screen in LT on a 360 px phone, and a golden test renders every screen in LT at 360×640.

---

## 7. Privacy, consent and security

**PRIV-01 (P0) — Health text is processed before consent.** `needs_screen.dart:74-76` → `app_state.dart:128-133` parses on every keystroke on step 02; consent is step 03. Under GDPR Art. 9, explicit consent should come before processing. Options: (a) consent before Needs, or (b) Needs collects raw text only and parsing starts after Agree. (a) is simpler and reads as more trustworthy.

**PRIV-02 (P0) — The privacy notice is false when AI is on.** `app_en.arb:247` and `app_lt.arb:247` say "No server receives your health text"; `deepseek_client.dart:49-66` sends names, ages and raw needs text. Consent purposes don't include AI. Either remove the AI path (AI-10 option 2) or add a separate explicit "AI help" opt-in that names the processor, its location and the transfer basis.

**PRIV-03 (P0 if AI is shown) — API key compiled into the client** (`deepseek_client.dart:19-24`, `String.fromEnvironment`). Anyone can extract it from the APK or `main.dart.js`. Use a serverless proxy (Cloudflare Worker / Vercel function) with rate limiting; never build web or release with the key.

**PRIV-04 (P1) — Plain-text health data + Android auto-backup.** `storage.dart` uses SharedPreferences; `AndroidManifest.xml` has no `allowBackup="false"`/`dataExtractionRules`. Set backup off and use `flutter_secure_storage`, or an encrypted file for the snapshot. On web it is `localStorage`: say so.

**PRIV-05 (P1) — Delete is a tombstone write.** `app_state.dart:238-242` writes a `cleared` snapshot instead of removing keys. Remove every key (`ready72.snapshot.v1`, `v2`, locale) and verify.

**PRIV-06 (P1) — Consent version and purposes are not enforced** (`app_state.dart:87`, `deepseek_client.dart:41-43`). Re-prompt when `consent.version != AppConfig.consentVersion`.

**PRIV-07 (P1) — Reminders are requested but never scheduled.** Consent asks "Send me reminders when food expires…", but there is no notification package or scheduling. Add `flutter_local_notifications` with the 60/14-day dates (they are already computed), or change the copy to "Show reminder dates in the app".

**PRIV-08 (P1) — "No analytics" vs bundled Google ML Kit/DataTransport** (from `mobile_scanner`). Disclose it in the notice or use the bundled-model variant without telemetry.

**PRIV-09 (P2)** — Publish a privacy policy page (the web demo can host it). `AppConfig.privacyNoticeUrl` currently points at the LT72 guide (`app_config.dart:67`).

**Pitch angle:** "Health data never leaves the phone; the plan is computed on-device" is a **winning differentiator** for a government/civil-protection audience, but only if it is true in the build we show.

---

## 8. Platform, build and deployment

**OPS-01 (P0) — Not a git repository.** `git status` fails. Run `git init`, write a proper `.gitignore` (add `video/node_modules/`, `video/build/`, `video/out/`, `.env*`, `*.zip`), commit, push to GitHub. Judges often check the repo and commit history.

**OPS-02 (P0) — No hosted demo.** Deploy `build/web` to Vercel/Netlify/Firebase/GitHub Pages; put the URL and a QR code on the last pitch slide and in the README. Test it on a real phone over mobile data.

**OPS-03 (P1) — Release APK is debug-signed** (`android/app/build.gradle.kts:29-32`; `apksigner` → `CN=Android Debug`). Create a release keystore (`key.properties`, gitignored), build an `.aab` and an `.apk`, enable shrink/minify.

**OPS-04 (P1) — CI.** GitHub Actions: `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, `flutter build web`, deploy on main. A green badge in the README costs 30 minutes and signals quality.

**OPS-05 (P1) — PWA claim is false.** `Makefile:14` uses the deprecated `--pwa-strategy=offline-first`; the generated `flutter_service_worker.js` unregisters itself and caches nothing. Either drop "offline PWA" from the docs or add a real service worker. Offline does matter for an emergency app, so a quick `workbox` cache of the built assets is worth it if time allows.

**OPS-06 (P1) — Repo bloat.** `video/` is ~1 GB (963 MB `node_modules`) inside the Flutter root; `build/` ~1 GB. Move `video/` to its own folder/repo or gitignore it.

**OPS-07 (P1) — Android manifest.** Declare `INTERNET` and `CAMERA` explicitly, `uses-feature android.hardware.camera required=false`, `allowBackup=false`. Localise the iOS `NSCameraUsageDescription` (LT).

**OPS-08 (P1) — macOS cannot reach the network**: missing `com.apple.security.network.client` in `macos/Runner/*.entitlements`. Add it or stop listing macOS as a target.

**OPS-09 (P2) — Web metadata.** `web/index.html` has no `lang`, no Open Graph/Twitter tags (link previews in the judges' chat will look empty), no `apple-mobile-web-app-capable`, a 192 px apple-touch-icon. `manifest.json` lacks `id`, `scope`, `lang`, `screenshots`. Add a branded loading screen. Flutter web shows a blank white page for 1–3 s on first load.

**OPS-10 (P2)** — Versions: `pubspec` 1.0.0+1, iOS/macOS 1.0, macOS product name "ready72" lowercase. Align. Add a project `LICENSE`; register the Inter font licence with `LicenseRegistry`.

**OPS-11 (P2)** — Stricter analysis: `strict-casts`, `strict-inference`, `unawaited_futures` (there are fire-and-forget `_persist()` calls at `app_state.dart:187, 211, 225, 232`).

**OPS-12 (P1) — Test on real devices.** The barcode camera has never run on hardware. Test the APK on one mid-range Android phone and Safari on an iPhone (web) before the demo. Record a backup video of the full flow (the `video/` Remotion project can produce it).

---

## 9. Tests

At audit time: 54 tests, all green. Current build: 62 tests. The gaps below were the plan; most are now covered.

- **TEST-01 (P0)** Regression tests for every P0 engine bug: child+pet crash, purification-only water, vegan blockers, toddler meals and calories, demo price range, 0 dropped.
- **TEST-02 (P1)** Eval must assert `blockersFired == 0` for every family and include children-only, senior-only, pet-without-adult, vegan, vegetarian, 4-year-old needing nappies, one adult + baby.
- **TEST-03 (P1)** Parser negative tests (EN + LT): "no pets", "not diabetic", "competition", multi-person sentences, LT inflections.
- **TEST-04 (P1)** `consent_gate_test.dart:42` checks only the `v1` key; the app now uses `v2`. Assert that **no** key exists before consent.
- **TEST-05 (P1)** `DeepSeekClient` with `MockClient`: 200, malformed JSON, 401 (no retry), timeout, missing consent, injection string.
- **TEST-06 (P1)** Storage: round trip, corrupt JSON, v1→v2 migration (both auto-seed and custom household).
- **TEST-07 (P1)** Layout matrix: every screen at 360×640 and 390×844, text scale 1.0/1.3/2.0, EN and LT. Fails on any RenderFlex overflow. This would have caught Subscribe, Pack and Welcome LT.
- **TEST-08 (P2)** Golden tests for the 8 artboard screens; compare against screenshots of the HTML artboard.
- **TEST-09 (P2)** `integration_test/` run of the full flow on an Android emulator in CI.

Rename the eval metric "Needs extraction accuracy 100%". It measures the deterministic parser on 8 cases written by us. Say exactly that, or grow the set to 50+ cases including negations and LT inflections and report the real number.

---

## 10. Documentation (fix before anyone reads the repo)

**DOC-01 — Stale or wrong statements:**

| Where | Says | Truth |
| --- | --- | --- |
| `README.md:53` | "except the six verified rows" | 16 |
| `docs/RESEARCH.md:111`, `docs/BARBORA_NOTES.md:124` | six verified | 16 |
| `docs/REPORT.md:146-149` | Android not built, licences not accepted | Release APK built, debug-signed |
| `docs/REPORT.md:142-143` | temporary debug tool excluded | Tool removed; drop the sentence |
| `README.md:5`, `REPORT.md:5-7` | eight screens | 8 artboard screens + Tracking + scanner |
| `README.md:30` | demo fixtures not in running UI | `DemoHousehold` is in `lib/models/person.dart` (migration + placeholder) |
| `README.md:48` | 60/14-day reminder dates stored | Computed, never scheduled |
| `README.md:56, 63` | data never leaves the device; no analytics | False with an AI key; ML Kit telemetry bundled |
| `REPORT.md:35, 145` | PWA + service worker | Service worker unregisters itself; not offline |
| `REPORT.md:127` | consent test proves zero stored snapshot | Checks only the v1 key |
| `REPORT.md:158` | "Needs extraction accuracy 100%" (AI) | Deterministic parser on 8 cases |
| `REPORT.md:190` | balance spread ~21–24 pp | Measured 20.4 pp (and will change after ENG-01) |
| `DEMO_SCRIPT.md:10` | official list ≈ 50 kg per person | 82 LT72 rows sum to ~28 kg total. Fix or source it |
| `DEMO_SCRIPT.md:44`, `RESEARCH.md:24-25` | 14-day medicine buffer used | `medicationBufferDays` unused |
| `DEMO_SCRIPT.md` | €747 / €1,235, 56 dropped | Must change after ENG-01/02 |

**DOC-02** — README top: one screenshot strip (8 screens), the hosted demo link, the APK link, a 30-second GIF, "How it works" in 3 bullets, then the technical detail. Today the README opens with stack deviations.

**DOC-03** — Add `docs/ARCHITECTURE.md` with one diagram: household → carry limits → needs → optimiser → guardrails → plan → order/pack/subscription. Judges with a technical background look for this.

**DOC-04** — Keep the honest "what is mocked" table. That honesty is good, but it belongs in the docs, not in the UI.

---

## 11. Features to add for "wow" (pick 2–3, do after P0s)

Ranked by impact per hour:

1. **Live "fit" animation on Plan** (M). Items drop into each person's bag; the weight bar fills; anything that doesn't fit visibly moves to a stronger carrier. This makes the unique idea, per-person carry limits, visible in 3 seconds.
2. **Example family + 60-second demo mode** (S). See UX-02.
3. **Per-person parsed needs chips** (M). See AI-09.
4. **"Grab and go" emergency view** (M). One screen for the moment of crisis: who takes which bag, where it is stored, what to add from home (medicine from the fridge, phone, keys, documents), the nearest shelter. Works offline. This answers the "so what happens in the emergency?" question that the current app never shows.
5. **Nearest shelter/evacuation point** (M–L). Lithuania publishes public shelter locations (PAGD "Priedangos" map). Even a static list for Vilnius with a map link is strong. Verify the data source and licence before using it.
6. **Printable/shareable checklist** (S–M). PDF or a share link per person ("Ona's bag"); grandparents don't install apps.
7. **Real reminders** (M). Local notifications for expiry and growth reviews (PRIV-07). Show one firing in the demo by setting a date to tomorrow.
8. **Real barcode demo** (S). Bring 3 real products whose EANs are in the catalogue (CAT-04); scan them live.
9. **Household sharing** (L). Invite a partner by link; both see the plan. Skip for the hackathon; mention it in the roadmap.
10. **Municipality / employer mode** (roadmap slide only). A B2B2C story: municipalities or employers sponsor bags for vulnerable residents/staff. Good for the business-model question.

---

## 12. Pitch, story and business

- **P0 — Lead with a person, not a feature.** "Ona is 71, takes insulin and weighs 62 kg. The official list adds up to ~28 kg of stuff. Ona can carry 7.4 kg. Nobody tells her which 7.4." Then show her bag. (Check the 28 kg figure against `lib/data/lt72.dart` and lt72.lt first.)
- **P0 — The number on the slide must match the app.** Today the artboard says €412 and the app says €1,235.
- **P1 — Show the moat in one sentence:** "Every bag is checked by 16 safety rules: weight, water, calories, allergies, medicine, before you see it." Then show one rule catching something (a nut allergy) live.
- **P1 — Business model:** subscription €16/month for the demo family. Explain the unit economics in one line (replacement food cost per year vs subscription revenue) and the partner channel (Barbora/Rimi referral or affiliate). Add: who else pays (municipalities, employers, insurers). Have rough numbers ready; do not invent market statistics on slides. Use only sourced figures.
- **P1 — Impact metric:** "% of households with a ready 72-hour bag" is the metric civil protection cares about. Find a sourced Lithuanian figure (government or survey) before using one.
- **P1 — Competitors / prior art:** official checklists (LT72 in Lithuania; similar national 72-hour campaigns exist in Finland, Estonia and Sweden) are static lists. Ready72's difference: per-person, carry-limit-aware, health-aware, orderable, kept fresh. Check exact names and URLs before putting them on a slide.
- **P2 — Roadmap slide:** EU-hosted backend, household sharing, real store APIs, municipality dashboard, offline shelter map.

---

## 13. What not to do

- Do not add a backend unless the AI path needs a key proxy. It adds demo risk for little visible value.
- Do not chase dark mode, macOS or iOS native builds before P0/P1 are done. Web + Android is enough for judges.
- Do not show the dropped-items list in the demo at all; fix the cause (ENG-02).
- Do not claim AI accuracy, live prices or PWA offline support that the build does not have. Judges ask.

---

## 14. Execution plan

Assumes ~2 working days. If there is less time, do Day 1 only.

### Day 1: demo-critical (P0)

| # | Task | IDs | Effort |
| --- | --- | --- | --- |
| 1 | `git init`, `.gitignore`, first commit | OPS-01, OPS-06 | S |
| 2 | Fix child+pet crash + error state on Consent | ENG-04 | S |
| 3 | Shared household kit, cheaper durables, Comfort = warmth add-on | ENG-01 | L |
| 4 | Priority packing, 85–90% fill, 0 dropped for the demo | ENG-02 | M |
| 5 | Water: litres guardrail, 0.5 L fallback, children carry small bottles | ENG-03 | M |
| 6 | Toddler food, calorie cap, single baby-food source | ENG-06 | S–M |
| 7 | Diet checks only for food; dedupe | ENG-05 | S |
| 8 | Remove internal copy; add "About this prototype" in settings | UX-01 | S |
| 9 | Example family link on Welcome | UX-02 | S |
| 10 | Parser negation, clause split, word boundaries | AI-01..03 | M |
| 11 | LT: Welcome size, Pack title, group labels, € format | L10N-01..05 | S |
| 12 | Privacy: consent before needs parsing; true notice; decide AI story | PRIV-01, -02, AI-10 | S–M |
| 13 | Regression tests for all of the above | TEST-01 | M |
| 14 | Deploy web, smoke test on a phone | OPS-02 | S |

### Day 2: product feel (P1)

| # | Task | IDs | Effort |
| --- | --- | --- | --- |
| 15 | Per-person weight bars + coverage strip on Plan | P-3, P-4, UX-10 | M |
| 16 | Pack completion → Home ("Your bags"), settings entry, resume | K-2, UX-03, UX-04 | L |
| 17 | READY72 header + back chevron, pinned CTA, progress hairline | UX-05..07 | S–M |
| 18 | Order: total, place-order confirm, stores match artboard | O-3, O-4, CAT-01 | M |
| 19 | Subscribe: cancel/manage, dated replacements, overflow fix | S-1..S-4 | M |
| 20 | Needs: answerable clarification + parsed chips | AI-04, AI-09, N-1 | M |
| 21 | Real EANs for verified rows; bring products to scan | CAT-04 | S |
| 22 | Layout matrix test (360/390 × 1.0/1.3/2.0 × EN/LT); fix overflows | TEST-07, S-2, K-3, F-3 | M |
| 23 | Icon, adaptive icon, splash, web loader, OG tags | UX-08, OPS-09 | M |
| 24 | Signed APK, CI badge | OPS-03, OPS-04 | M |
| 25 | Docs: README hero, fix every stale line, architecture diagram | DOC-01..03 | M |
| 26 | Native-speaker LT pass | L10N-06..18 | M |
| 27 | Rehearse pitch ×3; record backup video | Section 15 | M |

### If time remains (P2 / wow)

Fit animation (Wow 1), grab-and-go view (Wow 4), local notifications (PRIV-07), shelter list (Wow 5), printable checklist (Wow 6), remaining P2 items.

---

## 15. Demo script (target 3:00; rewrite numbers after ENG-01)

1. **0:00 Hook (20 s).** Ona's story (Section 12). Show the Welcome screen.
2. **0:20 Family (20 s).** Tap "Try with an example family". Point at the row hints: "Ona · senior · up to 7.4 kg; Mia · toddler · 0.4 kg".
3. **0:40 Needs (25 s).** Type or show: "Ona takes insulin. Mia is allergic to nuts. We have a dog." Chips appear under Ona and Mia. "No pets" counter-example if time: nothing appears.
4. **1:05 Consent (15 s).** One line: "Health data stays on the phone; nothing is sent." Agree.
5. **1:20 Plan (40 s).** Essential €2xx / Comfort €4xx. Per-person bars all under the limit. Coverage strip "LT72 critical 31/31". Tap Ona: insulin cooling pouch, low-sugar food, light items. Tap Mia: nut-free.
6. **2:00 Order (20 s).** Four stores, total, Place order → confirmation → tracking: "Your family is ready by Fri 20 Nov."
7. **2:20 Subscribe (15 s).** €16/month, "next food swap May 2027, Mia's next backpack Sep 2027".
8. **2:35 Pack (15 s).** Scan a real product → item checks off → last item → "Ona's bag is ready."
9. **2:50 Close (10 s).** "Every bag fits the person who carries it." Demo URL + QR.

Backup: if anything fails live, switch to the recorded video immediately. Do not debug on stage.

---

## 16. Judge Q&A prep

| Likely question | Answer to prepare |
| --- | --- |
| Where do prices come from? | Barbora live check on 13 Nov (N products); others are catalogue estimates. Production: retailer feeds/affiliate APIs. |
| Is the carry limit scientific? | LT72 guidance (one-fifth of body weight) + age caps + 15/12/10 kg ceilings for adults by body weight; sources in `docs/RESEARCH.md`. Be ready to explain why 200 kg ≠ 40 kg bag. |
| What if someone can't carry anything? | Their items move to the strongest carrier; if nobody can, the plan shows a gap rather than overloading anyone. |
| Is it safe for medical needs? | We never suggest doses; medicine is "bring your own prescription" + cooling pouch. Guardrail `no-doses` is tested. |
| GDPR? | Explicit consent before processing, on-device only, export and one-tap delete. (Only say this after PRIV-01/02 are fixed.) |
| How does AI fit? | Per AI-10 decision. Never claim live AI accuracy we did not measure. |
| Business model? | Subscription + retailer referral; B2B2C municipality/employer channel. |
| Why not just the LT72 list? | Static list ≈ dozens of kg; doesn't know who carries what, allergies, kids growing, expiry. |
| What's next? | Shelter map, household sharing, retailer integration, EU backend. |

---

## 17. Final pre-demo checklist

- [ ] `flutter test` green; `flutter analyze` clean; CI green
- [ ] Demo family: Essential and Comfort prices match the slides; 0 dropped; 0 blockers
- [ ] No "unverified/simulated/mocked/offline parser/DeepSeek" text on any consumer screen
- [ ] Example family button works on web and APK
- [ ] Every screen checked in EN and LT at 360 px; Lithuanian proofread
- [ ] Child+pet, vegan, one-senior, baby households produce sane plans
- [ ] "No pets" / "not diabetic" parse correctly
- [ ] Privacy notice text matches what the build actually does
- [ ] Pack ends in a completion state; Home screen exists; relaunch resumes
- [ ] Hosted web URL works on mobile data; QR on the last slide
- [ ] Release-signed APK on a real Android phone; camera scan tested with the real products you bring
- [ ] Backup screen recording of the full flow
- [ ] README hero, screenshots, links; stale docs fixed
- [ ] Git repo pushed; no secrets; no `video/node_modules` committed
- [ ] Pitch rehearsed 3× under 3:00
