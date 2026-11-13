/// Community packing advice for the Pack screen.
///
/// These are manually paraphrased samples from public preparedness
/// communities. They are opinions, not authority, and never override LT72.
/// The source label links to the subreddit, not to an unverified thread.
/// See docs/REDDIT_RESEARCH.md for why no live scraping was used.
class AdviceItem {
  const AdviceItem({
    required this.id,
    required this.textEn,
    required this.textLt,
    required this.appliesTo,
    required this.confidence,
    required this.sourceLabel,
    required this.sourceUrl,
    this.safetyFlag = false,
  });

  final String id;
  final String textEn;
  final String textLt;
  final String appliesTo;
  final String confidence;
  final String sourceLabel;
  final String sourceUrl;
  final bool safetyFlag;

  String text(String languageCode) => languageCode == 'lt' ? textLt : textEn;
}

const List<AdviceItem> adviceItems = [
  AdviceItem(
    id: 'adv-top-load',
    textEn:
        'Put water, a headlamp and a rain layer at the top of the bag. Food and shelter go lower.',
    textLt:
        'Vandenį, žibintuvėlį ir lietaus apsaugą dėkite kuprinės viršuje. Maistas ir pastogė – žemiau.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'r/preppers',
    sourceUrl: 'https://www.reddit.com/r/preppers/',
  ),
  AdviceItem(
    id: 'adv-dry-clothes',
    textEn:
        'Pack one full change of clothes in a dry bag. Wet clothes are the fastest way to lose body heat.',
    textLt:
        'Sudėkite visą persirengimo komplektą į neperšlampamą maišą. Šlapi drabužiai greičiausiai atšaldo kūną.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'r/backpacking',
    sourceUrl: 'https://www.reddit.com/r/backpacking/',
  ),
  AdviceItem(
    id: 'adv-small-bottles',
    textEn:
        'Carry water in several small bottles instead of one heavy container. It spreads the weight and limits loss if one leaks.',
    textLt:
        'Vandenį neškite keliose mažose talpose, o ne viename sunkiame inde. Taip svoris pasiskirsto ir sumažėja nuostoliai, jei viena prateka.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'r/Ultralight',
    sourceUrl: 'https://www.reddit.com/r/Ultralight/',
  ),
  AdviceItem(
    id: 'adv-rotate',
    textEn:
        'Check the bag when you change tyres in April and November. Rotate food and test every battery.',
    textLt:
        'Tikrinkite krepšį balandį ir lapkritį, kai keičiate padangas. Pakeiskite maistą ir patikrinkite baterijas.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'LT72',
    sourceUrl: 'https://lt72.lt/isvykimo-krepsys-5/',
  ),
  AdviceItem(
    id: 'adv-child-comfort',
    textEn:
        'For a child, pack a comfort toy, a full change of clothes and a laminated contact card they can hand to an adult.',
    textLt:
        'Vaikui įdėkite mėgstamą žaislą, visą persirengimo komplektą ir laminuotą kortelę su kontaktais, kurią jis galės parodyti suaugusiajam.',
    appliesTo: 'child',
    confidence: 'high',
    sourceLabel: 'r/EmergencyPreparedness',
    sourceUrl: 'https://www.reddit.com/r/EmergencyPreparedness/',
  ),
  AdviceItem(
    id: 'adv-baby-diapers',
    textEn:
        'Pack nappies for three days plus one spare outfit per day. Formula and bottled water are heavier than they look.',
    textLt:
        'Sauskelnių užtenka trims paroms ir po vieną atsarginį komplektą kiekvienai dienai. Mišinys ir vanduo sveria daugiau, nei atrodo.',
    appliesTo: 'toddler',
    confidence: 'high',
    sourceLabel: 'r/beyondthebump',
    sourceUrl: 'https://www.reddit.com/r/beyondthebump/',
  ),
  AdviceItem(
    id: 'adv-senior-meds',
    textEn:
        'Keep a written medication list with the medicine, not only on the phone. Add the pharmacist or doctor contact.',
    textLt:
        'Laikykite rašytinį vaistų sąrašą kartu su vaistais, ne tik telefone. Įrašykite vaistininko ar gydytojo kontaktą.',
    appliesTo: 'senior',
    confidence: 'high',
    sourceLabel: 'r/AgingParents',
    sourceUrl: 'https://www.reddit.com/r/AgingParents/',
  ),
  AdviceItem(
    id: 'adv-insulin',
    textEn:
        'Insulin needs a cool pack, not a freezer. Keep it in the bag you carry, not in checked luggage.',
    textLt:
        'Insulinui reikia vėsaus, ne šaldyto, dėklo. Laikykite jį rankinėje, o ne atiduotame bagaže.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'r/diabetes',
    sourceUrl: 'https://www.reddit.com/r/diabetes/',
    safetyFlag: true,
  ),
  AdviceItem(
    id: 'adv-cash',
    textEn:
        'Pack a little cash in small notes. Card terminals and mobile networks are often the first things to fail.',
    textLt:
        'Įdėkite šiek tiek grynųjų smulkiomis kupiūromis. Kortelių terminalai ir mobilus ryšys dažniausiai sugenda pirmieji.',
    appliesTo: 'all',
    confidence: 'medium',
    sourceLabel: 'r/preppers',
    sourceUrl: 'https://www.reddit.com/r/preppers/',
  ),
  AdviceItem(
    id: 'adv-no-military',
    textEn:
        'Avoid military-looking bags and clothing. In a war, looking like a combatant is dangerous.',
    textLt:
        'Venkite kariškai atrodančių kuprinių ir drabužių. Kare atrodyti kaip kovotojas yra pavojinga.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'LT72',
    sourceUrl: 'https://lt72.lt/isvykimo-krepsys-5/',
  ),
  AdviceItem(
    id: 'adv-pet',
    textEn:
        'A pet needs its own water, bowl, food, leash and vaccination record. One adult should own that bag.',
    textLt:
        'Augintiniui reikia savo vandens, dubenėlio, maisto, pavadėlio ir skiepų pažymėjimo. Už tą krepšį turi atsakyti vienas suaugęs.',
    appliesTo: 'pet',
    confidence: 'high',
    sourceLabel: 'r/dogs',
    sourceUrl: 'https://www.reddit.com/r/dogs/',
  ),
  AdviceItem(
    id: 'adv-label',
    textEn:
        'Write every person’s name on their bag. In a shared shelter, identical black backpacks get mixed up.',
    textLt:
        'Užrašykite kiekvieno vardo ant jo kuprinės. Bendrame prieglobstyje vienodos juodos kuprinės sumaišomos.',
    appliesTo: 'all',
    confidence: 'medium',
    sourceLabel: 'r/preppers',
    sourceUrl: 'https://www.reddit.com/r/preppers/',
  ),
  AdviceItem(
    id: 'adv-variety',
    textEn:
        'Do not fill a bag with forty identical cans. Mix calories, protein and something you will actually eat under stress.',
    textLt:
        'Neprikraukite krepšio keturiasdešimčia vienodų konservų. Derinkite kalorijas, baltymus ir tai, ką tikrai valgysite streso metu.',
    appliesTo: 'all',
    confidence: 'high',
    sourceLabel: 'r/bugout',
    sourceUrl: 'https://www.reddit.com/r/bugout/',
  ),
];

AdviceItem adviceForGroup(String group) {
  final safe = adviceItems.where((item) => !item.safetyFlag);
  final match = safe.where((item) => item.appliesTo == group);
  if (match.isNotEmpty) return match.first;
  return safe.first;
}
