# Store notes: Barbora and Decathlon

Research date: 2026-11-13. This is information only; Ready72 does **not**
connect to Barbora or Decathlon ordering. The app uses a local catalogue and a
mocked checkout.

## Barbora

### What was verified

- Public search URL: `https://barbora.lt/search?q=<query>` returns HTTP 200 and
  a server-rendered result page. `/paieska?q=` redirects to `/search?q=`.
- The page contains product cards with:
  - a title in `<span id="category-product-title-N">…</span>`;
  - a product link under `/p/<slug>`;
  - schema.org microdata: `itemProp="price" content="0.99"`,
    `itemProp="priceCurrency" content="EUR"`,
    `itemProp="availability" content="https://schema.org/InStock"`;
  - a visible unit-price label (for example `0,5 €/l`).
- `https://barbora.lt/robots.txt` disallows account, cart, checkout, delivery
  and payment paths (`/mano-prekes/`, `/krepselis`, `/pristatymas`,
  `/atsiskaitymas`, and equivalents in other languages). Search pages are not
  disallowed.
- An initial request pass used a clear agent
  `Ready72-research/1.0 (contact: demo@ready72.lt)` at one request per 1.2
  seconds. A later Puppeteer/Chromium pass fetched 18 search terms at 1.5 s
  intervals and produced 144 product rows; all 18 returned. The raw output is
  saved in `docs/price_snapshots/barbora_2026-11-13.json`.
- No account was created, no login was attempted, no cart or checkout was
  touched, and no personal data was collected.

### Sixteen live prices used in the catalogue

These rows are marked `verified: true` in `lib/data/catalogue.dart` and link to
the public product page:

| Product | Price | URL |
| --- | --- | --- |
| AKVILĖ still mineral water 500 ml | €0.59 | https://barbora.lt/p/negazuotas-naturalus-mineralinis-vanduo-akvile-500-ml |
| AKVILĖ still mineral water 1.5 l | €0.85 | https://barbora.lt/p/negazuotas-naturalus-mineralinis-vanduo-akvile-1-5-l |
| LINKĖJIMAI IŠ KAIMO oat groats 500 g | €1.49 | https://barbora.lt/p/avizines-kruopos-linkejimai-is-kaimo-500-g |
| ECON canned braised beef 230 g | €1.49 | https://barbora.lt/p/konservuota-troskinta-jautiena-econ-230-g |
| PERGALĖ dark chocolate 72% 85 g | €2.19 | https://barbora.lt/p/juodasis-sokoladas-72-proc-pergale-85-g |
| First aid kit | €36.99 | https://barbora.lt/p/pirmosios-pagalbos-vaistinele-1-vnt |
| GO ON protein bar, cookies, 50 g | €1.19 | https://barbora.lt/p/baltyminis-batonelis-go-on-sausainiu-skonio-50-g |
| ARIMEX roasted salted nut mix 300 g | €2.19 | https://barbora.lt/p/kepintu-ir-sudytu-riesutu-misinys-arimex-300-g |
| ARIMEX bread seed mix 100 g | €0.99 | https://barbora.lt/p/seklu-misinys-duonai-arimex-100-g |
| HOGARENAS 6 Seeds crackers 189 g | €1.89 | https://barbora.lt/p/krekeriai-hogarenas-6-seeds-189-g |
| LA MOLISANA Fusilli pasta 500 g | €1.39 | https://barbora.lt/p/makaronai-la-molisana-fusilli-nr-28-sraigteliai-500-g |
| HUGGIES Overnights nappies S4, 26 pack | €14.99 | https://barbora.lt/p/sauskelnes-huggies-overnights-s-4-26-vnt-26-vnt |
| HOLLE 1 infant formula 400 g | €11.99 | https://barbora.lt/p/ekologiskas-pieno-misinys-kudikiams-holle-1-nuo-gimimo-400-g |
| KUBUŠ baby apple/carrot/mango puree 100 g | €1.49 | https://barbora.lt/p/morku-obuoliu-ir-mangu-tyrele-kubus-baby-nuo-6-men-100-g |
| HAPPY TAILS dog food with beef 1250 g | €1.29 | https://barbora.lt/p/konservuotas-sunu-edalas-su-jautiena-happy-tails-1250-g |
| HAPPY TAILS cat food with fish 415 g | €0.49 | https://barbora.lt/p/konservuotas-kaciu-edalas-su-zuvimi-happy-tails-415-g |

A search for 2 l water also found AKVILĖ 2 l at €0.99 and ASET 5 l at €0.55.
The plan uses 1.5 l bottles for adults and 500 ml bottles for children; a
3-person adult household therefore gets six 1.5 l bottles (9 l), not eighteen
500 ml bottles. Olive oil was removed from the planner after a quantity review:
it was acting as a calorie filler and produced an odd 750 ml line.

### What is assumed, not verified

- Whether Barbora exposes a public or partner ordering API. No public partner
  API documentation was found. Assume any real integration requires a retail
  partnership, credentials and a contract.
- Delivery slots, fees, minimum baskets and substitution rules. Not tested;
  Ready72’s delivery dates and statuses are simulated.
- How a household account’s basket, loyalty pricing and age-restricted items
  behave. Not tested because no account or order was created.
- Whether every product page keeps the same microdata shape over time.

### What an integration would require

1. A written retail/partner agreement and API credentials (or a supported
   affiliate/product-feed route).
2. A product feed with stable SKUs/EANs, pack sizes, prices, stock, allergens
   and shelf life.
3. Delivery-slot and address APIs; age-restricted item handling.
4. Rate limits, caching and a price-snapshot audit trail.
5. A real checkout handoff. Ready72’s current “order” is a prepared basket plus
   deep links, not a checkout.

## Decathlon Lithuania

### What was verified

- `https://www.decathlon.lt/robots.txt` disallows account, cart, checkout,
  order-tracking and private paths, but allows public category pages.
- Automated requests to `https://www.decathlon.lt/` returned HTTP 403 in this
  environment. A public category page exists at
  `https://www.decathlon.lt/6493-kuprines` (verified through a public search
  result), but no live price could be read without a browser session.
- Zero Decathlon deals were verified. All Decathlon rows in the catalogue are
  fixtures marked `verified: false`; the app’s order screen counts them as
  unverified prices.

### Assumptions

- Decathlon likely requires a browser-like session or its own product feed for
  reliable prices. A production integration should use an official affiliate or
  partner feed rather than scraping.
- Store stock and delivery dates for Decathlon are mocked.

## Rimi and Eurovaistinė

These are used as additional mocked stores so the order screen can show a
realistic split. Public search paths were checked for URL validity:

- `https://www.rimi.lt/e-parduotuve/lt/paieska?query=…`
- `https://www.eurovaistine.lt/paieska/rezultatai?q=…`

No live price scrape was integrated and no order was placed. Their catalogue
rows are fixtures marked unverified.

## Ethics checklist

- Read robots.txt before fetching. ✔
- One request per second or slower. ✔ (1.2 s)
- Clear user agent. ✔
- Public pages only. ✔
- No login, no cart, no checkout, no real order. ✔
- No personal data collected. ✔
- Cached/saved results with a timestamp. ✔ (sixteen verified rows + this note)
- Failures reported, not hidden. ✔ (HTTP 500 on one Barbora query, 403 on
  Decathlon)
