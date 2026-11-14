import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lt'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ready72'**
  String get appName;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @languageLithuanian.
  ///
  /// In en, this message translates to:
  /// **'LT'**
  String get languageLithuanian;

  /// No description provided for @welcomeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Be ready.'**
  String get welcomeTitle1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In en, this message translates to:
  /// **'Carry less.'**
  String get welcomeTitle2;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A 72-hour emergency bag for every person in your family, light enough to carry.'**
  String get welcomeBody;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @familyTitle1.
  ///
  /// In en, this message translates to:
  /// **'Who are you'**
  String get familyTitle1;

  /// No description provided for @familyTitle2.
  ///
  /// In en, this message translates to:
  /// **'packing for?'**
  String get familyTitle2;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight kg'**
  String get weightLabel;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get namePlaceholder;

  /// No description provided for @agePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get agePlaceholder;

  /// No description provided for @weightPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Kg'**
  String get weightPlaceholder;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @removePerson.
  ///
  /// In en, this message translates to:
  /// **'Remove person'**
  String get removePerson;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a name.'**
  String get nameRequired;

  /// No description provided for @ageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 0 and 120.'**
  String get ageInvalid;

  /// No description provided for @weightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 2 and 300 kg.'**
  String get weightInvalid;

  /// No description provided for @familyHelper.
  ///
  /// In en, this message translates to:
  /// **'Each bag is capped at what that person can carry, and lower for children and seniors.'**
  String get familyHelper;

  /// No description provided for @familyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least one person.'**
  String get familyEmpty;

  /// No description provided for @removeNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove: {name}'**
  String removeNamed(String name);

  /// No description provided for @needsTitle1.
  ///
  /// In en, this message translates to:
  /// **'Tell us what'**
  String get needsTitle1;

  /// No description provided for @needsTitle2.
  ///
  /// In en, this message translates to:
  /// **'you need.'**
  String get needsTitle2;

  /// No description provided for @needsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Grandma Ona has diabetes and takes insulin. Mia is 2 and still in diapers. We have a dog.'**
  String get needsPlaceholder;

  /// No description provided for @youCanMention.
  ///
  /// In en, this message translates to:
  /// **'You can mention'**
  String get youCanMention;

  /// No description provided for @hintMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication or conditions'**
  String get hintMedication;

  /// No description provided for @hintAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies or diets'**
  String get hintAllergies;

  /// No description provided for @hintPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get hintPets;

  /// No description provided for @hintBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby needs'**
  String get hintBaby;

  /// No description provided for @hintGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses or mobility'**
  String get hintGlasses;

  /// No description provided for @needsClarify.
  ///
  /// In en, this message translates to:
  /// **'One thing to clarify: {question}'**
  String needsClarify(String question);

  /// No description provided for @needsParsed.
  ///
  /// In en, this message translates to:
  /// **'We mapped {count} needs to people.'**
  String needsParsed(int count);

  /// No description provided for @clarifyWho.
  ///
  /// In en, this message translates to:
  /// **'{detail} — who is this for?'**
  String clarifyWho(String detail);

  /// No description provided for @condDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get condDiabetes;

  /// No description provided for @condInsulin.
  ///
  /// In en, this message translates to:
  /// **'Insulin'**
  String get condInsulin;

  /// No description provided for @condHypertension.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get condHypertension;

  /// No description provided for @condAsthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get condAsthma;

  /// No description provided for @condEpilepsy.
  ///
  /// In en, this message translates to:
  /// **'Epilepsy'**
  String get condEpilepsy;

  /// No description provided for @condHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart condition'**
  String get condHeart;

  /// No description provided for @condKidney.
  ///
  /// In en, this message translates to:
  /// **'Kidney condition'**
  String get condKidney;

  /// No description provided for @condNuts.
  ///
  /// In en, this message translates to:
  /// **'Nut allergy'**
  String get condNuts;

  /// No description provided for @condGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get condGluten;

  /// No description provided for @condDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy-free'**
  String get condDairy;

  /// No description provided for @condFish.
  ///
  /// In en, this message translates to:
  /// **'Fish allergy'**
  String get condFish;

  /// No description provided for @condEggs.
  ///
  /// In en, this message translates to:
  /// **'Egg allergy'**
  String get condEggs;

  /// No description provided for @condSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy allergy'**
  String get condSoy;

  /// No description provided for @condVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get condVegetarian;

  /// No description provided for @condVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get condVegan;

  /// No description provided for @condPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get condPregnancy;

  /// No description provided for @condBack.
  ///
  /// In en, this message translates to:
  /// **'Back problem'**
  String get condBack;

  /// No description provided for @condMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get condMobility;

  /// No description provided for @condGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get condGlasses;

  /// No description provided for @condBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby needs'**
  String get condBaby;

  /// No description provided for @condPrescribed.
  ///
  /// In en, this message translates to:
  /// **'Prescribed medicine'**
  String get condPrescribed;

  /// No description provided for @consentTitle1.
  ///
  /// In en, this message translates to:
  /// **'Before we'**
  String get consentTitle1;

  /// No description provided for @consentTitle2.
  ///
  /// In en, this message translates to:
  /// **'continue.'**
  String get consentTitle2;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'We use ages, weights and your description of needs to build the plan on this device. This includes health information, which is sensitive data. Nothing is sent anywhere. You can delete it at any time.'**
  String get consentBody;

  /// No description provided for @consentRequired.
  ///
  /// In en, this message translates to:
  /// **'I agree to the processing of my data, including health information, to create my plan.'**
  String get consentRequired;

  /// No description provided for @consentReminders.
  ///
  /// In en, this message translates to:
  /// **'Send local reminders when food expires or a child outgrows clothes.'**
  String get consentReminders;

  /// No description provided for @privacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacyNotice;

  /// No description provided for @agreeAndSend.
  ///
  /// In en, this message translates to:
  /// **'Agree and build'**
  String get agreeAndSend;

  /// No description provided for @consentGateHint.
  ///
  /// In en, this message translates to:
  /// **'Your details stay on this device. Nothing is sent.'**
  String get consentGateHint;

  /// No description provided for @consentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Consent recorded {date}. You can withdraw it in Settings.'**
  String consentRecorded(String date);

  /// No description provided for @planTitle1.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get planTitle1;

  /// No description provided for @planTitle2.
  ///
  /// In en, this message translates to:
  /// **'your plan'**
  String get planTitle2;

  /// No description provided for @comfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get comfort;

  /// No description provided for @comfortSub.
  ///
  /// In en, this message translates to:
  /// **'72 hours, extra warmth'**
  String get comfortSub;

  /// No description provided for @essential.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get essential;

  /// No description provided for @essentialSub.
  ///
  /// In en, this message translates to:
  /// **'72 hours, lightest'**
  String get essentialSub;

  /// No description provided for @everyBagWithin.
  ///
  /// In en, this message translates to:
  /// **'Every bag within carry limit'**
  String get everyBagWithin;

  /// No description provided for @orderCta.
  ///
  /// In en, this message translates to:
  /// **'Order · {price}'**
  String orderCta(String price);

  /// No description provided for @bagLine.
  ///
  /// In en, this message translates to:
  /// **'{name} {weight} / {limit} kg'**
  String bagLine(String name, String weight, String limit);

  /// No description provided for @planGaps.
  ///
  /// In en, this message translates to:
  /// **'Not covered: {gaps}'**
  String planGaps(String gaps);

  /// No description provided for @planDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped to stay within weight: {items}'**
  String planDropped(String items);

  /// No description provided for @criticalCovered.
  ///
  /// In en, this message translates to:
  /// **'All critical categories covered'**
  String get criticalCovered;

  /// No description provided for @unverifiedPrices.
  ///
  /// In en, this message translates to:
  /// **''**
  String unverifiedPrices(int count);

  /// No description provided for @demoCatalogue.
  ///
  /// In en, this message translates to:
  /// **''**
  String get demoCatalogue;

  /// No description provided for @reducedCapacity.
  ///
  /// In en, this message translates to:
  /// **'Reduced carry limit on file'**
  String get reducedCapacity;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get orderTitle;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @trackDelivery.
  ///
  /// In en, this message translates to:
  /// **'Track delivery'**
  String get trackDelivery;

  /// No description provided for @keepFresh.
  ///
  /// In en, this message translates to:
  /// **'Keep my bag fresh'**
  String get keepFresh;

  /// No description provided for @statusOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get statusOrdered;

  /// No description provided for @statusPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get statusPacked;

  /// No description provided for @statusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get statusOnTheWay;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @deliveryMocked.
  ///
  /// In en, this message translates to:
  /// **''**
  String get deliveryMocked;

  /// No description provided for @subscribeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Keep your'**
  String get subscribeTitle1;

  /// No description provided for @subscribeTitle2.
  ///
  /// In en, this message translates to:
  /// **'bag fresh.'**
  String get subscribeTitle2;

  /// No description provided for @subscribeBody.
  ///
  /// In en, this message translates to:
  /// **'We replace food before it expires and clothes and backpacks your children outgrow, so you never repack.'**
  String get subscribeBody;

  /// No description provided for @upTo14.
  ///
  /// In en, this message translates to:
  /// **'Up to 14 · new backpacks'**
  String get upTo14;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @senior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get senior;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String perMonth(String price);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String totalPerMonth(String price);

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @subscribeCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe · {price} / month'**
  String subscribeCta(String price);

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscription active · {price} / month'**
  String subscribed(String price);

  /// No description provided for @paymentMocked.
  ///
  /// In en, this message translates to:
  /// **''**
  String get paymentMocked;

  /// No description provided for @packTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get packTitle;

  /// No description provided for @packTitleName.
  ///
  /// In en, this message translates to:
  /// **'{name}’s bag'**
  String packTitleName(String name);

  /// No description provided for @packProgress.
  ///
  /// In en, this message translates to:
  /// **'{checked} of {total} · {weight} / {limit} kg'**
  String packProgress(int checked, int total, String weight, String limit);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @setExpiry.
  ///
  /// In en, this message translates to:
  /// **'Set expiry'**
  String get setExpiry;

  /// No description provided for @expirySet.
  ///
  /// In en, this message translates to:
  /// **'Expiry {date}'**
  String expirySet(String date);

  /// No description provided for @expiryReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders {first} and {second}'**
  String expiryReminders(String first, String second);

  /// No description provided for @nextReview.
  ///
  /// In en, this message translates to:
  /// **'Next review {date}'**
  String nextReview(String date);

  /// No description provided for @communityAdvice.
  ///
  /// In en, this message translates to:
  /// **'Community advice'**
  String get communityAdvice;

  /// No description provided for @packed.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get packed;

  /// No description provided for @packedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} packed'**
  String packedCount(int count);

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items in this bag.'**
  String get noItems;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Ready72 processes the names, ages and weights of your household, and the free-text description of needs you choose to give, to build a 72-hour bag plan. Health information is special-category data under the GDPR. We process it only with your explicit consent and only for this purpose.\n\nEverything is computed and stored on this device. There is no first-party server, no analytics about you, and no advertising. The optional AI client is not used in this build. You can withdraw consent, export your data or delete everything in one action below. Deleting removes your household, needs, plan, order, subscription and packing progress from this device.'**
  String get privacyBody;

  /// No description provided for @withdrawConsent.
  ///
  /// In en, this message translates to:
  /// **'Withdraw consent and delete all data'**
  String get withdrawConsent;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @dataCopied.
  ///
  /// In en, this message translates to:
  /// **'Your data was copied to the clipboard.'**
  String get dataCopied;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes your household, needs, plan, order, subscription and packing progress from this device. It cannot be undone.'**
  String get deleteBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted.'**
  String get deleted;

  /// No description provided for @privacyLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the privacy notice'**
  String get privacyLinkHint;

  /// No description provided for @buildingPlan.
  ///
  /// In en, this message translates to:
  /// **'Building your bags…'**
  String get buildingPlan;

  /// No description provided for @planUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No plan yet. Go back and try again.'**
  String get planUnavailable;

  /// No description provided for @expiryHint.
  ///
  /// In en, this message translates to:
  /// **'Tap ··· to set an expiry date.'**
  String get expiryHint;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item details'**
  String get itemDetails;

  /// No description provided for @planDroppedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item was dropped to stay within weight.} other{{count} items were dropped to stay within weight.}}'**
  String planDroppedCount(num count);

  /// No description provided for @viewDropped.
  ///
  /// In en, this message translates to:
  /// **'View dropped items'**
  String get viewDropped;

  /// No description provided for @droppedTitle.
  ///
  /// In en, this message translates to:
  /// **'Dropped for weight'**
  String get droppedTitle;

  /// No description provided for @droppedWhy.
  ///
  /// In en, this message translates to:
  /// **'These did not fit within any bag’s carry limit.'**
  String get droppedWhy;

  /// No description provided for @planIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Some essentials did not fit within the carry limits. Review the dropped items before ordering.'**
  String get planIncomplete;

  /// No description provided for @forPerson.
  ///
  /// In en, this message translates to:
  /// **'For: {name}'**
  String forPerson(String name);

  /// No description provided for @aiOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline parser. It recognises common conditions, allergies, diets, pets, baby needs, glasses and mobility.'**
  String get aiOffline;

  /// No description provided for @aiConnected.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek is configured. Needs will be structured after you consent.'**
  String get aiConnected;

  /// No description provided for @clarifyUnsure.
  ///
  /// In en, this message translates to:
  /// **'We could not map that text to specific needs. Add a name and what they need, or continue.'**
  String get clarifyUnsure;

  /// No description provided for @lt72Source.
  ///
  /// In en, this message translates to:
  /// **'Based on the LT72 evacuation bag list (lt72.lt)'**
  String get lt72Source;

  /// No description provided for @priceVerified.
  ///
  /// In en, this message translates to:
  /// **'Price checked'**
  String get priceVerified;

  /// No description provided for @priceUnverified.
  ///
  /// In en, this message translates to:
  /// **'Catalogue estimate'**
  String get priceUnverified;

  /// No description provided for @viewProduct.
  ///
  /// In en, this message translates to:
  /// **'Open product page'**
  String get viewProduct;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Order tracking'**
  String get trackingTitle;

  /// No description provided for @trackingCode.
  ///
  /// In en, this message translates to:
  /// **'Tracking code {code}'**
  String trackingCode(String code);

  /// No description provided for @simulatedTracking.
  ///
  /// In en, this message translates to:
  /// **''**
  String get simulatedTracking;

  /// No description provided for @backToOrder.
  ///
  /// In en, this message translates to:
  /// **'Back to order'**
  String get backToOrder;

  /// No description provided for @ownItem.
  ///
  /// In en, this message translates to:
  /// **'Your own item'**
  String get ownItem;

  /// No description provided for @waterNote.
  ///
  /// In en, this message translates to:
  /// **'About 3 L of water per adult for 72 hours. Purification covers the rest.'**
  String get waterNote;

  /// No description provided for @validationTitle.
  ///
  /// In en, this message translates to:
  /// **'Check these details'**
  String get validationTitle;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @catDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get catDocuments;

  /// No description provided for @catClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get catClothing;

  /// No description provided for @catFirstAid.
  ///
  /// In en, this message translates to:
  /// **'First aid'**
  String get catFirstAid;

  /// No description provided for @catMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get catMedication;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @catHygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get catHygiene;

  /// No description provided for @catShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter'**
  String get catShelter;

  /// No description provided for @catTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get catTools;

  /// No description provided for @catCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get catCommunication;

  /// No description provided for @catLight.
  ///
  /// In en, this message translates to:
  /// **'Light and power'**
  String get catLight;

  /// No description provided for @catChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get catChildren;

  /// No description provided for @catPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get catPets;

  /// No description provided for @tryExample.
  ///
  /// In en, this message translates to:
  /// **'Try an example family'**
  String get tryExample;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'1 Tell us who · 2 We fit each bag to what they can carry · 3 Order and keep it fresh'**
  String get howItWorks;

  /// No description provided for @needsTrust.
  ///
  /// In en, this message translates to:
  /// **'We map this after you agree. Everything stays on this device.'**
  String get needsTrust;

  /// No description provided for @needsUnderstood.
  ///
  /// In en, this message translates to:
  /// **'What we understood'**
  String get needsUnderstood;

  /// No description provided for @needsNone.
  ///
  /// In en, this message translates to:
  /// **'No specific needs — a standard bag.'**
  String get needsNone;

  /// No description provided for @planWhy.
  ///
  /// In en, this message translates to:
  /// **'Every bag is capped at what that person can carry.'**
  String get planWhy;

  /// No description provided for @coverageLabel.
  ///
  /// In en, this message translates to:
  /// **'LT72 coverage'**
  String get coverageLabel;

  /// No description provided for @criticalCount.
  ///
  /// In en, this message translates to:
  /// **'{covered} of {total} critical groups'**
  String criticalCount(Object covered, Object total);

  /// No description provided for @bringFromHome.
  ///
  /// In en, this message translates to:
  /// **'Bring from home'**
  String get bringFromHome;

  /// No description provided for @bringFromHomeList.
  ///
  /// In en, this message translates to:
  /// **'ID copies, medicine, phone, charger, keys, cash, glasses, sleeping bag and mat.'**
  String get bringFromHomeList;

  /// No description provided for @planError.
  ///
  /// In en, this message translates to:
  /// **'We could not build a plan. Check the household details and try again.'**
  String get planError;

  /// No description provided for @reviewOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Review order · {price}'**
  String reviewOrderCta(Object price);

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTotal;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order · {price}'**
  String placeOrder(Object price);

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlaced;

  /// No description provided for @orderPlacedBody.
  ///
  /// In en, this message translates to:
  /// **'Four deliveries. Your family is ready by {date}.'**
  String orderPlacedBody(Object date);

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get cancelSubscription;

  /// No description provided for @subscriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled.'**
  String get subscriptionCancelled;

  /// No description provided for @replacementNote.
  ///
  /// In en, this message translates to:
  /// **'Food is swapped before it expires; children’s backpacks are replaced as they grow.'**
  String get replacementNote;

  /// No description provided for @packTitleWithName.
  ///
  /// In en, this message translates to:
  /// **'{name}’s bag'**
  String packTitleWithName(Object name);

  /// No description provided for @packReady.
  ///
  /// In en, this message translates to:
  /// **'{name}’s bag is ready.'**
  String packReady(Object name);

  /// No description provided for @packAllDone.
  ///
  /// In en, this message translates to:
  /// **'All packed. Keep it by the door.'**
  String get packAllDone;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get settingsPrivacy;

  /// No description provided for @aboutPrototype.
  ///
  /// In en, this message translates to:
  /// **'About this prototype'**
  String get aboutPrototype;

  /// No description provided for @aboutPrototypeBody.
  ///
  /// In en, this message translates to:
  /// **'Prices combine checked Barbora listings with catalogue estimates. Deliveries, payment and tracking are simulated for the hackathon build.'**
  String get aboutPrototypeBody;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your bags'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for 72 hours.'**
  String get homeSubtitle;

  /// No description provided for @homePlan.
  ///
  /// In en, this message translates to:
  /// **'View plan'**
  String get homePlan;

  /// No description provided for @homePack.
  ///
  /// In en, this message translates to:
  /// **'Pack a bag'**
  String get homePack;

  /// No description provided for @homeOrder.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get homeOrder;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeRestart.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get homeRestart;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @bagWeight.
  ///
  /// In en, this message translates to:
  /// **'{weight} / {limit} kg'**
  String bagWeight(String weight, String limit);

  /// No description provided for @condLowSugar.
  ///
  /// In en, this message translates to:
  /// **'Low sugar'**
  String get condLowSugar;

  /// No description provided for @markAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all packed'**
  String get markAll;

  /// No description provided for @unpackAll.
  ///
  /// In en, this message translates to:
  /// **'Unpack all'**
  String get unpackAll;

  /// No description provided for @grabGo.
  ///
  /// In en, this message translates to:
  /// **'Grab and go'**
  String get grabGo;

  /// No description provided for @grabGoSub.
  ///
  /// In en, this message translates to:
  /// **'Everything for the next 72 hours, in one place.'**
  String get grabGoSub;

  /// No description provided for @emergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Grab and go'**
  String get emergencyTitle;

  /// No description provided for @emergencySub.
  ///
  /// In en, this message translates to:
  /// **'If you have to leave now.'**
  String get emergencySub;

  /// No description provided for @emergencyTake.
  ///
  /// In en, this message translates to:
  /// **'Take these bags'**
  String get emergencyTake;

  /// No description provided for @emergencyHome.
  ///
  /// In en, this message translates to:
  /// **'Take from home'**
  String get emergencyHome;

  /// No description provided for @emergencyHomeList.
  ///
  /// In en, this message translates to:
  /// **'ID copies, medicine, phone, charger, keys, cash, glasses.'**
  String get emergencyHomeList;

  /// No description provided for @emergencyShelter.
  ///
  /// In en, this message translates to:
  /// **'Find a shelter'**
  String get emergencyShelter;

  /// No description provided for @emergencyShelterNote.
  ///
  /// In en, this message translates to:
  /// **'Official PAGD shelter information opens in your browser.'**
  String get emergencyShelterNote;

  /// No description provided for @emergencyCall.
  ///
  /// In en, this message translates to:
  /// **'Call 112'**
  String get emergencyCall;

  /// No description provided for @emergencyNote.
  ///
  /// In en, this message translates to:
  /// **'Do not wait for the app. If there is immediate danger, call 112.'**
  String get emergencyNote;

  /// No description provided for @openChecklist.
  ///
  /// In en, this message translates to:
  /// **'Open printable checklist'**
  String get openChecklist;

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistTitle;

  /// No description provided for @checklistSub.
  ///
  /// In en, this message translates to:
  /// **'Copy it, print it, or keep it offline.'**
  String get checklistSub;

  /// No description provided for @copyChecklist.
  ///
  /// In en, this message translates to:
  /// **'Copy checklist'**
  String get copyChecklist;

  /// No description provided for @checklistCopied.
  ///
  /// In en, this message translates to:
  /// **'Checklist copied to the clipboard.'**
  String get checklistCopied;

  /// No description provided for @checklistHeader.
  ///
  /// In en, this message translates to:
  /// **'READY72 · {name} · {weight} / {limit} kg'**
  String checklistHeader(String name, String weight, String limit);

  /// No description provided for @checklistFromHome.
  ///
  /// In en, this message translates to:
  /// **'From home: ID copies, medicine, phone, charger, keys, cash, glasses.'**
  String get checklistFromHome;

  /// No description provided for @shelterLink.
  ///
  /// In en, this message translates to:
  /// **'Open PAGD shelter information'**
  String get shelterLink;

  /// No description provided for @lt72SourceCount.
  ///
  /// In en, this message translates to:
  /// **'Based on the {count}-item LT72 list (lt72.lt)'**
  String lt72SourceCount(int count);

  /// No description provided for @openStore.
  ///
  /// In en, this message translates to:
  /// **'Open store'**
  String get openStore;

  /// No description provided for @copyStoreList.
  ///
  /// In en, this message translates to:
  /// **'Copy shopping list'**
  String get copyStoreList;

  /// No description provided for @storeListCopied.
  ///
  /// In en, this message translates to:
  /// **'Shopping list copied.'**
  String get storeListCopied;

  /// No description provided for @storeListHeader.
  ///
  /// In en, this message translates to:
  /// **'{store} · {count} items'**
  String storeListHeader(String store, int count);

  /// No description provided for @lt72List.
  ///
  /// In en, this message translates to:
  /// **'See the 82-item LT72 list'**
  String get lt72List;

  /// No description provided for @lt72ListSub.
  ///
  /// In en, this message translates to:
  /// **'The official list behind every plan.'**
  String get lt72ListSub;

  /// No description provided for @lt72OpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open lt72.lt'**
  String get lt72OpenSource;

  /// No description provided for @lt72Supplementary.
  ///
  /// In en, this message translates to:
  /// **'Supplementary'**
  String get lt72Supplementary;

  /// No description provided for @lt72Conditional.
  ///
  /// In en, this message translates to:
  /// **'Conditional'**
  String get lt72Conditional;

  /// No description provided for @lt72Critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get lt72Critical;

  /// No description provided for @lt72Important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get lt72Important;

  /// No description provided for @lt72Comfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get lt72Comfort;

  /// No description provided for @lt72GroupAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get lt72GroupAll;

  /// No description provided for @lt72GroupAdult.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get lt72GroupAdult;

  /// No description provided for @lt72GroupChild.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get lt72GroupChild;

  /// No description provided for @lt72GroupSenior.
  ///
  /// In en, this message translates to:
  /// **'Seniors'**
  String get lt72GroupSenior;

  /// No description provided for @lt72GroupBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get lt72GroupBaby;

  /// No description provided for @lt72GroupPet.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get lt72GroupPet;

  /// No description provided for @noAdultTitle.
  ///
  /// In en, this message translates to:
  /// **'No adult in this household'**
  String get noAdultTitle;

  /// No description provided for @noAdultBody.
  ///
  /// In en, this message translates to:
  /// **'Children cannot carry a full 72-hour load alone. Add an adult, or plan a pickup point with a wheeled carrier. The gaps below are shown honestly.'**
  String get noAdultBody;

  /// No description provided for @lt72Covered.
  ///
  /// In en, this message translates to:
  /// **'In plan'**
  String get lt72Covered;

  /// No description provided for @lt72FromHome.
  ///
  /// In en, this message translates to:
  /// **'From home'**
  String get lt72FromHome;

  /// No description provided for @lt72Gap.
  ///
  /// In en, this message translates to:
  /// **'Not covered'**
  String get lt72Gap;

  /// No description provided for @lt72Summary.
  ///
  /// In en, this message translates to:
  /// **'{covered} in plan · {home} from home · {gaps} gaps'**
  String lt72Summary(int covered, int home, int gaps);

  /// No description provided for @lt72MappingNote.
  ///
  /// In en, this message translates to:
  /// **'“In plan” means a purchased item covers that LT72 category. “From home” is already-own gear the app does not buy.'**
  String get lt72MappingNote;

  /// No description provided for @printChecklist.
  ///
  /// In en, this message translates to:
  /// **'Print / PDF'**
  String get printChecklist;

  /// No description provided for @printFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the print dialog.'**
  String get printFailed;

  /// No description provided for @shelterTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a shelter'**
  String get shelterTitle;

  /// No description provided for @shelterSub.
  ///
  /// In en, this message translates to:
  /// **'Collective protection buildings are chosen by your municipality.'**
  String get shelterSub;

  /// No description provided for @shelterOfficial.
  ///
  /// In en, this message translates to:
  /// **'Open the official PAGD list'**
  String get shelterOfficial;

  /// No description provided for @shelterMap.
  ///
  /// In en, this message translates to:
  /// **'Search the map near me'**
  String get shelterMap;

  /// No description provided for @shelterNote.
  ///
  /// In en, this message translates to:
  /// **'The map search is a starting point, not the official list. Confirm the building with your municipality or PAGD.'**
  String get shelterNote;

  /// No description provided for @shelterCall.
  ///
  /// In en, this message translates to:
  /// **'If there is immediate danger, call 112.'**
  String get shelterCall;

  /// No description provided for @catalogueTitle.
  ///
  /// In en, this message translates to:
  /// **'Product catalogue'**
  String get catalogueTitle;

  /// No description provided for @catalogueBody.
  ///
  /// In en, this message translates to:
  /// **'Real prices from public store pages. Search any item and open it at the store.'**
  String get catalogueBody;

  /// No description provided for @catalogueSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get catalogueSearchHint;

  /// No description provided for @catalogueAll.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get catalogueAll;

  /// No description provided for @catalogueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String catalogueCount(int count);

  /// No description provided for @catalogueNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching products.'**
  String get catalogueNoResults;

  /// No description provided for @catalogueAiPick.
  ///
  /// In en, this message translates to:
  /// **'Ask AI to pick'**
  String get catalogueAiPick;

  /// No description provided for @catalogueAiEmpty.
  ///
  /// In en, this message translates to:
  /// **'AI found nothing for this search.'**
  String get catalogueAiEmpty;

  /// No description provided for @catalogueSettings.
  ///
  /// In en, this message translates to:
  /// **'Product catalogue'**
  String get catalogueSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lt':
      return AppLocalizationsLt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
