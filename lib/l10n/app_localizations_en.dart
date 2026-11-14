// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ready72';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageLithuanian => 'LT';

  @override
  String get welcomeTitle1 => 'Be ready.';

  @override
  String get welcomeTitle2 => 'Carry less.';

  @override
  String get welcomeBody =>
      'A 72-hour emergency bag for every person in your family, light enough to carry.';

  @override
  String get begin => 'Begin';

  @override
  String get familyTitle1 => 'Who are you';

  @override
  String get familyTitle2 => 'packing for?';

  @override
  String get nameLabel => 'Name';

  @override
  String get ageLabel => 'Age';

  @override
  String get weightLabel => 'Weight kg';

  @override
  String get namePlaceholder => 'Name';

  @override
  String get agePlaceholder => 'Age';

  @override
  String get weightPlaceholder => 'Kg';

  @override
  String get continueLabel => 'Continue';

  @override
  String get addPerson => 'Add person';

  @override
  String get removePerson => 'Remove person';

  @override
  String get nameRequired => 'Add a name.';

  @override
  String get ageInvalid => 'Age must be between 0 and 120.';

  @override
  String get weightInvalid => 'Weight must be between 2 and 300 kg.';

  @override
  String get familyHelper =>
      'Each bag is capped at what that person can carry, and lower for children and seniors.';

  @override
  String get familyEmpty => 'Add at least one person.';

  @override
  String removeNamed(String name) {
    return 'Remove: $name';
  }

  @override
  String get needsTitle1 => 'Tell us what';

  @override
  String get needsTitle2 => 'you need.';

  @override
  String get needsPlaceholder =>
      'Grandma Ona has diabetes and takes insulin. Mia is 2 and still in diapers. We have a dog.';

  @override
  String get youCanMention => 'You can mention';

  @override
  String get hintMedication => 'Medication or conditions';

  @override
  String get hintAllergies => 'Allergies or diets';

  @override
  String get hintPets => 'Pets';

  @override
  String get hintBaby => 'Baby needs';

  @override
  String get hintGlasses => 'Glasses or mobility';

  @override
  String needsClarify(String question) {
    return 'One thing to clarify: $question';
  }

  @override
  String needsParsed(int count) {
    return 'We mapped $count needs to people.';
  }

  @override
  String clarifyWho(String detail) {
    return '$detail — who is this for?';
  }

  @override
  String get condDiabetes => 'Diabetes';

  @override
  String get condInsulin => 'Insulin';

  @override
  String get condHypertension => 'Blood pressure';

  @override
  String get condAsthma => 'Asthma';

  @override
  String get condEpilepsy => 'Epilepsy';

  @override
  String get condHeart => 'Heart condition';

  @override
  String get condKidney => 'Kidney condition';

  @override
  String get condNuts => 'Nut allergy';

  @override
  String get condGluten => 'Gluten-free';

  @override
  String get condDairy => 'Dairy-free';

  @override
  String get condFish => 'Fish allergy';

  @override
  String get condEggs => 'Egg allergy';

  @override
  String get condSoy => 'Soy allergy';

  @override
  String get condVegetarian => 'Vegetarian';

  @override
  String get condVegan => 'Vegan';

  @override
  String get condPregnancy => 'Pregnancy';

  @override
  String get condBack => 'Back problem';

  @override
  String get condMobility => 'Mobility';

  @override
  String get condGlasses => 'Glasses';

  @override
  String get condBaby => 'Baby needs';

  @override
  String get condPrescribed => 'Prescribed medicine';

  @override
  String get consentTitle1 => 'Before we';

  @override
  String get consentTitle2 => 'continue.';

  @override
  String get consentBody =>
      'We use ages, weights and your description of needs to build the plan on this device. This includes health information, which is sensitive data. Nothing is sent anywhere. You can delete it at any time.';

  @override
  String get consentRequired =>
      'I agree to the processing of my data, including health information, to create my plan.';

  @override
  String get consentReminders =>
      'Send local reminders when food expires or a child outgrows clothes.';

  @override
  String get privacyNotice => 'Privacy notice';

  @override
  String get agreeAndSend => 'Agree and build';

  @override
  String get consentGateHint =>
      'Your details stay on this device. Nothing is sent.';

  @override
  String consentRecorded(String date) {
    return 'Consent recorded $date. You can withdraw it in Settings.';
  }

  @override
  String get planTitle1 => 'Choose';

  @override
  String get planTitle2 => 'your plan';

  @override
  String get comfort => 'Comfort';

  @override
  String get comfortSub => '72 hours, extra warmth';

  @override
  String get essential => 'Essential';

  @override
  String get essentialSub => '72 hours, lightest';

  @override
  String get everyBagWithin => 'Every bag within carry limit';

  @override
  String orderCta(String price) {
    return 'Order · $price';
  }

  @override
  String bagLine(String name, String weight, String limit) {
    return '$name $weight / $limit kg';
  }

  @override
  String planGaps(String gaps) {
    return 'Not covered: $gaps';
  }

  @override
  String planDropped(String items) {
    return 'Dropped to stay within weight: $items';
  }

  @override
  String get criticalCovered => 'All critical categories covered';

  @override
  String unverifiedPrices(int count) {
    return '';
  }

  @override
  String get demoCatalogue => '';

  @override
  String get reducedCapacity => 'Reduced carry limit on file';

  @override
  String get orderTitle => 'Your order';

  @override
  String get stores => 'Stores';

  @override
  String get deliveries => 'Deliveries';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get trackDelivery => 'Track delivery';

  @override
  String get keepFresh => 'Keep my bag fresh';

  @override
  String get statusOrdered => 'Ordered';

  @override
  String get statusPacked => 'Packed';

  @override
  String get statusOnTheWay => 'On the way';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get deliveryMocked => '';

  @override
  String get subscribeTitle1 => 'Keep your';

  @override
  String get subscribeTitle2 => 'bag fresh.';

  @override
  String get subscribeBody =>
      'We replace food before it expires and clothes and backpacks your children outgrow, so you never repack.';

  @override
  String get upTo14 => 'Up to 14 · new backpacks';

  @override
  String get adult => 'Adult';

  @override
  String get senior => 'Senior';

  @override
  String perMonth(String price) {
    return '$price / month';
  }

  @override
  String get total => 'Total';

  @override
  String totalPerMonth(String price) {
    return '$price / month';
  }

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get notNow => 'Not now';

  @override
  String subscribeCta(String price) {
    return 'Subscribe · $price / month';
  }

  @override
  String subscribed(String price) {
    return 'Subscription active · $price / month';
  }

  @override
  String get paymentMocked => '';

  @override
  String get packTitle => 'Pack';

  @override
  String packTitleName(String name) {
    return '$name’s bag';
  }

  @override
  String packProgress(int checked, int total, String weight, String limit) {
    return '$checked of $total · $weight / $limit kg';
  }

  @override
  String get close => 'Close';

  @override
  String get setExpiry => 'Set expiry';

  @override
  String expirySet(String date) {
    return 'Expiry $date';
  }

  @override
  String expiryReminders(String first, String second) {
    return 'Reminders $first and $second';
  }

  @override
  String nextReview(String date) {
    return 'Next review $date';
  }

  @override
  String get communityAdvice => 'Community advice';

  @override
  String get packed => 'Packed';

  @override
  String packedCount(int count) {
    return '$count packed';
  }

  @override
  String get noItems => 'No items in this bag.';

  @override
  String get privacyTitle => 'Privacy notice';

  @override
  String get privacyBody =>
      'Ready72 processes the names, ages and weights of your household, and the free-text description of needs you choose to give, to build a 72-hour bag plan. Health information is special-category data under the GDPR. We process it only with your explicit consent and only for this purpose.\n\nEverything is computed and stored on this device. There is no first-party server, no analytics about you, and no advertising. The optional AI client is not used in this build. You can withdraw consent, export your data or delete everything in one action below. Deleting removes your household, needs, plan, order, subscription and packing progress from this device.';

  @override
  String get withdrawConsent => 'Withdraw consent and delete all data';

  @override
  String get exportData => 'Export my data';

  @override
  String get dataCopied => 'Your data was copied to the clipboard.';

  @override
  String get deleteTitle => 'Delete all data?';

  @override
  String get deleteBody =>
      'This removes your household, needs, plan, order, subscription and packing progress from this device. It cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleted => 'All data deleted.';

  @override
  String get privacyLinkHint => 'Opens the privacy notice';

  @override
  String get buildingPlan => 'Building your bags…';

  @override
  String get planUnavailable => 'No plan yet. Go back and try again.';

  @override
  String get expiryHint => 'Tap ··· to set an expiry date.';

  @override
  String get itemDetails => 'Item details';

  @override
  String planDroppedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items were dropped to stay within weight.',
      one: '1 item was dropped to stay within weight.',
    );
    return '$_temp0';
  }

  @override
  String get viewDropped => 'View dropped items';

  @override
  String get droppedTitle => 'Dropped for weight';

  @override
  String get droppedWhy => 'These did not fit within any bag’s carry limit.';

  @override
  String get planIncomplete =>
      'Some essentials did not fit within the carry limits. Review the dropped items before ordering.';

  @override
  String forPerson(String name) {
    return 'For: $name';
  }

  @override
  String get aiOffline =>
      'Offline parser. It recognises common conditions, allergies, diets, pets, baby needs, glasses and mobility.';

  @override
  String get aiConnected =>
      'DeepSeek is configured. Needs will be structured after you consent.';

  @override
  String get clarifyUnsure =>
      'We could not map that text to specific needs. Add a name and what they need, or continue.';

  @override
  String get lt72Source => 'Based on the LT72 evacuation bag list (lt72.lt)';

  @override
  String get priceVerified => 'Price checked';

  @override
  String get priceUnverified => 'Catalogue estimate';

  @override
  String get viewProduct => 'Open product page';

  @override
  String get trackingTitle => 'Order tracking';

  @override
  String trackingCode(String code) {
    return 'Tracking code $code';
  }

  @override
  String get simulatedTracking => '';

  @override
  String get backToOrder => 'Back to order';

  @override
  String get ownItem => 'Your own item';

  @override
  String get waterNote =>
      'About 3 L of water per adult for 72 hours. Purification covers the rest.';

  @override
  String get validationTitle => 'Check these details';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get menu => 'Menu';

  @override
  String get catDocuments => 'Documents';

  @override
  String get catClothing => 'Clothing';

  @override
  String get catFirstAid => 'First aid';

  @override
  String get catMedication => 'Medication';

  @override
  String get catFood => 'Food';

  @override
  String get catWater => 'Water';

  @override
  String get catHygiene => 'Hygiene';

  @override
  String get catShelter => 'Shelter';

  @override
  String get catTools => 'Tools';

  @override
  String get catCommunication => 'Communication';

  @override
  String get catLight => 'Light and power';

  @override
  String get catChildren => 'Children';

  @override
  String get catPets => 'Pets';

  @override
  String get tryExample => 'Try an example family';

  @override
  String get howItWorks =>
      '1 Tell us who · 2 We fit each bag to what they can carry · 3 Order and keep it fresh';

  @override
  String get needsTrust =>
      'We map this after you agree. Everything stays on this device.';

  @override
  String get needsUnderstood => 'What we understood';

  @override
  String get needsNone => 'No specific needs — a standard bag.';

  @override
  String get planWhy => 'Every bag is capped at what that person can carry.';

  @override
  String get coverageLabel => 'LT72 coverage';

  @override
  String criticalCount(Object covered, Object total) {
    return '$covered of $total critical groups';
  }

  @override
  String get bringFromHome => 'Bring from home';

  @override
  String get bringFromHomeList =>
      'ID copies, medicine, phone, charger, keys, cash, glasses, sleeping bag and mat.';

  @override
  String get planError =>
      'We could not build a plan. Check the household details and try again.';

  @override
  String reviewOrderCta(Object price) {
    return 'Review order · $price';
  }

  @override
  String get orderTotal => 'Total';

  @override
  String placeOrder(Object price) {
    return 'Place order · $price';
  }

  @override
  String get orderPlaced => 'Order placed';

  @override
  String orderPlacedBody(Object date) {
    return 'Four deliveries. Your family is ready by $date.';
  }

  @override
  String get cancelSubscription => 'Cancel subscription';

  @override
  String get subscriptionCancelled => 'Subscription cancelled.';

  @override
  String get replacementNote =>
      'Food is swapped before it expires; children’s backpacks are replaced as they grow.';

  @override
  String packTitleWithName(Object name) {
    return '$name’s bag';
  }

  @override
  String packReady(Object name) {
    return '$name’s bag is ready.';
  }

  @override
  String get packAllDone => 'All packed. Keep it by the door.';

  @override
  String get done => 'Done';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacy => 'Privacy notice';

  @override
  String get aboutPrototype => 'About this prototype';

  @override
  String get aboutPrototypeBody =>
      'Prices combine checked Barbora listings with catalogue estimates. Deliveries, payment and tracking are simulated for the hackathon build.';

  @override
  String get homeTitle => 'Your bags';

  @override
  String get homeSubtitle => 'Ready for 72 hours.';

  @override
  String get homePlan => 'View plan';

  @override
  String get homePack => 'Pack a bag';

  @override
  String get homeOrder => 'Order status';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeRestart => 'Start over';

  @override
  String get back => 'Back';

  @override
  String get languageLabel => 'Language';

  @override
  String bagWeight(String weight, String limit) {
    return '$weight / $limit kg';
  }

  @override
  String get condLowSugar => 'Low sugar';

  @override
  String get markAll => 'Mark all packed';

  @override
  String get unpackAll => 'Unpack all';

  @override
  String get grabGo => 'Grab and go';

  @override
  String get grabGoSub => 'Everything for the next 72 hours, in one place.';

  @override
  String get emergencyTitle => 'Grab and go';

  @override
  String get emergencySub => 'If you have to leave now.';

  @override
  String get emergencyTake => 'Take these bags';

  @override
  String get emergencyHome => 'Take from home';

  @override
  String get emergencyHomeList =>
      'ID copies, medicine, phone, charger, keys, cash, glasses.';

  @override
  String get emergencyShelter => 'Find a shelter';

  @override
  String get emergencyShelterNote =>
      'Official PAGD shelter information opens in your browser.';

  @override
  String get emergencyCall => 'Call 112';

  @override
  String get emergencyNote =>
      'Do not wait for the app. If there is immediate danger, call 112.';

  @override
  String get openChecklist => 'Open printable checklist';

  @override
  String get checklistTitle => 'Checklist';

  @override
  String get checklistSub => 'Copy it, print it, or keep it offline.';

  @override
  String get copyChecklist => 'Copy checklist';

  @override
  String get checklistCopied => 'Checklist copied to the clipboard.';

  @override
  String checklistHeader(String name, String weight, String limit) {
    return 'READY72 · $name · $weight / $limit kg';
  }

  @override
  String get checklistFromHome =>
      'From home: ID copies, medicine, phone, charger, keys, cash, glasses.';

  @override
  String get shelterLink => 'Open PAGD shelter information';

  @override
  String lt72SourceCount(int count) {
    return 'Based on the $count-item LT72 list (lt72.lt)';
  }

  @override
  String get openStore => 'Open store';

  @override
  String get copyStoreList => 'Copy shopping list';

  @override
  String get storeListCopied => 'Shopping list copied.';

  @override
  String storeListHeader(String store, int count) {
    return '$store · $count items';
  }

  @override
  String get lt72List => 'See the 82-item LT72 list';

  @override
  String get lt72ListSub => 'The official list behind every plan.';

  @override
  String get lt72OpenSource => 'Open lt72.lt';

  @override
  String get lt72Supplementary => 'Supplementary';

  @override
  String get lt72Conditional => 'Conditional';

  @override
  String get lt72Critical => 'Critical';

  @override
  String get lt72Important => 'Important';

  @override
  String get lt72Comfort => 'Comfort';

  @override
  String get lt72GroupAll => 'All';

  @override
  String get lt72GroupAdult => 'Adults';

  @override
  String get lt72GroupChild => 'Children';

  @override
  String get lt72GroupSenior => 'Seniors';

  @override
  String get lt72GroupBaby => 'Baby';

  @override
  String get lt72GroupPet => 'Pets';

  @override
  String get noAdultTitle => 'No adult in this household';

  @override
  String get noAdultBody =>
      'Children cannot carry a full 72-hour load alone. Add an adult, or plan a pickup point with a wheeled carrier. The gaps below are shown honestly.';

  @override
  String get lt72Covered => 'In plan';

  @override
  String get lt72FromHome => 'From home';

  @override
  String get lt72Gap => 'Not covered';

  @override
  String lt72Summary(int covered, int home, int gaps) {
    return '$covered in plan · $home from home · $gaps gaps';
  }

  @override
  String get lt72MappingNote =>
      '“In plan” means a purchased item covers that LT72 category. “From home” is already-own gear the app does not buy.';

  @override
  String get printChecklist => 'Print / PDF';

  @override
  String get printFailed => 'Could not open the print dialog.';

  @override
  String get shelterTitle => 'Find a shelter';

  @override
  String get shelterSub =>
      'Collective protection buildings are chosen by your municipality.';

  @override
  String get shelterOfficial => 'Open the official PAGD list';

  @override
  String get shelterMap => 'Search the map near me';

  @override
  String get shelterNote =>
      'The map search is a starting point, not the official list. Confirm the building with your municipality or PAGD.';

  @override
  String get shelterCall => 'If there is immediate danger, call 112.';

  @override
  String get catalogueTitle => 'Product catalogue';

  @override
  String get catalogueBody =>
      'Real prices from public store pages. Search any item and open it at the store.';

  @override
  String get catalogueSearchHint => 'Search products';

  @override
  String get catalogueAll => 'All stores';

  @override
  String catalogueCount(int count) {
    return '$count products';
  }

  @override
  String get catalogueNoResults => 'No matching products.';

  @override
  String get catalogueAiPick => 'Ask AI to pick';

  @override
  String get catalogueAiEmpty => 'AI found nothing for this search.';

  @override
  String get catalogueSettings => 'Product catalogue';
}
