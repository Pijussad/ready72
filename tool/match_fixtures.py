#!/usr/bin/env python3
"""Match each curated fixture product to the cheapest sensible real store offer.

Output: assets/catalogue/matches.json  (fixture id -> offer snapshot).
The optimiser keeps fixture weight/calories/shelf life (safety inputs); only
price, store, title and URL come from the scraped offer. Fixtures with no
confident match are left out and stay flagged as unverified.
"""
import json, re, sys, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'assets/catalogue/products.json'
OUT = ROOT / 'assets/catalogue/matches.json'


def norm(s):
    s = unicodedata.normalize('NFKD', s.lower())
    return ''.join(c for c in s if not unicodedata.combining(c))


# id: (include regex, exclude regex, stores, lo, hi, litres)
SPARE = r'atsargin|dalis|lanko|stulpel|sagtis|dirzel|dangtel|virve|lynai|iklotas|ikrov|elektrinis|paspirtuk|dviracio|zirg|poniam|zvejyb|karpi|kd|gaubtas|remas|stogo'
S = {
 'canned-fish': (r'skumbr.*aliej', r'kepti|pomidor|garstyc', ['barbora'], 1.2, 5, None),
 'canned-meat': (r'konservuota.*jautien|troskinta jautiena', r'kates|sunu|kaciu|siuniu|ledo', ['barbora'], 1.0, 4, None),
 'canned-beans': (r'pupel.*pomidor', r'penkiu|baltosios', ['barbora'], 0.6, 3, None),
 'nut-mix': (r'riesut.*misin', r'saldyt|glaz|sokolad', ['barbora'], 1.5, 6, None),
 'crackers': (r'krekeri', r'sunu|kaciu|vaik', ['barbora'], 1.0, 4, None),
 'chocolate': (r'(juodasis|juodas).*sokolad', r'rinkin|kalend|saldain', ['barbora'], 1.2, 4, None),
 'noodles': (r'makaronai', r'sriub|kates|sunu|vaik|instant|greit', ['barbora'], 0.8, 3, None),
 'oats': (r'avizines kruopos|avizu dribsn|dribsniai', r'sunu|kaciu|vaik|zvaig', ['barbora'], 0.8, 3, None),
 'formula': (r'pieno misinys.*kudik|kudikiu.*misinys|miesinys.*kudik', r'sojos|ožk|ozk', ['barbora', 'eurovaistine'], 6, 20, None),
 'baby-food': (r'tyrel', r'sunu|kaciu|ledai', ['barbora'], 0.5, 2.5, None),
 'toddler-meal': (r'(patiekal|tyrel|koše|kose).*(1 metu|12 men|mazyl|vaikams)|nuo 1 metu|nuo 12', r'sunu|kaciu', ['barbora'], 0.8, 4, None),
 'dog-food': (r'sunu edalas|sunu eadalas|konservuotas sunu', None, ['barbora'], 0.8, 4, None),
 'cat-food': (r'kaciu edalas|konservuotas kaciu', None, ['barbora'], 0.3, 2, None),
 'dog-dry': (r'sausas sunu|sunu.*sausas|sausas.*sunu', r'skanest|kaulas', ['barbora'], 3, 12, None),
 'tea': (r'juodoji arbata|juoda arbata|juodos arbatos', r'zalioji|vaisin', ['barbora'], 1.0, 4, None),
 'water-05': (r'negazuotas.*(mineralinis|stalo|geriamasis).*vanduo|vanduo.*negazuotas', None, ['barbora'], 0.2, 1.2, 0.5),
 'water-15': (r'negazuotas.*(mineralinis|stalo|geriamasis).*vanduo|vanduo.*negazuotas', None, ['barbora'], 0.3, 1.5, 1.5),
 'water-filter': (r'(vandens|geriamojo).*filtr|filtravimo gerty|filtravimo rink', r'atsargin|keist', ['decathlon'], 8, 80, None),
 'first-aid': (r'vaistinel|pirmosios pagalbos (rinkin|vaist)', r'zirg|poni|iklot|tepal|purskal|kate|augintin', ['decathlon', 'eurovaistine', 'barbora'], 8, 40, None),
 'cpr-mask': (r'(cpr|dirbtinio kvepav|gaivinim).*(kauk|maskel)', None, ['eurovaistine', 'decathlon'], 2, 20, None),
 'plasters': (r'pleistr.*puslem|puslems.*pleistr|hidrokoloid.*pleistr', None, ['eurovaistine', 'decathlon'], 2, 15, None),
 'med-pouch': (r'vaistu (dekl|dezut|organizer)|vaistinele.*dekl|kelionine vaistin', None, ['eurovaistine', 'decathlon'], 2, 20, None),
 'toothbrush': (r'dantu.*(sepetel|pasta)', r'elektr|galv', ['barbora', 'eurovaistine'], 1.5, 8, None),
 'toilet-paper': (r'tualetinis popierius', None, ['barbora'], 1.5, 8, None),
 'towel': (r'mikropluost|mikrofibr.*ranksl', r'dviracio|valym|auto', ['decathlon'], 4, 30, None),
 'soap': (r'muilas|muilo gabal', r'skystas|dozator|kosmet|dovan|rinkin', ['barbora'], 0.8, 5, None),
 'pads': (r'higienines iklot|higieniniai paketai|paketai.*moter|iklot.*moter', r'kasdien|slaug', ['barbora', 'eurovaistine'], 1.5, 8, None),
 'rain-jacket': (r'lietaus striuk|nepraleid.*striuk|neperslampam.*striuk|nuo lietaus', r'vaik|zirg|dviraci|dviratin|' + SPARE, ['decathlon'], 15, 80, None),
 'hat-gloves': (r'(kepur|pirstin)', r'vaik|zirg|dviraci|golf|joj|bokso|vartinink|vartin|virtuv|' + SPARE, ['decathlon'], 3, 25, None),
 'spare-shoes': (r'zygio bat|turistiniai bat|tureistiniai bat', r'vaik|' + SPARE, ['decathlon'], 15, 90, None),
 'gaiter': (r'(kaklo mova|buff)', r'vaik|zirg|' + SPARE, ['decathlon'], 4, 25, None),
 'trousers': (r'(zygio|turistines|zygiu).*kelnes|kelnes.*zygi', r'vaik|zirg|dviraci|' + SPARE, ['decathlon'], 12, 70, None),
 'tent': (r'(dviviet|2 vietu|dvieju vietu).*palapin|palapin.*(dvivie|2 vietu)', r'stogo|zvejyb|karpi|atsargin|vidin|' + SPARE, ['decathlon'], 40, 250, None),
 'headlamp': (r'galvos zibint|zibint.*galv|priekinis zibintas.*galv', r'atsargin|akumuliat|dviraci|paspirtuk|' + SPARE, ['decathlon', 'barbora'], 3, 40, None),
 'whistle': (r'svilp', r'sunu|dresur|treniruot', ['decathlon'], 1, 8, None),
 'lighter': (r'ziebtuv', r'kandil|dujin.*kamin|virtuv|elektr', ['barbora'], 0.6, 5, None),
 'duct-tape': (r'(lipni juosta|izoliacin.*juosta|remonto juosta)', r'dvipus|popierin', ['decathlon', 'barbora'], 1.5, 12, None),
 'compass': (r'kompas', r'dalis', ['decathlon'], 3, 40, None),
 'notebook': (r'uzrasin|sąsiuvin|sasiuvin', None, ['barbora'], 0.8, 6, None),
 'usb-docs': (r'usb.*(laikmen|atmint)|atmintine', None, ['decathlon', 'barbora'], 4, 25, None),
 'sewing-kit': (r'siuvim.*(reikmen|rinkin|rinkinys)', None, ['barbora'], 1.5, 10, None),
 'pet-leash': (r'pavadel', r'ritin|mokymo', ['barbora'], 2, 20, None),
 'toddler-clothes': (r'kudik.*(komplek|kostium|pizam)|mazyl.*(komplek)', None, ['barbora'], 5, 25, None),
 'diapers': (r'sauskelnes.*huggies.*overnight|huggies.*overnight.*sauskelnes', None, ['barbora'], 6, 18, None),
 'child-clothes': (r'vaik.*(komplek|kostium|pizam|marskin.*kelnes)', None, ['barbora'], 8, 30, None),
 'seeds': (r'seklu misinys|seklos', r'sodinim|daigin|gele', ['barbora'], 0.6, 4, None),

 'meal-chicken': (r'ekspedic.*(vistien|ryz)|(vistien|ryz).*ekspedic|liofiliz.*(vistien|ryz)', None, ['barbora','decathlon'], 2.0, 12, None),
 'meal-veg': (r'ekspedic.*(darzov|lesi)|(darzov|lesi).*ekspedic|liofiliz.*(darzov|lesi)', None, ['barbora','decathlon'], 2.0, 12, None),
 'energy-bar': (r'baltym.*batonel|energ.*batonel|batonelis su (riesut|medum|sauliarasc)', r'sunu|kaciu|vaik|zole|zvaig|sokolad|vafl|glaz', ['barbora'], 0.8, 3, None),
 'dried-fruit': (r'dziovint.*(obuol|abrikos|slyv|razin|bananu)|(obuol|abrikos|slyv).*dziovint', r'sausain|saldain|sokolad|arbat|keks', ['barbora'], 1.0, 6, None),
 'antiseptic': (r'antisept.*(tirpal|purskal)|(tirpal|purskal).*antisept|oktenisept|vandenilio perok', r'krem|dexpanth|rank|dezinf.*rank', ['eurovaistine'], 1.5, 12, None),
 'wet-wipes': (r'dregnos servetel', r'kud|vaik|baby|akims|ausims|intym|nuvalym.*grim|dezinf', ['barbora'], 1, 6, None),
 'base-layer': (r'termo(\s|-)?apatin|termoizoliac.*marskin|apatiniai.*termo|bazinis sluoksnis', r'vaik|futbol|krepsin|' + SPARE, ['decathlon'], 6, 40, None),
 'socks': (r'kojin', r'vaik|zirg|sliduri|kompresin|puskojin|den,|kojinaite|pedkelnes', ['decathlon'], 2, 20, None),
 'underwear': (r'apatinks|apatiniai|trumpikes|boxer', r'termo|vaik|sport|kompres|sauskeln|kelnait|marskin|kojin|' + SPARE, ['barbora'], 3, 20, None),
 'backpack-adult': (r'kuprine.*(2[5-9]|[3-5]\d) ?(l|litr)|(2[5-9]|[3-5]\d) ?(l|litr).*kuprine', r'dirzel|sagtis|dviraci|vaik|zirg|dangtel|apsauga|krepsel|' + SPARE, ['decathlon'], 12, 90, None),
 'backpack-child': (r'vaik.*kuprine.*(1\d|2\d) ?(l|litr)|kuprine.*vaik.*(1\d|2\d) ?(l|litr)', r'dirzel|' + SPARE, ['decathlon', 'barbora'], 6, 40, None),
 'backpack-toddler': (r'(2.?5|mazyl).*kuprine|kuprine.*(2.?5 metu|mazyl)', r'dirzel|' + SPARE, ['decathlon'], 4, 30, None),
 'sleeping-bag': (r'miegmais', r'idekl|vaik|' + SPARE, ['decathlon'], 15, 90, None),
 'batteries': (r'(aa|lr6).*(baterij|elementai)|(baterij|elementai).*(aa|lr6)', r'aaa|a23|cr|lr44|girland', ['barbora', 'decathlon'], 3, 14, None),
 'power-bank': (r'isorine baterija|power ?bank|nesiojamas.*kroviklis', r'iphone|magsafe|automobil|biolite|' + SPARE, ['decathlon', 'barbora'], 5, 30, None),
 'radio': (r'radijas|radijo imtuvas|radijo aparat', r'budink|laikrodis|atsargin|dalis|dviraci|transliuotoj|valdom|automobil|kontrol', ['decathlon', 'barbora'], 8, 60, None),
 'paracord': (r'parakord|paracord', None, ['decathlon', 'barbora'], 2, 20, None),
 'metal-cup': (r'(metalinis|nerudijanci|titano).*puodel|puodelis.*(nerudij|metal)', r'sunu', ['decathlon'], 3, 25, None),
 'spork': (r'sakute.*saukst|saukst.*sakut|spork|stalo irankiu', None, ['decathlon'], 1.5, 15, None),
 'child-toy': (r'spalvinimo knygel|knygel', r'baterij|stalas', ['barbora'], 3, 10, None),
 'pet-bowl': (r'(dubuo|dubenel).*(augintin|sun|kat|gyvun)|sulankst.*dubuo|gyvunu dubenel', None, ['barbora', 'decathlon'], 2, 15, None),
 'peanut-butter': (r'riesutu sviest', r'sokolad|migdol', ['barbora'], 2, 8, None),
 'coffee': (r'tirpi.*kava|kava.*tirpi', r'kapsul|latte|capuccino|3in1|3 in 1|cappuc|kavos gerimas', ['barbora'], 1.5, 12, None),
 'purification': (r'vandens (valym|dezinf)|dezinf.*vand.*tablet|tablet.*(vandens|geriam)', r'vaik', ['eurovaistine', 'decathlon'], 3, 25, None),
 'tourniquet': (r'turnik|zgutas|sustabdymo juosta', None, ['eurovaistine', 'decathlon'], 4, 40, None),
 'masks': (r'ffp2|ffp3|n95', None, ['eurovaistine', 'barbora', 'decathlon'], 1.5, 20, None),
 'sanitizer': (r'(rank|rankom).*(dezinf|antisept)|dezinf.*rank|rank.*(gelis|skystis).*dezinf', r'purskiamas.*dozator|stacion|vaik', ['eurovaistine', 'barbora'], 1, 10, None),
 'emergency-blanket': (r'avarin.*(antklod|skraist)|izoliacin.*(antklod|skraist)|isgyvenim|nrc|folijos antklod', None, ['decathlon', 'eurovaistine', 'barbora'], 1, 15, None),
 'tarp': (r'palapinsiaut|tarp\b|tentas', r'zvejyb|' + SPARE, ['decathlon'], 8, 80, None),
 'usb-cable': (r'usb.?c.*(kabel|laid)|(kabel|laid).*usb.?c', None, ['decathlon', 'barbora'], 2, 20, None),
 'document-pouch': (r'(dokument).*(dekl|krepsel|maiselis|maisel)|neperslampam.*(dekl|maiselis)', r'automobil', ['decathlon', 'barbora'], 2, 25, None),
 'cooling-pouch': (r'(insulin|vaist).*(auš|aus|vesin).*(dekl|krep|maiš)|vesinimo (dekl|krep)', None, ['eurovaistine'], 8, 60, None),
 'fleece': (r'^flisas|flisas ?[„"]|flisinis (dzemper|bliuz)', r'vaik|zirg|pirstin|kepur|salik|kojin|mova|medziokl|apatinis', ['decathlon'], 8, 60, None),
 'stove': (r'turistine virykle|dujine virykle', r'sienel|zarnel|grill|dalis|atsargin|pjezo.*grill', ['decathlon'], 8, 90, None),
}


