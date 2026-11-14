#!/usr/bin/env python3
"""Merge store scrapes into one compact, classified product database.

This is deliberately rule-based. Every row keeps the store's exact observed
price and URL; the role/tags are retrieval hints for the planner and the AI,
not safety claims. Nutrition, pack weight and shelf life are estimates.
"""
import json, re, unicodedata
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STORES = ROOT / 'data' / 'stores'
OUT = ROOT / 'assets' / 'catalogue' / 'products.json'
META = ROOT / 'assets' / 'catalogue' / 'meta.json'

ROLES = {
    'water': (['vanduo', 'mineralinis vanduo'], ['drink'], 24, 0),
    'meal-ready': (['ekspedicinis', 'patiekalas', 'sriuba', 'košė'], ['food'], 18, 450),
    'canned-fish': (['konservuota skumbr', 'konservuota tun', 'konservuota žuv', 'sardel'], ['food'], 36, 200),
    'canned-meat': (['konservuota jautien', 'konservuota paukšt', 'konservuota mesa', 'konservuotos dešr'], ['food'], 36, 250),
    'beans': (['pupel', 'žirnel', 'ankšt', 'lęši'], ['food'], 24, 110),
    'energy-bar': (['batonėl', 'baltyminis', 'protein'], ['food'], 12, 400),
    'nuts': (['riešut', 'migdol', 'anakard', 'lazdyn'], ['food'], 9, 600),
    'peanut-butter': (['riešutų sviest'], ['food'], 12, 600),
    'crackers': (['kreker', 'sausain', 'traškuč'], ['food'], 9, 450),
    'chocolate': (['šokolad'], ['food'], 12, 550),
    'pasta': (['makaron', 'spage', 'fusilli', 'penne', 'rigat'], ['food'], 24, 350),
    'oats': (['aviž', 'kruop', 'dribsni'], ['food'], 12, 370),
    'dried-fruit': (['džiovint', 'razin', 'datul', 'slyv'], ['food'], 12, 300),
    'formula': (['pieno mišin', 'mišinys kūdik'], ['baby', 'food'], 18, 500),
    'baby-food': (['tyrel', 'kūdikių', 'nuo 4 mėn', 'nuo 6 mėn'], ['baby', 'food'], 12, 70),
    'toddler-food': (['mažyli', 'vaikų patiekal', 'vaikų užkand'], ['baby', 'food'], 9, 350),
    'coffee': (['kava', 'kavos'], ['drink'], 18, 0),
    'tea': (['arbata', 'arbatos'], ['drink'], 18, 0),
    'pet-food': (['šunų ėdal', 'kačių ėdal', 'šunų maistas', 'kačių maistas', 'gyvūnų'], ['pet'], 18, 350),
    'first-aid': (['pirmosios pagalbos', 'vaistinėl', 'pleistr', 'tvar', 'turniket', 'žaizd'], ['medical'], 36, 0),
    'medicine': (['vaist', 'tablet', 'kapsul', 'lašai', 'sirup', 'gelis'], ['medical'], 24, 0),
    'hygiene': (['higien', 'dantų', 'šepetėl', 'dantų pasta', 'muil', 'šampūn', 'dušo', 'skustuv', 'servetėl', 'tualetinis', 'įklot', 'tampon', 'sauskeln'], ['hygiene'], 36, 0),
    'sanitizer': (['dezinfekc', 'antisept', 'rankų'], ['hygiene', 'medical'], 24, 0),
    'mask': (['kaukė', 'respirator', 'ffp'], ['medical'], 36, 0),
    'clothing': (['striuk', 'flis', 'termo', 'kojin', 'kepur', 'pirštin', 'batai', 'kelnės', 'marškin', 'drabuž'], ['clothing'], 0, 0),
    'backpack': (['kuprin'], ['gear'], 0, 0),
    'sleep-shelter': (['miegmaiš', 'palapin', 'kilimėl', 'palapinsiaust', 'antklod'], ['shelter'], 0, 0),
    'light-power': (['žibintuv', 'baterij', 'išorinė baterij', 'power bank', 'usb kabel', 'radijas'], ['light', 'power'], 0, 0),
    'tools': (['įrank', 'kompas', 'švilpuk', 'parakord', 'virvė', 'lipni juosta', 'peilis', 'viryklėl', 'dujos', 'puodel', 'šakutė'], ['tools'], 0, 0),
    'documents': (['dokument', 'užrašin', 'rašikl', 'žemėlap'], ['documents'], 0, 0),
    'pet-gear': (['pavadėl', 'dubenėl', 'nešiokl', 'gyvūn'], ['pet'], 0, 0),
    'child-gear': (['vaikiška', 'vaikui', 'mažyli', 'sauskeln', 'žaisl'], ['baby'], 0, 0),
}

ROLE_ORDER = list(ROLES)


def deaccent(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s.lower()) if unicodedata.category(c) != 'Mn')


