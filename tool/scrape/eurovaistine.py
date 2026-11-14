#!/usr/bin/env python3
"""Scrape public Eurovaistine category pages for first-aid, hygiene and baby goods."""
import json, re, sys, time
from datetime import datetime, timezone
from pathlib import Path
from bs4 import BeautifulSoup
sys.path.insert(0, str(Path(__file__).parent))
from common import ROOT, fetch

OUT = ROOT / 'data' / 'stores' / 'eurovaistine.json'
PARTIAL = ROOT / 'data' / 'stores' / 'eurovaistine.partial.json'
BASE = 'https://www.eurovaistine.lt'
CATS = Path('/tmp/ev_cats.txt').read_text().split()


def parse(html, cat):
    s = BeautifulSoup(html, 'lxml')
    rows = []
    for card in s.select('a.productCard'):
        img = card.select_one('img')
        title = (img.get('alt') if img else '').strip()
        price_el = card.select_one('.productPrice')
        raw = price_el.get_text(' ', strip=True) if price_el else ''
        m = re.search(r'(\d+[.,]\d{2})', raw.replace('\xa0', ' '))
        href = card.get('href') or ''
        if not title or not m or not href:
            continue
        rows.append({
            'id': href.rsplit('/', 1)[-1],
            'name': title,
            'price': float(m.group(1).replace(',', '.')),
            'url': BASE + href,
            'category': cat,
            'brand': '',
            'image': (img.get('src') if img else None),
        })
    return rows


def main():
    done = set()
    seen = {}
    if PARTIAL.exists():
        old = json.loads(PARTIAL.read_text())
        done = set(old.get('done', []))
        seen = {p['id']: p for p in old.get('products', [])}
    for i, cat in enumerate(CATS, 1):
        if cat in done:
            continue
        try:
            html = fetch(cat, sleep=0.45)
            for row in parse(html, cat.replace(BASE + '/l/', '')):
                seen[row['id']] = row
        except Exception as e:
            print(f'  fail {cat}: {e}', flush=True)
        done.add(cat)
        if i % 10 == 0:
            print(f'[{i}/{len(CATS)}] rows={len(seen)}', flush=True)
            PARTIAL.write_text(json.dumps({'done': sorted(done), 'products': list(seen.values())}, ensure_ascii=False, separators=(',', ':')))
    rows = sorted(seen.values(), key=lambda p: (p['category'], p['name']))
    payload = {
        'store': 'eurovaistine', 'label': 'Eurovaistinė', 'currency': 'EUR',
        'scrapedAt': datetime.now(timezone.utc).isoformat(timespec='seconds'),
        'source': 'https://www.eurovaistine.lt/sitemap/taxons.xml',
        'rate': '1 req/s', 'count': len(rows), 'products': rows,
    }
    OUT.write_text(json.dumps(payload, ensure_ascii=False, separators=(',', ':')))
    print(f'wrote {OUT} ({OUT.stat().st_size/1e6:.2f} MB) rows={len(rows)}')


if __name__ == '__main__':
    main()