def main():
    products = json.load(open(SRC))['products']
    for p in products:
        p['_n'] = norm(p['name'])
    out = {}
    report = []
    for fid, (inc, exc, stores, lo, hi, litres) in S.items():
        cand = []
        for p in products:
            if stores and p['store'] not in stores:
                continue
            if not (lo <= p['price'] <= hi):
                continue
            if not re.search(inc, p['_n']):
                continue
            if exc and re.search(exc, p['_n']):
                continue
            if litres is not None and p.get('litres') != litres:
                continue
            cand.append(p)
        cand.sort(key=lambda p: (p['price'], p['name']))
        if not cand:
            report.append((fid, None))
            continue
        pick = cand[0]
        report.append((fid, pick, len(cand)))
        out[fid] = {
            'offerId': pick['id'],
            'store': pick['store'],
            'name': pick['name'],
            'priceEur': pick['price'],
            'url': pick['url'],
            'pack': pick.get('pack') or '',
            'scrapedFrom': 'store-catalogue',
        }
    OUT.write_text(json.dumps({'version': 1, 'matches': out}, ensure_ascii=False, indent=1))
    for r in report:
        if r[1] is None:
            print(f'MISS  {r[0]}')
        else:
            print(f'{r[0]:18} {r[1]["store"][:4]} {r[1]["price"]:>6}  {r[1]["name"][:70]}  ({r[2]})')
    print(f'\n{len(out)}/{len(S)} matched')


if __name__ == '__main__':
    main()
