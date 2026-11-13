import '../config/app_config.dart';
import '../data/catalogue.dart';
import '../data/lt72.dart';
import '../models/person.dart';
import '../models/plan.dart';
import '../models/product.dart';
import 'carry_limits.dart';

class GuardrailRule {
  const GuardrailRule({
    required this.id,
    required this.statement,
    required this.evidence,
    required this.blocker,
    required this.repair,
  });

  final String id;
  final String statement;
  final String evidence;
  final bool blocker;
  final String repair;
}

/// Rules are checkable by ordinary code, never by asking the LLM again.
/// The discovery pass and red-team notes are recorded in docs/GUARDRAILS.md.
const List<GuardrailRule> guardrailRules = [
  GuardrailRule(
    id: 'food-mandatory',
    statement: 'Every person has at least 90% of their 72-hour calorie target.',
    evidence: 'LT72 food section; WHO/FAO calorie references',
    blocker: true,
    repair: 'Add the cheapest compatible calorie-dense food.',
  ),
  GuardrailRule(
    id: 'water-mandatory',
    statement: 'The plan contains carried water and a purification method.',
    evidence:
        'LT72 water section: 2-4 l per person per day; purification mandatory for natural water',
    blocker: true,
    repair: 'Add water bottles and purification tablets.',
  ),
  GuardrailRule(
    id: 'critical-coverage',
    statement: 'Every critical LT72 category is covered, or the gap is shown.',
    evidence: 'LT72 evacuation-bag checklist',
    blocker: true,
    repair:
        'Add the lightest catalogue item from the missing category, or report the gap.',
  ),
  GuardrailRule(
    id: 'carry-limit',
    statement: 'No bag exceeds its owner carry limit.',
    evidence: 'LT72: no more than one fifth of body weight; age caps in config',
    blocker: true,
    repair:
        'Move the item to the strongest carrier or drop the lowest priority line.',
  ),
  GuardrailRule(
    id: 'allergen',
    statement:
        'No item contains an allergen or violates a diet for its beneficiary or carrier.',
    evidence: 'LT72 special-diet guidance; user-provided needs',
    blocker: true,
    repair: 'Swap for a compatible catalogue item; if none, report a gap.',
  ),
  GuardrailRule(
    id: 'age',
    statement: 'Items are suitable for the age of the person they are for.',
    evidence: 'LT72 child and infant guidance',
    blocker: true,
    repair: 'Replace with an age-appropriate product.',
  ),
  GuardrailRule(
    id: 'product-exists',
    statement: 'Every product id exists in the catalogue snapshot.',
    evidence: 'Catalogue contract',
    blocker: true,
    repair: 'Remove invented ids; rebuild from catalogue.',
  ),
  GuardrailRule(
    id: 'quantity-sane',
    statement: 'No line exceeds 12 units and no duplicate line exists.',
    evidence: 'Red-team pass: hoarding and duplicate failures',
    blocker: false,
    repair: 'Cap quantity and merge duplicate lines.',
  ),
  GuardrailRule(
    id: 'needs-mapped',
    statement:
        'Every parsed need maps to an item, a reduced limit, or a visible gap.',
    evidence: 'Section 4.3 safety requirements',
    blocker: true,
    repair: 'Add the mapped item or list the gap.',
  ),
  GuardrailRule(
    id: 'shelf-life',
    statement: 'Stored food has at least 12 months of shelf life.',
    evidence: 'Ready72 stored-food rule; LT72 twice-yearly review',
    blocker: true,
    repair: 'Swap for a longer-life product.',
  ),
  GuardrailRule(
    id: 'no-doses',
    statement: 'No medicine dose is generated or displayed.',
    evidence: 'Medical safety rule: app is not a medical advisor',
    blocker: true,
    repair: 'Replace with a reminder to bring prescribed medicine.',
  ),
  GuardrailRule(
    id: 'price-snapshot',
    statement:
        'Every price comes from the catalogue snapshot, never from the model.',
    evidence: 'Section 4.4a price rules',
    blocker: true,
    repair: 'Recompute the line from the catalogue; flag unverified prices.',
  ),
  GuardrailRule(
    id: 'price-range',
    statement: 'The plan total is within a plausible household range.',
    evidence: 'Catalogue snapshot sanity bounds',
    blocker: false,
    repair: 'Flag the total for review.',
  ),
  GuardrailRule(
    id: 'pets-covered',
    statement: 'A household with pets gets pet food, water and handling items.',
    evidence: 'LT72 pet evacuation-bag section',
    blocker: true,
    repair: 'Add the pet kit to the strongest adult bag.',
  ),
  GuardrailRule(
    id: 'shared-heavy',
    statement:
        'Heavy shared items are carried by an adult, never a child or toddler.',
    evidence: 'Section 4.4b distribution rules',
    blocker: true,
    repair: 'Reassign the unit to the adult with the most remaining capacity.',
  ),
  GuardrailRule(
    id: 'balance',
    statement:
        'Carriers finish within 15 percentage points of the fullest bag.',
    evidence: 'Section 4.4b balance target',
    blocker: false,
    repair: 'Move light units from the fullest bag to the emptiest.',
  ),
];