def classify(name, category, store):
    text = deaccent(f'{name} {category}')
    for role in ROLE_ORDER:
        words = ROLES[role][0]
        if any(deaccent(w) in text for w in words):
            # Keep water bottles distinct from filters and water containers.
            if role == 'water' and any(x in text for x in ['filtr', 'talpa', 'gertuv', 'maišelis']):
                continue
            if role == 'pet-food' and store == 'barbora' and 'gyvunu-prekes' not in category:
                continue
            return role
    if any(x in text for x in ['maistas', 'bakaleja', 'pieno', 'mesa', 'zuvis', 'vaisiai', 'darzoves', 'duona', 'saldytas', 'konditer']):
        return 'food-other'
    if any(x in text for x in ['kosmetika', 'higiena']):
        return 'hygiene-other'
    return 'other'


PACK_RE = re.compile(r'(\d+(?:[.,]\d+)?)\s*(kg|g|ml|l|vnt\.?|tabletės?|tablet|kapsulės?|kapsul|ritin|poros?|m|cm|mm)\b', re.I)


def parse_pack(name):
    found = PACK_RE.findall(name)
    for amount, unit in reversed(found):
        value = float(amount.replace(',', '.'))
        u = unit.lower().rstrip('.')
        if u == 'kg': return value, value, None, 'mass', None
        if u == 'g': return value / 1000, value / 1000, None, 'mass', None
        if u == 'l': return None, None, value, 'volume', None
        if u == 'ml': return None, None, value / 1000, 'volume', None
        if u.startswith('vnt') or u.startswith('tablet') or u.startswith('kapsul') or u in ('ritin', 'poros'):
            return None, None, None, 'count', int(value)
    return None, None, None, None, None


def main():
    products = []
    source_meta = []
    for name in ['barbora', 'decathlon', 'eurovaistine']:
        path = STORES / f'{name}.json'
        if not path.exists():
            continue
        data = json.loads(path.read_text())
        source_meta.append({
            'store': name, 'label': data.get('label'), 'count': data.get('count'),
            'scrapedAt': data.get('scrapedAt'), 'source': data.get('source'),
        })
        for p in data['products']:
            if p.get('alcohol'):
                tags = ['alcohol', 'ageRestricted']
            else:
                tags = []
            role = classify(p['name'], p.get('categoryPath') or p.get('category') or '', name)
            kg, net_kg, litres, kind, count = parse_pack(p['name'])
            kcal100 = ROLES.get(role, ([], [], 0, 0))[3] if role in ROLES else 0
            kcal = round(kcal100 * (net_kg or 0) * 10) if net_kg else 0
            if 'food' in tags or role in ('meal-ready', 'canned-fish', 'canned-meat', 'beans', 'energy-bar', 'nuts', 'peanut-butter', 'crackers', 'chocolate', 'pasta', 'oats', 'dried-fruit', 'formula', 'baby-food', 'toddler-food', 'coffee', 'tea', 'pet-food'):
                tags.append('food')
            if role in ROLES:
                tags.extend(ROLES[role][1])
            tags = sorted(set(tags))
            products.append({
                'id': f'{name}:{p["id"]}',
                'store': name,
                'name': p['name'].strip(),
                'price': round(float(p['price']), 2),
                'url': p['url'],
                'category': (p.get('categoryPath') or p.get('category') or '').split('/')[-1],
                'group': ((p.get('categoryPath') or '').split('/')[1] if p.get('categoryPath') and len((p.get('categoryPath') or '').split('/')) > 1 else (p.get('category') or '')),
                'brand': (p.get('brand') or '').strip(),
                'role': role,
                'tags': tags,
                'pack': f'{count} vnt.' if count else (f'{net_kg*1000:.0f} g' if net_kg else (f'{litres:g} l' if litres else '')),
                'netKg': round(net_kg, 3) if net_kg else None,
                'litres': round(litres, 3) if litres else None,
                'count': count,
                'kcal': kcal,
                'shelfMonths': ROLES.get(role, ([], [], 0, 0))[2] if role in ROLES else 0,
                'image': p.get('image'),
            })
    products.sort(key=lambda p: (p['store'], p['role'], p['name']))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({'version': 1, 'count': len(products), 'products': products}, ensure_ascii=False, separators=(',', ':')))
    meta = {
        'generatedAt': datetime.now(timezone.utc).isoformat(timespec='seconds'),
        'currency': 'EUR',
        'count': len(products),
        'stores': source_meta,
        'note': 'Prices and URLs are public store observations. Pack weight, nutrition, shelf life, role and tags are estimates/retrieval hints, not safety claims.',
    }
    META.write_text(json.dumps(meta, ensure_ascii=False, indent=2))
    print(f'wrote {OUT} ({OUT.stat().st_size/1e6:.1f} MB) rows={len(products)}')
    from collections import Counter
    print(Counter(p['store'] for p in products))
    print(Counter(p['role'] for p in products).most_common(20))


if __name__ == '__main__':
    main()
