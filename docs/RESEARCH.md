# Ready72 research

Retrieved 2026-11-13 unless stated otherwise. This document separates what was
verified, what was inferred, and what was deliberately left out.

## 1. LT72 official guidance

Primary source: **https://lt72.lt/isvykimo-krepsys-5/** (Priešgaisrinės apsaugos
ir gelbėjimo departamentas prie VRM). Read in full on 2026-11-13.

Facts taken directly from the page:

- Every family member should have their own evacuation bag, adapted to age,
  health and individual needs.
- The recommended maximum bag weight is **no more than one fifth (20%) of body
  weight**. A 100 kg person should carry no more than 20 kg.
- A roughly **45 litre backpack** is suggested.
- Food must be familiar, tasted, long-life, quick to prepare and nutritious.
  The page recommends 3 days of dry rations, canned meat, special/baby food,
  sweets, nuts, coffee/tea, salt and spices.
- Water guidance is **2–4 litres per person per day** for drinking, cooking and
  hygiene. It recommends carrying water in small containers and having
  purification tablets and a filter for natural water.
- Prescribed medicine reserve: the official page says **7 days**. Ready72 shows
  this and recommends a **14-day buffer** as the safer planning default, with a
  prompt to speak to a pharmacist or doctor. It never generates doses.
- Review the bag at least **twice a year**, ideally when changing tyres in
  April and November. Check expiry dates, electronics and seasonal clothing.
- Avoid military-looking bags and clothing. The page warns that looking like a
  combatant is dangerous in a war.
- The list covers documents, spare clothing, first aid, tools, food and water,
  hygiene, rest/sleep, electronics, children, elderly people, people with
  disabilities and pets.

The list was transcribed into `lib/data/lt72.dart` (82 structured rows with
category, quantity, weight, shelf life, priority, applicable groups and a
`supplementary` flag). Official rows are not invented. A small number of rows
are flagged `supplementary` (for example a portable solar panel and barter
items) where the idea comes from other official preparedness guides; the flag
is never used to silently extend the official list.

Supplementary sources (reviewed for comparison, not used to override LT72):

- Ready.gov, Build A Kit — https://www.ready.gov/kit
- American Red Cross, Survival kit supplies —
  https://www.redcross.org/get-help/how-to-prepare-for-emergencies/survival-kit-supplies.html

## 2. Safe carry weight

- LT72: at most **20% of body weight** for an evacuation bag.
- REI Expert Advice, “How Much Should Your Pack Weigh” —
  https://www.rei.com/learn/expert-advice/backpacking-weight.html — gives the
  general guideline that a loaded backpacking pack should not exceed about
  **20% of body weight**.
- Search results also surfaced lower day-hike targets (10%) and more aggressive
  mountaineering guidance. Ready72 chooses conservative values for dependants
  rather than the highest published number.

Implementation (`lib/config/app_config.dart`):

| Group | Share of body weight | Absolute cap |
| --- | --- | --- |
| Adult (15–64) | 20% | 15 kg |
| Adult 120–179 kg | 20% | 12 kg |
| Adult 180 kg+ | 20% | 10 kg |
| Senior (65+) | 12% | 10 kg |
| Child (4–14) | 15% | 8 kg |
| Toddler (under 4) | 3% | 2.5 kg |

Body weight is not a proxy for strength. The absolute caps prevent a very heavy
adult from being assigned a 20 kg load even when 20% of body weight would allow
it, and the cap tightens further above 120 kg and 180 kg. A 200 kg adult gets a
**10 kg** bag, not 20 kg. The 70 kg example remains 14 kg. A disclosed back
problem, pregnancy or mobility aid multiplies the limit by **0.60** and flags
the reduction; the app does not give medical advice.

## 3. Food and water targets

- Daily calorie planning values used for 72 hours: adult 2000, senior 1800,
  child 1400, toddler 1000 kcal/day. These are planning targets for mild
  activity, not medical prescriptions.
- LT72’s 2–4 l/day would make a 72-hour bag impossible for most people
  (6–12 kg just for water). Ready72 therefore carries a **1.0 l/person/day
  baseline** and makes **purification tablets mandatory**. The plan reports the
  trade-off instead of pretending the full 2–4 l is carried. Comfort spends
  spare capacity on warmth/shelter/filter rather than extra water weight.
- Food is selected only from the catalogue and must meet the allergy/diet
  constraints. The optimiser prefers calorie-dense, long-life products, caps
  quantities and mixes several products to avoid “40 identical cans”.

## 4. Growth projection

Method: a small median height-for-age table for ages 0–18, unisex
approximation, with clothing sizes mapped from height. This is sufficient for a
“review the bag before the child outgrows it” hint; it is not a clinical growth
chart and no sex is collected.

Reference for the method: WHO Child Growth Standards —
https://www.who.int/tools/child-growth-standards. The actual table is a simple
planning approximation, not a reproduction of WHO percentiles.

Review scheduling: every **6 months** for children under 6, every **12 months**
for older children and adults. Food expiry reminders are generated at **60 and
14 days** before the entered expiry date.

## 5. Store research route

- Barbora: public search pages are server-rendered and expose schema.org price,
  currency, availability and product URLs. Search is allowed by robots.txt;
  cart, checkout, account and delivery pages are disallowed. Details and the
  sixteen verified prices are in `docs/BARBORA_NOTES.md`.
- Decathlon: robots.txt allows public pages, but automated requests to the
  Lithuanian homepage returned HTTP 403 in this environment. Zero live
  Decathlon prices were verified. Catalogue Decathlon rows are fixtures and
  are marked unverified.
- Rimi and Eurovaistinė are used as mocked additional stores. Their public
  search paths were checked for URL validity, but no live price scrape was
  integrated.

## 6. Reddit route

The official Data API requires OAuth, a registered app, a descriptive user
agent and rate-limit compliance (commonly ~100 queries/minute per OAuth client;
unauthenticated traffic is blocked or limited). Sources:

- Reddit Data API Terms — https://redditinc.com/policies/data-api-terms
- Reddit Data API Wiki (Reddit Help) — https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

No credentials were available during the hackathon and no attempt was made to
bypass the API, robots.txt or rate limits. Ready72 therefore ships 13 manually
paraphrased advice samples from public preparedness communities, with subreddit
links rather than invented thread permalinks. Full details and conflicts are in
`docs/REDDIT_RESEARCH.md`.

## 7. What is not verified

- Sixteen Barbora prices are verified; the rest of the catalogue is fixture data. The raw 18-query, 144-row scrape is in `docs/price_snapshots/barbora_2026-11-13.json`.
- Decathlon prices: 0 verified.
- Reddit: 0 live threads collected; 13 manual samples.
- DeepSeek: no live key in this environment, so live model quality is not
  measured. The deterministic parser and the guardrails are fully exercised.
- Delivery slots and shipment statuses are simulated.