Person? _personById(List<Person> people, String id) {
  for (final person in people) {
    if (person.id == id) return person;
  }
  return null;
}

class PlanGuardrails {
  PlanGuardrails._();

  static GuardrailReport validate({
    required PlanRequest request,
    required PlanResult plan,
    required Map<String, CarryLimit> limits,
  }) {
    final checks = <GuardrailCheck>[];

    void add(String id, bool passed, {String? detail}) {
      final rule = guardrailRules.firstWhere((rule) => rule.id == id);
      checks.add(
        GuardrailCheck(
          id: id,
          statement: rule.statement,
          blocker: rule.blocker,
          passed: passed,
          detail: detail,
        ),
      );
    }

    // Food.
    final foodFailures = <String>[];
    for (final person in request.household) {
      final target = AppConfig.dailyCalories(person.group) * 3;
      final actual = plan.caloriesByPerson[person.id] ?? 0;
      if (actual < target * 0.9) {
        foodFailures.add('${person.name}: $actual / ${target.round()} kcal');
      }
    }
    add(
      'food-mandatory',
      foodFailures.isEmpty,
      detail: foodFailures.isEmpty ? null : foodFailures.join(', '),
    );

    // Water: check litres actually carried, not just the category.
    final carriedLitres = plan.items
        .where(
          (item) =>
              item.product.id == 'water-05' || item.product.id == 'water-15',
        )
        .fold(0.0, (sum, item) => sum + item.product.weightKg * item.quantity);
    final requiredLitres = request.household.fold(0.0, (sum, person) {
      return sum +
          AppConfig.waterLitresPerDay(
                person.group,
                comfort: request.tier == PlanTier.comfort,
              ) *
              3 *
              0.8;
    });
    final hasPurification = plan.items.any(
      (item) =>
          item.product.id == 'purification' ||
          item.product.id == 'water-filter',
    );
    add(
      'water-mandatory',
      carriedLitres + 0.001 >= requiredLitres && hasPurification,
      detail:
          '${carriedLitres.toStringAsFixed(1)} L carried, '
          '${requiredLitres.toStringAsFixed(1)} L required',
    );

    // Critical categories.
    final missingCritical = criticalCategories.difference(
      plan.coveredCategories,
    );
    add(
      'critical-coverage',
      missingCritical.isEmpty,
      detail: missingCritical.isEmpty
          ? null
          : missingCritical.map((category) => category.name).join(', '),
    );

    // Carry limits.
    final over = plan.bags.values.where((bag) => !bag.withinLimit).toList();
    add(
      'carry-limit',
      over.isEmpty,
      detail: over.isEmpty
          ? null
          : over
                .map(
                  (bag) =>
                      '${bag.person.name} ${bag.weightKg.toStringAsFixed(1)}/${bag.limitKg}',
                )
                .join(', '),
    );

    // Allergens and diets, for beneficiary and carrier.
    final allergenFailures = <String>[];
    final allergenSeen = <String>{};
    for (final item in plan.items) {
      if (!item.product.isFood &&
          item.product.category != LCategory.medication) {
        continue;
      }
      final beneficiary = _personById(request.household, item.beneficiaryId);
      final carrier = _personById(request.household, item.carrierId);
      final people = <Person>{};
      if (beneficiary != null) people.add(beneficiary);
      if (carrier != null) people.add(carrier);
      for (final person in people) {
        final needs = request.needs.needsFor(person.id);
        if (!item.product.compatibleWith(
          allergies: needs.allergies,
          diets: needs.diets,
        )) {
          final label = '${item.product.id} for ${person.name}';
          if (allergenSeen.add(label)) allergenFailures.add(label);
        }
      }
    }
    add(
      'allergen',
      allergenFailures.isEmpty,
      detail: allergenFailures.isEmpty ? null : allergenFailures.join(', '),
    );

    // Age.
    final ageFailures = <String>[];
    for (final item in plan.items) {
      final beneficiary = _personById(request.household, item.beneficiaryId);
      if (beneficiary != null &&
          !item.product.suitableForAge(beneficiary.age)) {
        ageFailures.add('${item.product.id} for ${beneficiary.name}');
      }
    }
    add(
      'age',
      ageFailures.isEmpty,
      detail: ageFailures.isEmpty ? null : ageFailures.join(', '),
    );

    // Catalogue identity and price snapshot.
    final missingProducts = <String>[];
    final badPrices = <String>[];
    for (final item in plan.items) {
      final known = productById(item.product.id);
      if (known == null) {
        missingProducts.add(item.product.id);
      } else if ((known.priceEur - item.product.priceEur).abs() > 0.001) {
        badPrices.add(item.product.id);
      }
    }
    add(
      'product-exists',
      missingProducts.isEmpty,
      detail: missingProducts.isEmpty ? null : missingProducts.join(', '),
    );
    add(
      'price-snapshot',
      badPrices.isEmpty,
      detail: badPrices.isEmpty ? null : badPrices.join(', '),
    );

    // Quantities and duplicates.
    final keys = <String>{};
    var quantityProblem = false;
    for (final item in plan.items) {
      if (item.quantity < 1 || item.quantity > 8) quantityProblem = true;
      if (!keys.add(item.key)) quantityProblem = true;
    }
    add('quantity-sane', !quantityProblem);

    // Needs mapping.
    final unmapped = _unmappedNeeds(request, plan, limits);
    add(
      'needs-mapped',
      unmapped.isEmpty,
      detail: unmapped.isEmpty ? null : unmapped.join('; '),
    );

    // Shelf life for stored food.
    final shortLife = plan.items
        .where(
          (item) =>
              item.product.isFood &&
              item.product.shelfLifeMonths < AppConfig.minimumShelfLifeMonths,
        )
        .map((item) => item.product.id)
        .toList();
    add(
      'shelf-life',
      shortLife.isEmpty,
      detail: shortLife.isEmpty ? null : shortLife.join(', '),
    );

    // No doses anywhere.
    final dosePattern = RegExp(
      r'\b\d+(?:[.,]\d+)?\s*(mg|mcg|µg|units?|iu)\b',
      caseSensitive: false,
    );
    final doseHits = plan.items
        .where(
          (item) =>
              item.product.category == LCategory.medication &&
              (dosePattern.hasMatch(item.product.nameEn) ||
                  dosePattern.hasMatch(item.product.nameLt) ||
                  (item.note != null && dosePattern.hasMatch(item.note!))),
        )
        .map((item) => item.product.id)
        .toList();
    add(
      'no-doses',
      doseHits.isEmpty,
      detail: doseHits.isEmpty ? null : doseHits.join(', '),
    );

    // Price range sanity (the approved artboard is €286–€412 for four people).
    final perPerson = plan.totalPrice / request.household.length;
    add(
      'price-range',
      perPerson >= 60 && perPerson <= 900,
      detail: '€${perPerson.toStringAsFixed(2)} per person',
    );

    // Pets.
    if (request.needs.hasPets) {
      final petItems = plan.items.where(
        (item) => item.product.category == LCategory.pets,
      );
      final hasPetFood = plan.items.any(
        (item) =>
            item.product.id == 'dog-food' ||
            item.product.id == 'cat-food' ||
            item.product.id == 'dog-dry',
      );
      add('pets-covered', petItems.isNotEmpty && hasPetFood);
    } else {
      add('pets-covered', true);
    }

    // Heavy shared items go to adults.
    final sharedHeavy = plan.items.where(
      (item) => item.shared && item.weightKg > 0.5,
    );
    var heavyOk = true;
    for (final item in sharedHeavy) {
      final carrier = _personById(request.household, item.carrierId);
      if (carrier == null ||
          (!carrier.isAdult && !carrier.isSenior && carrier.age < 10)) {
        heavyOk = false;
      }
    }
    add('shared-heavy', heavyOk);

    // Balance (warning only).
    final ratios = plan.bags.values
        .where((bag) => bag.limitKg > 0)
        .map((bag) => bag.fillRatio)
        .toList();
    if (ratios.isEmpty) {
      add('balance', true);
    } else {
      final spread =
          ratios.reduce((a, b) => a > b ? a : b) -
          ratios.reduce((a, b) => a < b ? a : b);
      add(
        'balance',
        spread <= 0.15,
        detail: '${(spread * 100).round()} percentage points',
      );
    }

    return GuardrailReport(checks);
  }

