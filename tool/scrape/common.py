import json, re, time, hashlib, os, sys
from pathlib import Path
import requests

ROOT = Path(__file__).resolve().parents[2]
CACHE = ROOT / '.cache' / 'scrape'
CACHE.mkdir(parents=True, exist_ok=True)
UA = 'Ready72-research/1.0 (+https://github.com/Pijussad/ready72; demo@ready72.lt)'
HEADERS = {'User-Agent': UA, 'Accept-Language': 'lt-LT,lt;q=0.9,en;q=0.8'}

def fetch(url, *, sleep=1.0, timeout=40):
    key = hashlib.sha256(url.encode()).hexdigest()[:24]
    path = CACHE / f'{key}.html'
    if path.exists() and path.stat().st_size > 50_000:
        return path.read_text(errors='replace')
    if path.exists():
        path.unlink()
    r = requests.get(url, headers=HEADERS, timeout=timeout)
    r.raise_for_status()
    path.write_text(r.text)
    time.sleep(sleep)
    return r.text

def remix(html):
    m = re.search(r'window\.__remixContext = (\{.*?\});</script>', html, re.S)
    if not m:
        raise ValueError('no remix context')
    return json.loads(m.group(1))

def category_data(html):
    if len(html) < 50_000:
        return None
    d = remix(html)
    for v in d.get('state', {}).get('loaderData', {}).values():
        try:
            q = v['dehydratedState']['queries'][0]['state']['data']
        except Exception:
            continue
        if isinstance(q, dict) and 'inventories' in q:
            return q
    return None
