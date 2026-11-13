// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appName => 'Ready72';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageLithuanian => 'LT';

  @override
  String get welcomeTitle1 => 'Pasiruoškite.';

  @override
  String get welcomeTitle2 => 'Neškite mažiau.';

  @override
  String get welcomeBody =>
      '72 valandų išvykimo krepšys kiekvienam šeimos nariui, pakankamai lengvas, kad galėtumėte nešti.';

  @override
  String get begin => 'Pradėti';

  @override
  String get familyTitle1 => 'Kam ruošiate';

  @override
  String get familyTitle2 => 'krepšius?';

  @override
  String get nameLabel => 'Vardas';

  @override
  String get ageLabel => 'Amžius';

  @override
  String get weightLabel => 'Svoris kg';

  @override
  String get namePlaceholder => 'Vardas';

  @override
  String get agePlaceholder => 'Metai';

  @override
  String get weightPlaceholder => 'Kg';

  @override
  String get continueLabel => 'Tęsti';

  @override
  String get addPerson => 'Pridėti asmenį';

  @override
  String get removePerson => 'Pašalinti asmenį';

  @override
  String get nameRequired => 'Įrašykite vardą.';

  @override
  String get ageInvalid => 'Amžius turi būti nuo 0 iki 120.';

  @override
  String get weightInvalid => 'Svoris turi būti nuo 2 iki 300 kg.';

  @override
  String get familyHelper =>
      'Kiekvieno krepšio svoris ribojamas pagal tai, ką žmogus gali nešti, o vaikams ir senjorams – dar mažesnis.';

  @override
  String get familyEmpty => 'Pridėkite bent vieną asmenį.';

  @override
  String removeNamed(String name) {
    return 'Pašalinti: $name';
  }

  @override
  String get needsTitle1 => 'Pasakykite, ko';

  @override
  String get needsTitle2 => 'jums reikia.';

  @override
  String get needsPlaceholder =>
      'Močiutei Onai diagnozuotas diabetas, ji vartoja insulį. Mia yra 2 metų, dar nešioja sauskelnes. Turime šunį.';

  @override
  String get youCanMention => 'Galite paminėti';

  @override
  String get hintMedication => 'Vaistai ar būklės';

  @override
  String get hintAllergies => 'Alergijos ar dieta';

  @override
  String get hintPets => 'Augintiniai';

  @override
  String get hintBaby => 'Kūdikio poreikiai';

  @override
  String get hintGlasses => 'Akiniai ar judėjimo sunkumai';

  @override
  String needsClarify(String question) {
    return 'Vienas patikslinimas: $question';
  }

  @override
  String needsParsed(int count) {
    return 'Poreikius priskyrėme $count asmenims.';
  }

  @override
  String clarifyWho(String detail) {
    return '$detail – kam tai?';
  }

  @override
  String get condDiabetes => 'Diabetas';

  @override
  String get condInsulin => 'Insulinas';

  @override
  String get condHypertension => 'Kraujospūdis';

  @override
  String get condAsthma => 'Astma';

  @override
  String get condEpilepsy => 'Epilepsija';

  @override
  String get condHeart => 'Širdies būklė';

  @override
  String get condKidney => 'Inkstų būklė';

  @override
  String get condNuts => 'Riešutų alergija';

  @override
  String get condGluten => 'Be glitimo';

  @override
  String get condDairy => 'Be pieno';

  @override
  String get condFish => 'Žuvies alergija';

  @override
  String get condEggs => 'Kiaušinių alergija';

  @override
  String get condSoy => 'Sojų alergija';

  @override
  String get condVegetarian => 'Vegetariška';

  @override
  String get condVegan => 'Veganiška';

  @override
  String get condPregnancy => 'Nėštumas';

  @override
  String get condBack => 'Nugaros problema';

  @override
  String get condMobility => 'Judėjimo sunkumai';

  @override
  String get condGlasses => 'Akiniai';

  @override
  String get condBaby => 'Kūdikio poreikiai';

  @override
  String get condPrescribed => 'Paskirti vaistai';

  @override
  String get consentTitle1 => 'Prieš';

  @override
  String get consentTitle2 => 'tęsdami.';

  @override
  String get consentBody =>
      'Naudojame amžių, svorį ir jūsų aprašytus poreikius planui sudaryti šiame įrenginyje. Tai apima sveikatos informaciją – jautrius duomenis. Niekas niekur nesiunčiama. Galite bet kada viską ištrinti.';

  @override
  String get consentRequired =>
      'Sutinku, kad mano duomenys, įskaitant sveikatos informaciją, būtų tvarkomi mano planui sudaryti.';

  @override
  String get consentReminders =>
      'Siųsti vietinius priminimus, kai baigiasi maisto galiojimas arba vaikas išauga drabužius.';

  @override
  String get privacyNotice => 'Privatumo pranešimas';

  @override
  String get agreeAndSend => 'Sutikti ir sukurti';

  @override
  String get consentGateHint =>
      'Duomenys lieka šiame įrenginyje. Niekas nesiunčiama.';

  @override
  String consentRecorded(String date) {
    return 'Sutikimas įrašytas $date. Galite jį atšaukti nustatymuose.';
  }

  @override
  String get planTitle1 => 'Pasirinkite';

  @override
  String get planTitle2 => 'savo planą';

  @override
  String get comfort => 'Komfortas';

  @override
  String get comfortSub => '72 valandos, daugiau šilumos';

  @override
  String get essential => 'Esminis';

  @override
  String get essentialSub => '72 valandos, lengviausias';

  @override
  String get everyBagWithin => 'Kiekvienas krepšys neviršija ribos';

  @override
  String orderCta(String price) {
    return 'Užsakyti · $price';
  }

  @override
  String bagLine(String name, String weight, String limit) {
    return '$name $weight / $limit kg';
  }

  @override
  String planGaps(String gaps) {
    return 'Nepadengta: $gaps';
  }

  @override
  String planDropped(String items) {
    return 'Pašalinta, kad tilptų: $items';
  }

  @override
  String get criticalCovered => 'Visos svarbiausios kategorijos padengtos';

  @override
  String unverifiedPrices(int count) {
    return '';
  }

  @override
  String get demoCatalogue => '';

  @override
  String get reducedCapacity => 'Įrašyta sumažinta nešimo riba';

  @override
  String get orderTitle => 'Jūsų užsakymas';

  @override
  String get stores => 'Parduotuvės';

  @override
  String get deliveries => 'Pristatymai';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prekės',
      many: '$count prekių',
      few: '$count prekės',
      one: '1 prekė',
    );
    return '$_temp0';
  }

  @override
  String get trackDelivery => 'Sekti pristatymą';

  @override
  String get keepFresh => 'Išlaikyti krepšį šviežią';

  @override
  String get statusOrdered => 'Užsakytas';

  @override
  String get statusPacked => 'Supakuotas';

  @override
  String get statusOnTheWay => 'Pakeliui';

  @override
  String get statusDelivered => 'Pristatytas';

  @override
  String get deliveryMocked => '';

  @override
  String get subscribeTitle1 => 'Išlaikykite';

  @override
  String get subscribeTitle2 => 'krepšį šviežią.';

  @override
  String get subscribeBody =>
      'Pakeisime maistą nepasibaigus galiojimui, o vaikų išaugtus drabužius ir kuprines – kad niekada netektų perrinkti.';

  @override
  String get upTo14 => 'Iki 14 m. · naujos kuprinės';

  @override
  String get adult => 'Suaugusio amžiaus';

  @override
  String get senior => 'Senjoro amžiaus';

  @override
  String perMonth(String price) {
    return '$price / mėn.';
  }

  @override
  String get total => 'Iš viso';

  @override
  String totalPerMonth(String price) {
    return '$price / mėn.';
  }

  @override
  String get cancelAnytime => 'Atšaukti galima bet kada';

  @override
  String get notNow => 'Ne dabar';

  @override
  String subscribeCta(String price) {
    return 'Prenumeruoti · $price / mėn.';
  }

  @override
  String subscribed(String price) {
    return 'Prenumerata aktyvi · $price / mėn.';
  }

  @override
  String get paymentMocked => '';

  @override
  String get packTitle => 'Krepšys';

  @override
  String packTitleName(String name) {
    return 'Krepšys · $name';
  }

  @override
  String packProgress(int checked, int total, String weight, String limit) {
    return '$checked iš $total · $weight / $limit kg';
  }

  @override
  String get close => 'Uždaryti';

  @override
  String get setExpiry => 'Nustatyti galiojimą';

  @override
  String expirySet(String date) {
    return 'Galioja iki $date';
  }

  @override
  String expiryReminders(String first, String second) {
    return 'Priminimai $first ir $second';
  }

  @override
  String nextReview(String date) {
    return 'Kita peržiūra $date';
  }

  @override
  String get communityAdvice => 'Bendruomenės patarimas';

  @override
  String get packed => 'Sudėta';

  @override
  String packedCount(int count) {
    return 'Sudėta $count';
  }

  @override
  String get noItems => 'Šiame krepšyje nėra daiktų.';

  @override
  String get privacyTitle => 'Privatumo pranešimas';

  @override
  String get privacyBody =>
      'Ready72 tvarko jūsų šeimos narių vardus, amžių ir svorį bei jūsų pateiktą laisvo teksto poreikių aprašymą, kad sudarytų 72 valandų krepšio planą. Sveikatos informacija pagal BDAR yra specialių kategorijų duomenys. Ją tvarkome tik gavę jūsų aiškų sutikimą ir tik šiam tikslui.\n\nViskas apskaičiuojama ir saugoma šiame įrenginyje. Neturime serverio, jokios analitikos apie jus ir jokios reklamos. Pasirenkamas AI klientas šiame leidime nenaudojamas. Žemiau galite atšaukti sutikimą, eksportuoti duomenis arba viską ištrinti vienu veiksmu. Ištrynus bus pašalinti šeima, poreikiai, planas, užsakymas, prenumerata ir pakavimo eiga iš šio įrenginio.';

  @override
  String get withdrawConsent => 'Atšaukti sutikimą ir ištrinti visus duomenis';

  @override
  String get exportData => 'Eksportuoti mano duomenis';

  @override
  String get dataCopied => 'Duomenys nukopijuoti į iškarpinę.';

  @override
  String get deleteTitle => 'Ištrinti visus duomenis?';

  @override
  String get deleteBody =>
      'Iš šio įrenginio bus pašalinti šeima, poreikiai, planas, užsakymas, prenumerata ir pakavimo eiga. Atšaukti negalėsite.';

  @override
  String get delete => 'Ištrinti';

  @override
  String get cancel => 'Atšaukti';

  @override
  String get deleted => 'Visi duomenys ištrinti.';

  @override
  String get privacyLinkHint => 'Atidaro privatumo pranešimą';

  @override
  String get buildingPlan => 'Sudaromi krepšiai…';

  @override
  String get planUnavailable =>
      'Plano dar nėra. Grįžkite ir bandykite dar kartą.';

  @override
  String get expiryHint => 'Bakstelėkite ··· ir nustatykite galiojimą.';

  @override
  String get itemDetails => 'Daikto informacija';

  @override
  String planDroppedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count daiktai pašalinti, kad tilptų.',
      many: '$count daiktų pašalinta, kad tilptų.',
      few: '$count daiktai pašalinti, kad tilptų.',
      one: '1 daiktas pašalintas, kad tilptų.',
    );
    return '$_temp0';
  }

  @override
  String get viewDropped => 'Peržiūrėti pašalintus daiktus';

  @override
  String get droppedTitle => 'Pašalinta dėl svorio';

  @override
  String get droppedWhy => 'Šie daiktai netilpo į jokio krepšio nešimo ribą.';

  @override
  String get planIncomplete =>
      'Kai kurie būtiniausi daiktai netilpo į nešimo ribas. Prieš užsakydami peržiūrėkite pašalintus daiktus.';

  @override
  String forPerson(String name) {
    return 'Skirta: $name';
  }

  @override
  String get aiOffline =>
      'Neprisijungęs analizatorius. Jis atpažįsta įprastas būklės, alergijas, dietas, augintinius, kūdikio poreikius, akinius ir judėjimą.';

  @override
  String get aiConnected =>
      'DeepSeek sukonfigūruotas. Poreikiai bus susisteminti po sutikimo.';

  @override
  String get clarifyUnsure =>
      'Nepavyko priskirti teksto konkretiems poreikiams. Įrašykite vardą ir nurodykite, ko reikia, arba tęskite.';

  @override
  String get lt72Source => 'Pagal LT72 išvykimo krepšio sąrašą (lt72.lt)';

  @override
  String get priceVerified => 'Kaina patikrinta';

  @override
  String get priceUnverified => 'Katalogo įvertis';

  @override
  String get viewProduct => 'Atidaryti prekę';

  @override
  String get trackingTitle => 'Užsakymo sekimas';

  @override
  String trackingCode(String code) {
    return 'Sekimo kodas $code';
  }

  @override
  String get simulatedTracking => '';

  @override
  String get backToOrder => 'Grįžti į užsakymą';

  @override
  String get ownItem => 'Jūsų daiktas';

  @override
  String get waterNote =>
      'Vienam suaugusiam asmeniui 72 val. reikia apie 3 l vandens. Likusiam vandeniui – valymo priemonės.';

  @override
  String get validationTitle => 'Patikrinkite duomenis';

  @override
  String get genericError => 'Įvyko klaida. Bandykite dar kartą.';

  @override
  String get menu => 'Meniu';

  @override
  String get catDocuments => 'Dokumentai';

  @override
  String get catClothing => 'Drabužiai';

  @override
  String get catFirstAid => 'Pirmoji pagalba';

  @override
  String get catMedication => 'Vaistai';

  @override
  String get catFood => 'Maistas';

  @override
  String get catWater => 'Vanduo';

  @override
  String get catHygiene => 'Higiena';

  @override
  String get catShelter => 'Pastogė';

  @override
  String get catTools => 'Įrankiai';

  @override
  String get catCommunication => 'Ryšys';

  @override
  String get catLight => 'Šviesa ir energija';

  @override
  String get catChildren => 'Vaikams';

  @override
  String get catPets => 'Augintiniams';

  @override
  String get tryExample => 'Išbandyti pavyzdinę šeimą';

  @override
  String get howItWorks =>
      '1 Pasakykite, kam · 2 Kiekvieną krepšį pritaikome pagal tai, ką žmogus gali nešti · 3 Užsisakykite ir išlaikykite šviežią';

  @override
  String get needsTrust =>
      'Poreikius susisteminsime po sutikimo. Viskas lieka šiame įrenginyje.';

  @override
  String get needsUnderstood => 'Ką supratome';

  @override
  String get needsNone => 'Konkrečių poreikių nėra – standartinis krepšys.';

  @override
  String get planWhy =>
      'Kiekvienas krepšys ribojamas pagal tai, ką žmogus gali nešti.';

  @override
  String get coverageLabel => 'LT72 padengimas';

  @override
  String criticalCount(Object covered, Object total) {
    return '$covered iš $total svarbiausių grupių';
  }

  @override
  String get bringFromHome => 'Pasiimkite iš namų';

  @override
  String get bringFromHomeList =>
      'Dokumentų kopijos, vaistai, telefonas, įkroviklis, raktai, pinigai, akiniai, miegmaišis ir kilimėlis.';

  @override
  String get planError =>
      'Plano sudaryti nepavyko. Patikrinkite šeimos duomenis ir bandykite dar kartą.';

  @override
  String reviewOrderCta(Object price) {
    return 'Peržiūrėti užsakymą · $price';
  }

  @override
  String get orderTotal => 'Iš viso';

  @override
  String placeOrder(Object price) {
    return 'Užsakyti · $price';
  }

  @override
  String get orderPlaced => 'Užsakymas pateiktas';

  @override
  String orderPlacedBody(Object date) {
    return 'Keturi pristatymai. Jūsų šeima bus pasiruošusi iki $date.';
  }

  @override
  String get cancelSubscription => 'Atšaukti prenumeratą';

  @override
  String get subscriptionCancelled => 'Prenumerata atšaukta.';

  @override
  String get replacementNote =>
      'Maistas pakeičiamas nepasibaigus galiojimui; vaikų kuprinės – kai vaikai jas išauga.';

  @override
  String packTitleWithName(Object name) {
    return 'Krepšys · $name';
  }

  @override
  String packReady(Object name) {
    return 'Krepšys paruoštas: $name.';
  }

  @override
  String get packAllDone => 'Viskas supakuota. Laikykite prie durų.';

  @override
  String get done => 'Atlikta';

  @override
  String get settingsTitle => 'Nustatymai';

  @override
  String get settingsPrivacy => 'Privatumo pranešimas';

  @override
  String get aboutPrototype => 'Apie šį prototipą';

  @override
  String get aboutPrototypeBody =>
      'Kainos pagrįstos patikrintais „Barbora“ sąrašais ir katalogo įverčiais. Pristatymas, mokėjimas ir sekimas šiame hakatono leidime imituojami.';

  @override
  String get homeTitle => 'Jūsų krepšiai';

  @override
  String get homeSubtitle => 'Pasiruošę 72 valandoms.';

  @override
  String get homePlan => 'Peržiūrėti planą';

  @override
  String get homePack => 'Pakuoti krepšį';

  @override
  String get homeOrder => 'Užsakymo būsena';

  @override
  String get homeSettings => 'Nustatymai';

  @override
  String get homeRestart => 'Pradėti iš naujo';

  @override
  String get back => 'Atgal';

  @override
  String get languageLabel => 'Kalba';

  @override
  String bagWeight(String weight, String limit) {
    return '$weight / $limit kg';
  }

  @override
  String get condLowSugar => 'Mažai cukraus';

  @override
  String get markAll => 'Pažymėti viską kaip supakuotą';

  @override
  String get unpackAll => 'Išpakuoti viską';

  @override
  String get grabGo => 'Imkite ir eikite';

  @override
  String get grabGoSub => 'Viskas artimiausioms 72 valandoms vienoje vietoje.';

  @override
  String get emergencyTitle => 'Imkite ir eikite';

  @override
  String get emergencySub => 'Jei reikia išvykti dabar pat.';

  @override
  String get emergencyTake => 'Pasiimkite šiuos krepšius';

  @override
  String get emergencyHome => 'Pasiimkite iš namų';

  @override
  String get emergencyHomeList =>
      'Dokumentų kopijos, vaistai, telefonas, įkroviklis, raktai, pinigai, akiniai.';

  @override
  String get emergencyShelter => 'Rasti priedangą';

  @override
  String get emergencyShelterNote =>
      'Oficiali PAGD informacija apie priedangas atsidarys naršyklėje.';

  @override
  String get emergencyCall => 'Skambinti 112';

  @override
  String get emergencyNote =>
      'Nelaukite programėlės. Jei gresia pavojus, skambinkite 112.';

  @override
  String get openChecklist => 'Atidaryti spausdinamą sąrašą';

  @override
  String get checklistTitle => 'Sąrašas';

  @override
  String get checklistSub =>
      'Nukopijuokite, atsispausdinkite arba naudokitės neprisijungę.';

  @override
  String get copyChecklist => 'Kopijuoti sąrašą';

  @override
  String get checklistCopied => 'Sąrašas nukopijuotas į iškarpinę.';

  @override
  String checklistHeader(String name, String weight, String limit) {
    return 'READY72 · $name · $weight / $limit kg';
  }

  @override
  String get checklistFromHome =>
      'Iš namų: dokumentų kopijos, vaistai, telefonas, įkroviklis, raktai, pinigai, akiniai.';

  @override
  String get shelterLink => 'Atidaryti PAGD informaciją apie priedangas';

  @override
  String lt72SourceCount(int count) {
    return 'Pagal $count punktų LT72 sąrašą (lt72.lt)';
  }

  @override
  String get openStore => 'Atidaryti parduotuvę';

  @override
  String get copyStoreList => 'Kopijuoti pirkinių sąrašą';

  @override
  String get storeListCopied => 'Pirkinių sąrašas nukopijuotas.';

  @override
  String storeListHeader(String store, int count) {
    return '$store · $count prekės';
  }

  @override
  String get lt72List => 'Peržiūrėti 82 punktų LT72 sąrašą';

  @override
  String get lt72ListSub =>
      'Oficialus sąrašas, kuriuo grindžiamas kiekvienas planas.';

  @override
  String get lt72OpenSource => 'Atidaryti lt72.lt';

  @override
  String get lt72Supplementary => 'Papildoma';

  @override
  String get lt72Conditional => 'Sąlyginė';

  @override
  String get lt72Critical => 'Būtina';

  @override
  String get lt72Important => 'Svarbu';

  @override
  String get lt72Comfort => 'Komfortas';

  @override
  String get lt72GroupAll => 'Visiems';

  @override
  String get lt72GroupAdult => 'Suaugusiesiems';

  @override
  String get lt72GroupChild => 'Vaikams';

  @override
  String get lt72GroupSenior => 'Senjorams';

  @override
  String get lt72GroupBaby => 'Kūdikiui';

  @override
  String get lt72GroupPet => 'Augintiniams';

  @override
  String get noAdultTitle => 'Šioje šeimoje nėra suaugusio asmens';

  @override
  String get noAdultBody =>
      'Vaikai negali patys nešti viso 72 valandų krovinio. Pridėkite suaugusį asmenį arba suplanuokite atsiėmimo punktą su vežimėliu. Trūkumai rodomi sąžiningai.';

  @override
  String get lt72Covered => 'Plane';

  @override
  String get lt72FromHome => 'Iš namų';

  @override
  String get lt72Gap => 'Nepadengta';

  @override
  String lt72Summary(int covered, int home, int gaps) {
    return '$covered plane · $home iš namų · $gaps trūkumai';
  }

  @override
  String get lt72MappingNote =>
      '„Plane“ reiškia, kad tą LT72 kategoriją padengia perkama prekė. „Iš namų“ – jau turimi daiktai, kurių programa neperka.';

  @override
  String get printChecklist => 'Spausdinti / PDF';

  @override
  String get printFailed => 'Nepavyko atidaryti spausdinimo dialogo.';

  @override
  String get shelterTitle => 'Rasti priedangą';

  @override
  String get shelterSub =>
      'Kolektyvinės apsaugos statinius parenka savivaldybė.';

  @override
  String get shelterOfficial => 'Atidaryti oficialų PAGD sąrašą';

  @override
  String get shelterMap => 'Ieškoti žemėlapyje netoliese';

  @override
  String get shelterNote =>
      'Paieška žemėlapyje yra tik atspirties taškas, ne oficialus sąrašas. Pastatą patvirtinkite savivaldybėje arba PAGD.';

  @override
  String get shelterCall => 'Jei gresia tiesioginis pavojus, skambinkite 112.';
}
