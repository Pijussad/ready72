# Store product database

Generated: 14 Nov 2026. Currency: EUR. Source: public store pages.

| Store | Products | Coverage |
| --- | ---: | --- |
| Barbora | 24,866 | Every product in the public category tree (`sitemap-categories.xml`); 107 of 24,973 sitemap URLs were not returned by category pages. |
| Decathlon | 3,711 | Public search results for 53 Lithuanian 72-hour-kit queries, 8 pages each. |
| Eurovaistinė | 4,981 | 535 public first-aid, hygiene, baby, health and travel categories. |
| **Total** | **33,558** | |

Rimi is not in this generated database yet. The app keeps its small Rimi fixture for order splitting.

## Files

- `data/stores/barbora.json` — raw normalized scrape.
- `data/stores/decathlon.json` — raw normalized scrape; SKU, exact price, URL.
- `data/stores/eurovaistine.json` — raw normalized scrape.
- `assets/catalogue/products.json` — merged, compact, classified database loaded by the app.
- `assets/catalogue/meta.json` — counts, scrape timestamps and caveats.

## Schema

Every row has:

- `id` — globally unique `store:sku`.
- `store`, `name`, `price`, `url` — exact observed price and product page.
- `category`, `group`, `brand`.
- `role` — retrieval hint (`water`, `first-aid`, `sleep-shelter`, `pet-food`, …).
- `tags` — `food`, `medical`, `baby`, `pet`, `gear`, `alcohol`, etc.
- `pack`, `netKg`, `litres`, `count` — parsed from the product name.
- `kcal`, `shelfMonths` — estimates for plan maths, not label data.
- `image` — public store image URL.

## Use in the app

`StoreCatalogue.load()` reads the asset once. Settings → **Product catalogue** searches it locally, shows exact prices and opens the real product page. The AI shortlist uses `StoreCatalogue.search` / `forRole`, then `DeepSeekClient.pickFromCatalogue` may return only ids from that shortlist. The app re-reads name, price and URL from the database, so the model cannot invent a product or price.

## Caveats

- A scrape is a snapshot. Prices and stock change; the UI shows the observed date in `meta.json`.
- Role, pack weight, calories, shelf life and tags are rule-based estimates, **not safety claims**. Allergen and diet filtering must be verified against the label before a real order.
- Decathlon sits behind Cloudflare. The scrape used a normal headful Chrome session on public search pages, one request at a time; no login, cart or checkout.
- Eurovaistinė `robots.txt` disallows search-result URLs; only public category pages from its sitemap were read.
- No account, cart, checkout, personal data or payment flow was touched.

## How the plan uses real prices

`tool/match_fixtures.py` matches each curated product (`lib/data/catalogue.dart`) to the cheapest sensible real offer using reviewed Lithuanian keyword, exclusion, store and price-band rules, and writes `assets/catalogue/matches.json` (about 20 KB, loaded at start-up). The optimiser keeps the curated weight, calories, shelf life, allergens and age range, because the carry and safety guardrails depend on them; only price, store, title and URL come from the offer, and the line counts as verified. Products with no confident match (for example CPR mask, tourniquet, FFP2 masks, hand sanitiser, emergency blanket, expedition meals) keep their fixture price and stay flagged unverified. Review `python3 tool/match_fixtures.py` output after every re-scrape.

## Rebuild

```bash
python3 tool/scrape/barbora.py
python3 tool/scrape/decathlon.py       # needs Chrome on :9222
python3 tool/scrape/eurovaistine.py
python3 tool/build_catalogue.py
python3 tool/match_fixtures.py
flutter test test/store_catalogue_test.dart
```
