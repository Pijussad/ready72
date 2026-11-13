import '../data/lt72.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../models/person.dart';
import '../models/product.dart';

String conditionLabel(AppLocalizations l, String? token) {
  switch (token) {
    case 'diabetes':
      return l.condDiabetes;
    case 'insulin':
      return l.condInsulin;
    case 'hypertension':
      return l.condHypertension;
    case 'asthma':
      return l.condAsthma;
    case 'epilepsy':
      return l.condEpilepsy;
    case 'heart':
      return l.condHeart;
    case 'kidney':
      return l.condKidney;
    case 'nuts':
      return l.condNuts;
    case 'gluten':
    case 'glutenFree':
      return l.condGluten;
    case 'dairy':
    case 'dairyFree':
      return l.condDairy;
    case 'fish':
      return l.condFish;
    case 'eggs':
      return l.condEggs;
    case 'soy':
      return l.condSoy;
    case 'lowSugar':
      return l.condLowSugar;
    case 'vegetarian':
      return l.condVegetarian;
    case 'vegan':
      return l.condVegan;
    case 'pregnancy':
    case 'pregnant':
      return l.condPregnancy;
    case 'back':
      return l.condBack;
    case 'mobility':
      return l.condMobility;
    case 'glasses':
      return l.condGlasses;
    case 'baby':
      return l.condBaby;
    case 'prescribed':
      return l.condPrescribed;
    default:
      return token ?? '';
  }
}

String categoryLabel(AppLocalizations l, LCategory category) {
  switch (category) {
    case LCategory.documents:
      return l.catDocuments;
    case LCategory.clothing:
      return l.catClothing;
    case LCategory.firstAid:
      return l.catFirstAid;
    case LCategory.medication:
      return l.catMedication;
    case LCategory.food:
      return l.catFood;
    case LCategory.water:
      return l.catWater;
    case LCategory.hygiene:
      return l.catHygiene;
    case LCategory.shelter:
      return l.catShelter;
    case LCategory.tools:
      return l.catTools;
    case LCategory.communication:
      return l.catCommunication;
    case LCategory.light:
      return l.catLight;
    case LCategory.children:
      return l.catChildren;
    case LCategory.pets:
      return l.catPets;
  }
}

String categoryLabelFromKey(AppLocalizations l, String key) {
  for (final entry in categoryNameKeys.entries) {
    if (entry.value == key) return categoryLabel(l, entry.key);
  }
  return key;
}

String statusLabel(AppLocalizations l, ShipmentStatus status) {
  switch (status) {
    case ShipmentStatus.ordered:
      return l.statusOrdered;
    case ShipmentStatus.packed:
      return l.statusPacked;
    case ShipmentStatus.onTheWay:
      return l.statusOnTheWay;
    case ShipmentStatus.delivered:
      return l.statusDelivered;
  }
}

String groupLabel(AppLocalizations l, Person person) {
  if (person.isToddler || person.isChild) return l.upTo14;
  if (person.isSenior) return l.senior;
  return l.adult;
}
