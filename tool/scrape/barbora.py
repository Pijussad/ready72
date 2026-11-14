#!/usr/bin/env python3
"""Scrape the public Barbora category tree into a local product database.

Only public category pages are read. No account, cart or checkout is touched.
One request per second, cached under .cache/scrape, with a clear user agent.
"""
import json, math, re, sys, time
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import ROOT, fetch, category_data

BASE = 'https://barbora.lt'
OUT = ROOT / 'data' / 'stores' / 'barbora.json'


def roots():
    xml = fetch(f'{BASE}/sitemap-categories.xml', sleep=0.5)
    urls = sorted(set(re.findall(r'<loc>(https://barbora\.lt/c/[^<]+)</loc>', xml)))
    return [u for u in urls if u.rstrip('/').count('/') == 5]


def product(row):
    slug = row.get('url') or ''
    return {
        'id': row.get('id'),
        'name': (row.get('title') or '').strip(),
        'price': row.get('price'),
        'url': f'{BASE}/p/{slug}' if slug else None,
        'category': (row.get('categoryPathUrl') or '').split('/')[-1],
        'categoryPath': row.get('categoryPathUrl'),
        'brand': row.get('brand') or '',
        'unit': row.get('unit') or {},
        'compare': row.get('comparativeUnit') or {},
        'status': row.get('status'),
        'alcohol': bool(row.get('isAlcohol')),
        'ageLimit': row.get('ageLimitation'),
        'image': row.get('image'),
        'expirationDays': row.get('expirationDays'),
        'promotion': row.get('promotion'),
    }


def main():
    all_rows = {}
    root_list = roots()
    for index, root in enumerate(root_list, 1):
        first = category_data(fetch(root))
        if not first:
            print(f'[{index}/{len(root_list)}] no data: {root}', flush=True)
            continue
        total, limit = first['count'], first.get('limit', 60)
        pages = math.ceil(total / limit)
        print(f'[{index}/{len(root_list)}] {root.rsplit("/",1)[-1]} {total} / {pages}p', flush=True)
        for page in range(1, pages + 1):
            url = root if page == 1 else f'{root}?page={page}'
            data = first if page == 1 else category_data(fetch(url))
            if not data:
                print(f'  page {page}: no data', flush=True)
                continue
            for row in data.get('inventories') or []:
                if row.get('id'):
                    all_rows[row['id']] = product(row)
            if page % 10 == 0:
                print(f'  page {page}/{pages} rows={len(all_rows)}', flush=True)
    rows = list(all_rows.values())
    rows.sort(key=lambda r: (r['categoryPath'] or '', r['name']))
    payload = {
        'store': 'barbora',
        'label': 'Barbora',
        'currency': 'EUR',
        'scrapedAt': datetime.now(timezone.utc).isoformat(timespec='seconds'),
        'source': f'{BASE}/sitemap-categories.xml',
        'rate': '1 req/s',
        'count': len(rows),
        'products': rows,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, ensure_ascii=False, separators=(',', ':')))
    print(f'wrote {OUT} ({OUT.stat().st_size/1e6:.1f} MB) rows={len(rows)}')


if __name__ == '__main__':
    main()