  static List<String> _unmappedNeeds(
    PlanRequest request,
    PlanResult plan,
    Map<String, CarryLimit> limits,
  ) {
    final result = <String>[];
    for (final person in request.household) {
      final needs = request.needs.needsFor(person.id);
      final items = plan.items
          .where((item) => item.beneficiaryId == person.id)
          .toList();
      bool has(String id) => items.any((item) => item.product.id == id);
      bool hasCategory(LCategory category) =>
          items.any((item) => item.product.category == category);

      if ((needs.medications.isNotEmpty || needs.conditions.isNotEmpty) &&
          !has('prescription') &&
          !has('med-pouch')) {
        result.add('${person.name}: medication');
      }
      if (needs.medications.isNotEmpty && !has('prescription')) {
        result.add('${person.name}: prescription reminder');
      }
      if (needs.needsCooling && !has('cooling-pouch')) {
        result.add('${person.name}: cooling');
      }
      if (person.age <= 3 && needs.diapers && !has('diapers')) {
        result.add('${person.name}: nappies');
      }
      if (person.age <= 3 && needs.formula && !has('formula')) {
        result.add('${person.name}: formula');
      }
      if (person.age <= 3 && needs.babyFood && !has('baby-food')) {
        result.add('${person.name}: baby food');
      }
      if (needs.glasses && !has('glasses-case')) {
        result.add('${person.name}: glasses');
      }
      if (needs.needsReducedCapacity && !limits[person.id]!.reduced) {
        result.add('${person.name}: reduced capacity');
      }
      if ((needs.allergies.isNotEmpty || needs.diets.isNotEmpty) &&
          !hasCategory(LCategory.food)) {
        result.add('${person.name}: diet food');
      }
    }
    if (request.needs.hasPets) {
      final hasPetFood = plan.items.any(
        (item) =>
            item.product.category == LCategory.pets ||
            item.product.id == 'dog-food' ||
            item.product.id == 'cat-food' ||
            item.product.id == 'dog-dry',
      );
      if (!hasPetFood) result.add('pets: food');
    }
    return result;
  }
}
