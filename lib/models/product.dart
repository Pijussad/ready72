enum Store { barbora, rimi, eurovaistine, decathlon }

extension StoreDetails on Store {
  String get label {
    switch (this) {
      case Store.barbora:
        return 'Barbora';
      case Store.rimi:
        return 'Rimi';
      case Store.eurovaistine:
        return 'Eurovaistinė';
      case Store.decathlon:
        return 'Decathlon';
    }
  }

  String get homeUrl {
    switch (this) {
      case Store.barbora:
        return 'https://barbora.lt/';
      case Store.rimi:
        return 'https://www.rimi.lt/';
      case Store.eurovaistine:
        return 'https://www.eurovaistine.lt/';
      case Store.decathlon:
        return 'https://www.decathlon.lt/';
    }
  }

  String searchUrl(String query) {
    final encoded = Uri.encodeQueryComponent(query);
    switch (this) {
      case Store.barbora:
        return 'https://barbora.lt/search?q=$encoded';
      case Store.rimi:
        return 'https://www.rimi.lt/search?query=$encoded';
      case Store.eurovaistine:
        return 'https://www.eurovaistine.lt/paieska/rezultatai?q=$encoded';
      case Store.decathlon:
        return 'https://www.decathlon.lt/search/?query=$encoded';
    }
  }

  /// Delivery is simulated in this prototype; these are not live slots.
  int get deliveryDays {
    switch (this) {
      case Store.barbora:
        return 2;
      case Store.rimi:
        return 2;
      case Store.eurovaistine:
        return 3;
      case Store.decathlon:
        return 5;
    }
  }
}

enum Priority { critical, important, comfort }

enum LCategory {
  documents,
  clothing,
  firstAid,
  medication,
  food,
  water,
  hygiene,
  shelter,
  tools,
  communication,
  light,
  children,
  pets,
}

/// A demo catalogue product. Prices, weights and stock are fixture data for
/// the hackathon. `verified` is false because they are not live store quotes.
class Product {
  const Product({
    required this.id,
    required this.nameEn,
    required this.nameLt,
    required this.category,
    required this.store,
    required this.priceEur,
    required this.weightKg,
    required this.shelfLifeMonths,
    required this.allergens,
    required this.diets,
    required this.caloriesPerUnit,
    required this.priority,
    required this.ageMin,
    required this.ageMax,
    required this.tags,
    required this.url,
    this.verified = false,
  });

  final String id;
  final String nameEn;
  final String nameLt;
  final LCategory category;
  final Store store;
  final double priceEur;
  final double weightKg;
  final int shelfLifeMonths;
  final Set<String> allergens;
  final Set<String> diets;
  final int caloriesPerUnit;
  final Priority priority;
  final int ageMin;
  final int ageMax;
  final Set<String> tags;
  final String url;
  final bool verified;

  String name(String languageCode) => languageCode == 'lt' ? nameLt : nameEn;

  /// Store search in Lithuanian. Search pages are stable; individual product
  /// pages in the fixture catalogue go out of stock or disappear.
  String get orderUrl => store.searchUrl(nameLt);

  bool get isShared => tags.contains('shared');
  bool get userSupplied => tags.contains('userSupplied');
  bool get isFood => category == LCategory.food && caloriesPerUnit > 0;
  bool get highSugar => tags.contains('highSugar');

  bool suitableForAge(int age) => age >= ageMin && age <= ageMax;

  bool compatibleWith({
    required Set<String> allergies,
    required Set<String> diets,
  }) {
    // Diet and allergen rules apply to things a person eats or takes, not to
    // backpacks, tents or first-aid kits.
    if (category != LCategory.food && category != LCategory.medication) {
      return true;
    }
    if (allergens.any(allergies.contains)) return false;
    if (category != LCategory.food) return true;
    if (diets.contains('vegan') && !this.diets.contains('vegan')) return false;
    if (diets.contains('vegetarian') &&
        !this.diets.contains('vegetarian') &&
        !this.diets.contains('vegan')) {
      return false;
    }
    if (diets.contains('glutenFree') && allergens.contains('gluten')) {
      return false;
    }
    if (diets.contains('dairyFree') && allergens.contains('dairy')) {
      return false;
    }
    if (diets.contains('lowSugar') && highSugar) return false;
    return true;
  }
}
