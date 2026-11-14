#!/usr/bin/env python3
"""Scrape Decathlon Lithuania public search results through a local Chrome CDP session.

Decathlon behind Cloudflare returns 403 to plain HTTP clients. A normal headful
Chrome profile is used only to read public search pages. No login/cart/checkout.
"""
import json, re, sys, time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

sys.path.insert(0, str(Path(__file__).parent))
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'data' / 'stores' / 'decathlon.json'
PARTIAL = ROOT / 'data' / 'stores' / 'decathlon.partial.json'
MAX_PAGES = 8
sys.path.insert(0, '/tmp')
from cdp import CDP  # local helper, not committed

QUERIES = [
    'kuprinė', 'vaikiška kuprinė', 'miegmaišys', 'palapinė', 'miego kilimėlis',
    'palapinsiaustė', 'žibintuvėlis', 'priekinis žibintas', 'baterijos',
    'išorinė baterija', 'power bank', 'usb kabelis', 'radijas', 'švilpukas',
    'daugiafunkcis įrankis', 'kompasas', 'žemėlapis', 'virvė', 'parakordas',
    'lietaus striukė', 'flisas', 'termo apatiniai', 'kojinės', 'kepurė',
    'pirštinės', 'žygio batai', 'kaklo mova', 'kelnės', 'tualetinis popierius',
    'rankšluostis', 'muilas', 'pirmosios pagalbos', 'vaistinėlė', 'pleistrai',
    'turniketas', 'kaukė', 'dezinfekcinis', 'vandens filtras', 'vandens talpa',
    'gertuvė', 'viryklėlė', 'dujos', 'puodelis', 'šakutė', 'peilis',
    'maisto laikymas', 'sausas maistas', 'energijos batonėlis', 'vanduo',
    'vaiko nešioklė', 'pavadėlis', 'dubenėlis', 'avarinė antklodė',
]


def parse(html):
    count = re.search(r'data-page-count="(\d+)"', html)
    m = re.search(r'<script type="application/json" data-src>(.*?)</script>', html, re.S)
    rows = []
    if m:
        try:
            payload = json.loads(m.group(1))
            if payload and isinstance(payload[0], list):
                rows = payload[0]
        except Exception:
            pass
    return rows, int(count.group(1)) if count else 1


def product(row, query):
    meta = row.get('metaData') or {}
    return {
        'id': meta.get('sku') or meta.get('idProductAttribute'),
        'name': row.get('title'),
        'price': (row.get('price') or {}).get('amountRaw'),
        'currency': 'EUR',
        'url': row.get('cardLinkUrl'),
        'brand': row.get('brand') or '',
        'category': meta.get('nature') or '',
        'image': (row.get('image') or {}).get('url'),
        'search': query,
    }


def main():
    c = CDP()
    seen = {}
    if PARTIAL.exists():
        old = json.loads(PARTIAL.read_text())
        seen = {str(p['id']): p for p in old.get('products', [])}
        done = set(old.get('doneQueries', []))
        print(f'resume: {len(seen)} rows, {len(done)} queries', flush=True)
    else:
        done = set()
    for i, q in enumerate(QUERIES, 1):
        if q in done:
            continue
        base = 'https://www.decathlon.lt/search/?query=' + quote(q)
        html = c.eval(f"fetch({json.dumps(base)}).then(r=>r.text())")
        rows, pages = parse(html)
        print(f'[{i}/{len(QUERIES)}] {q}: {len(rows)} rows, {pages}p', flush=True)
        for page in range(1, min(pages, MAX_PAGES) + 1):
            if page > 1:
                url = f'{base}&page={page}'
                html = c.eval(f"fetch({json.dumps(url)}).then(r=>r.text())")
                rows, _ = parse(html)
            for row in rows:
                p = product(row, q)
                if p['id'] and p['price'] is not None:
                    seen[str(p['id'])] = p
            time.sleep(0.45)
        done.add(q)
        payload = {'count': len(seen), 'doneQueries': sorted(done), 'products': sorted(seen.values(), key=lambda p: (p['category'], p['name']))}
        PARTIAL.write_text(json.dumps(payload, ensure_ascii=False, separators=(',', ':')))
        time.sleep(0.45)
    products = sorted(seen.values(), key=lambda p: (p['category'], p['name']))
    payload = {
        'store': 'decathlon',
        'label': 'Decathlon',
        'currency': 'EUR',
        'scrapedAt': datetime.now(timezone.utc).isoformat(timespec='seconds'),
        'source': 'https://www.decathlon.lt/search/',
        'rate': '1 req/s via local Chrome',
        'count': len(products),
        'queries': QUERIES,
        'products': products,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, ensure_ascii=False, separators=(',', ':')))
    print(f'wrote {OUT} ({OUT.stat().st_size/1e6:.2f} MB) rows={len(products)}')


if __name__ == '__main__':
    main()
