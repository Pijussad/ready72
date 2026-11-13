# Guardrails

The plan is produced by a pipeline: household → needs parsing → catalogue
selection → deterministic optimiser → guardrail checks → repair/drop → final
plan. Every rule below is checkable by ordinary Dart code; none asks the LLM
again.

## Discovery method (honest note)

The intended discovery step was: give DeepSeek the research corpus and failed
test outputs, ask it to propose rules, then red-team with deliberately broken
plans until no new failure type appears. **No DeepSeek key was available in this
environment**, so the discovery/red-team loop was run manually against the
deterministic pipeline and its failure tests. The rule set below is therefore
hand-curated from the brief, LT72, and observed failures; it is not a claim of
live model-driven discovery. The rules are more numerous than the starting
examples and each has test evidence.

## Rules

| ID | Rule | Severity | Evidence | Repair |
| --- | --- | --- | --- | --- |
| food-mandatory | Every person has ≥90% of their 72-hour calorie target. | Blocker | LT72 food section; planning calorie values in `app_config.dart` | Add the cheapest compatible calorie-dense food; if capacity fails, report the gap. |
| water-mandatory | Carried litres meet 80% of the baseline for every person, plus purification. | Blocker | LT72 water section (2–4 l/day; tablets/filter for natural water) | Add water bottles and purification tablets. |
| critical-coverage | Every critical LT72 category is covered, or the gap is shown. | Blocker | `lib/data/lt72.dart`, critical category set | Add the lightest item from the missing category, or report. |
| carry-limit | No bag exceeds its owner’s limit. | Blocker | LT72 one-fifth rule; age caps in config | Move to the strongest carrier or drop the lowest priority line. |
| allergen | No item contains an allergen or violates a diet for its beneficiary **or carrier**. | Blocker | LT72 special-diet guidance; user needs | Swap for a compatible item; report if none. |
| age | Items are suitable for the beneficiary’s age. | Blocker | LT72 child/infant guidance; age bands | Replace with an age-appropriate product. |
| product-exists | Every product id exists in the catalogue snapshot. | Blocker | Catalogue contract | Remove invented ids; rebuild from catalogue. |
| quantity-sane | No line >12 units and no duplicate line. | Warning | Red-team: hoarding/duplicates | Cap and merge. |
| needs-mapped | Every parsed need maps to an item, reduced limit or visible gap. | Blocker | Brief §4.3 | Add the mapped item or list the gap. |
| shelf-life | Stored food has ≥12 months shelf life. | Blocker | Stored-food rule; LT72 twice-yearly review | Swap to longer-life food. |
| no-doses | No medicine dose is generated or displayed. | Blocker | Medical safety rule | Replace with a “bring your own prescribed medicine” reminder. |
| price-snapshot | Every price comes from the catalogue snapshot, never a model. | Blocker | Brief §4.4a | Recompute from catalogue; flag unverified prices. |
| price-range | Per-person total is within €60–€900. | Warning | Catalogue sanity bounds | Flag for review. |
| pets-covered | A pet household gets pet food and handling items. | Blocker | LT72 pet section | Add the pet kit to the strongest adult bag. |
| shared-heavy | Heavy shared items (>0.5 kg) go to an adult, never a child/toddler. | Blocker | Brief §4.4b | Reassign to the adult with the most room. |
| balance | Carriers finish within 15 percentage points of the fullest bag. | Warning | Brief §4.4b balance target | Move light units from the fullest bag. |

Extra rules beyond the brief’s starting list: age, product-exists,
quantity-sane, needs-mapped, shelf-life, no-doses, price-snapshot, price-range,
pets-covered, shared-heavy, balance.

## How the pipeline enforces them

1. Personal essential kit is assigned first, then overflow moves to a carer.
2. Food, water and pet load are distributed **before** comfort kit, so comfort
   cannot crowd out calories.
3. Shared units go to the carrier with the most remaining capacity, with
   weight-based eligibility (heavy → adults only).
4. If a unit cannot fit, it is dropped by priority (comfort → important), never
   silently. The Plan screen reports the count and lists the dropped items.
5. Guardrails run after assembly. The demo plan has **0 blocker failures**. The
   only warning is the balance spread (roughly 20–25 percentage points) caused by the
   toddler’s 0.39 kg limit and Ona’s reduced limit.
6. There is no live LLM answer in this build, so “raw LLM vs guarded” failure
   rates are **not measured**. The deterministic fallback is the demo engine.

## Test evidence

Run `flutter test test/guardrails_test.dart` and
`flutter test test/optimizer_test.dart`.

Deliberate failures, all caught:

| Injected failure | Rule that fired |
| --- | --- |
| Food removed, calories zeroed | `food-mandatory` |
| Bag limit lowered below its load | `carry-limit` |
| Invented product id | `product-exists` |
| Catalogue price changed by €10 | `price-snapshot` |
| Water items and water coverage removed | `water-mandatory`, `critical-coverage` |
| “Insulin 20 units” medication item | `no-doses` |

Evaluated families (8, including Lithuanian, vague text, insulin, nut allergy,
newborn, wheelchair, two pets, vegan child):

- needs extraction 100%
- weight compliance 100%
- critical-category coverage 100%
- allergy exclusion 100%
- invented/no medical doses 0

## Firing frequency in the demo family

| Rule | Final demo plan | Deliberate test |
| --- | --- | --- |
| All blockers | 0 fired | 1 each where injected |
| balance | warning at ~20–25 pp | not injected |
| price-range | passes | not injected |
| quantity-sane | passes | not injected |

The raw planner is deterministic, so these counts are reproducible.
