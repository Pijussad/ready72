import 'dart:math';

import '../config/app_config.dart';
import '../data/catalogue.dart';
import '../data/lt72.dart';
import '../models/needs.dart';
import '../models/person.dart';
import '../models/plan.dart';
import '../models/product.dart';
import 'carry_limits.dart';
import 'guardrails.dart';

/// Deterministic plan builder with guardrails.
///
/// The LLM, when enabled, proposes the same shape (product ids, quantities and
/// a carrier). This builder is the fallback and the repair tool: it only uses
/// catalogue ids, computes every price itself, and never exceeds a limit.
class PlanOptimizer {
  const PlanOptimizer();

  PlanResult build(PlanRequest request) {
    final limits = <String, CarryLimit>{
      for (final person in request.household)
        person.id: CarryLimits.compute(
          person,
          request.needs.needsFor(person.id),
        ),
    };

    final bags = <String, List<PlanItem>>{
      for (final person in request.household) person.id: <PlanItem>[],
    };
    final dropped = <String>[];

    // 1. Essential personal lines, owned by the person.
    for (final person in request.household) {
      final items = _essentialPersonalItems(person, request);
      for (final item in items) {
        bags[person.id]!.add(item);
      }
    }

    // 2. Fit personal lines into each bag. Dependants' items move to a carer.
    for (final person in request.household) {
      _fitPersonal(
        person: person,
        household: request.household,
        bags: bags,
        limits: limits,
        dropped: dropped,
        languageCode: request.languageCode,
      );
    }

    // 3. Critical/important common load first: food, water and pets must not
    // be displaced by comfort kit.
    final remaining = <String, double>{
      for (final person in request.household)
        person.id: max(
          0,
          limits[person.id]!.limitKg - _weightOf(bags[person.id]!),
        ),
    };

    final basePool = <_PoolLine>[
      ..._sharedEssentialPool(request),
      ..._foodPool(request),
      ..._waterPool(request),
      if (request.needs.hasPets) ..._petPool(request),
    ];

    final baseItems = _distribute(
      pool: basePool,
      request: request,
      remaining: remaining,
      dropped: dropped,
    );
    for (final item in baseItems) {
      bags[item.carrierId]!.add(item);
    }

    // 4. Comfort kit only uses what is left.
    if (request.tier == PlanTier.comfort) {
      final carerId = _strongestAdult(request)?.id;
      final comfortPool = <_PoolLine>[
        for (final person in request.household)
          for (final item in _comfortPersonalItems(person, request))
            _PoolLine(
              product: item.product,
              quantity: item.quantity,
              beneficiaryId: person.id,
              preferredCarrierId: person.isToddler ? carerId : person.id,
              strictPreferred: !person.isToddler && !person.isChild,
              adultsOnly: person.isToddler,
            ),
        ..._comfortPool(request),
      ];
      final comfortItems = _distribute(
        pool: comfortPool,
        request: request,
        remaining: remaining,
        dropped: dropped,
        reportDropped: false,
      );
      for (final item in comfortItems) {
        bags[item.carrierId]!.add(item);
      }
    }

    // 4. Merge duplicate lines after distribution.
    final merged = <String, PlanItem>{};
    for (final items in bags.values) {
      for (final item in items) {
        final existing = merged[item.key];
        if (existing == null) {
          merged[item.key] = item;
        } else {
          merged[item.key] = existing.copyWith(
            quantity: existing.quantity + item.quantity,
          );
        }
      }
    }
    final finalItems = merged.values.toList()
      ..sort((a, b) {
        final byCarrier = a.carrierId.compareTo(b.carrierId);
        if (byCarrier != 0) return byCarrier;
        final byPriority = a.product.priority.index.compareTo(
          b.product.priority.index,
        );
        if (byPriority != 0) return byPriority;
        return a.product.id.compareTo(b.product.id);
      });

    for (final items in bags.values) {
      items.clear();
    }
    for (final item in finalItems) {
      bags[item.carrierId]!.add(item);
    }

    final personBags = <String, PersonBag>{
      for (final person in request.household)
        person.id: PersonBag(
          person: person,
          limitKg: limits[person.id]!.limitKg,
          items: bags[person.id]!,
        ),
    };

    final covered = <LCategory>{
      for (final item in finalItems) item.product.category,
    };
    final gaps = criticalCategories.difference(covered);
    if (request.needs.hasPets &&
        !finalItems.any((item) => item.product.category == LCategory.pets)) {
      gaps.add(LCategory.pets);
    }

    final calories = <String, int>{
      for (final person in request.household) person.id: 0,
    };
    for (final item in finalItems) {
      if (item.product.isFood && !item.product.tags.contains('pets')) {
        calories[item.beneficiaryId] =
            (calories[item.beneficiaryId] ?? 0) + item.calories;
      }
    }

    final unverified = finalItems
        .where((item) => !item.product.verified && !item.product.userSupplied)
        .map((item) => item.product.id)
        .toSet()
        .length;

    final temporary = PlanResult(
      tier: request.tier,
      items: finalItems,
      bags: personBags,
      coveredCategories: covered,
      gaps: gaps,
      dropped: dropped,
      caloriesByPerson: calories,
      guardrails: const GuardrailReport([]),
      unverifiedPriceCount: unverified,
    );

    final report = PlanGuardrails.validate(
      request: request,
      plan: temporary,
      limits: limits,
    );

    return PlanResult(
      tier: request.tier,
      items: finalItems,
      bags: personBags,
      coveredCategories: covered,
      gaps: gaps,
      dropped: dropped,
      caloriesByPerson: calories,
      guardrails: report,
      unverifiedPriceCount: unverified,
    );
  }

  // ---------------------------------------------------------------------
  // Personal kit
  // ---------------------------------------------------------------------

  List<PlanItem> _essentialPersonalItems(Person person, PlanRequest request) {
    final needs = request.needs.needsFor(person.id);
    final items = <PlanItem>[];

    void add(String id, {int quantity = 1, String? note}) {
      final product = productById(id);
      if (product == null) return;
      if (!product.suitableForAge(person.age)) return;
      if (items.any((item) => item.product.id == id)) return;
      items.add(
        PlanItem(
          product: product,
          quantity: quantity,
          carrierId: person.id,
          beneficiaryId: person.id,
          note: note,
        ),
      );
    }

    void addNeedsItems() {
      if (needs.glasses) add('glasses-case');
      if (needs.medications.isNotEmpty ||
          needs.conditions.isNotEmpty ||
          needs.healthHistory) {
        add('prescription', note: 'Bring your own prescribed medicine.');
        add('health-history');
      }
      if (needs.needsCooling) add('cooling-pouch');
    }

    if (person.isToddler) {
      add('child-id');
      add('child-toy');
      add('med-pouch');
      add('emergency-blanket');
      add('backpack-toddler');
      add('toddler-clothes');
      if (needs.diapers || person.age <= 3) add('diapers');
      if (needs.formula) add('formula');
      if (needs.babyFood || person.age <= 3) add('baby-food', quantity: 6);
      addNeedsItems();
      return items;
    }

    if (person.isChild) {
      add('backpack-child');
      add('child-clothes');
      add('child-id');
      add('med-pouch');
      add('emergency-blanket');
      addNeedsItems();
      return items;
    }

    // Adult and senior: the Essential tier carries only what covers every
    // critical category. Comfort adds the rest of the LT72 personal kit.
    add('backpack-adult');
    add('document-pouch');
    add('med-pouch');
    add('base-layer');
    add('emergency-blanket');
    add('headlamp');
    addNeedsItems();
    return items;
  }

  List<PlanItem> _comfortPersonalItems(Person person, PlanRequest request) {
    final items = <PlanItem>[];
    void add(String id) {
      final product = productById(id);
      if (product == null) return;
      if (!product.suitableForAge(person.age)) return;
      if (items.any((item) => item.product.id == id)) return;
      items.add(
        PlanItem(
          product: product,
          quantity: 1,
          carrierId: person.id,
          beneficiaryId: person.id,
        ),
      );
    }

    if (person.isToddler) {
      add('hat-gloves');
      add('socks');
    } else if (person.isChild) {
      add('fleece');
      add('hat-gloves');
    } else {
      add('fleece');
      add('hat-gloves');
    }
    return items;
  }

  // ---------------------------------------------------------------------
  // Common pool
  // ---------------------------------------------------------------------

  /// One first-aid kit and a small number of hygiene kits serve the household.
  /// Buying a full kit for every person was the main reason the old plan cost
  /// three times the approved artboard.
  List<_PoolLine> _sharedEssentialPool(PlanRequest request) {
    final lines = <_PoolLine>[];
    final carrier = _strongestCarrier(request);
    void add(String id, int quantity) {
      final product = productById(id);
      if (product == null) return;
      lines.add(
        _PoolLine(
          product: product,
          quantity: quantity,
          beneficiaryId: carrier?.id ?? request.household.first.id,
          shared: true,
          preferredCarrierId: carrier?.id,
        ),
      );
    }

    add('first-aid', 1);
    add('hygiene-kit', max(1, (request.household.length / 2).ceil()));
    return lines;
  }

  List<_PoolLine> _foodPool(PlanRequest request) {
    final lines = <_PoolLine>[];
    for (final person in request.household) {
      final needs = request.needs.needsFor(person.id);
      lines.addAll(
        _foodForPerson(person: person, needs: needs, tier: request.tier).map(
          (entry) => _PoolLine(
            product: entry.$1,
            quantity: entry.$2,
            beneficiaryId: person.id,
          ),
        ),
      );
    }
    return lines;
  }

  List<(Product, int)> _foodForPerson({
    required Person person,
    required PersonNeeds needs,
    required PlanTier tier,
  }) {
    final target = AppConfig.dailyCalories(person.group) * 3;
    final compatible = catalogue
        .where(
          (product) =>
              product.isFood &&
              !product.tags.contains('pets') &&
              product.suitableForAge(person.age) &&
              product.compatibleWith(
                allergies: needs.allergies,
                diets: needs.diets,
              ) &&
              product.priority != Priority.comfort &&
              product.shelfLifeMonths >= AppConfig.minimumShelfLifeMonths,
        )
        .toList();

    if (compatible.isEmpty) return const [];

    final chosen = <String, int>{};
    int calories = 0;

    void take(Product product, int quantity) {
      if (quantity <= 0) return;
      chosen[product.id] = (chosen[product.id] ?? 0) + quantity;
      calories += product.caloriesPerUnit * quantity;
    }

    Product? firstWhere(bool Function(Product) test) {
      for (final product in compatible) {
        if (test(product)) return product;
      }
      return null;
    }

    final preferVeg =
        needs.diets.contains('vegetarian') || needs.diets.contains('vegan');

    if (person.age <= 3) {
      final babyFood = firstWhere((product) => product.id == 'baby-food');
      final toddlerMeal = firstWhere((product) => product.id == 'toddler-meal');
      final toddlerSnack = firstWhere(
        (product) => product.id == 'toddler-snack',
      );
      final formula = firstWhere((product) => product.id == 'formula');
      if (babyFood != null) take(babyFood, 4);
      if (toddlerMeal != null) take(toddlerMeal, 6);
      if (toddlerSnack != null) take(toddlerSnack, 4);
      if (formula != null && (person.age < 1 || needs.formula)) {
        take(formula, 2);
      }
    } else {
      final meal =
          firstWhere(
            (product) =>
                product.id == (preferVeg ? 'meal-veg' : 'meal-chicken'),
          ) ??
          firstWhere(
            (product) =>
                product.category == LCategory.food &&
                product.id.startsWith('meal-'),
          );
      if (meal != null) take(meal, 1);
      final snack =
          firstWhere((product) => product.id == 'energy-bar') ??
          firstWhere((product) => product.id == 'dried-fruit');
      if (snack != null) take(snack, 1);

      final dense = [...compatible]
        ..sort((a, b) {
          final aDensity = a.caloriesPerUnit / max(a.weightKg, 0.01);
          final bDensity = b.caloriesPerUnit / max(b.weightKg, 0.01);
          return bDensity.compareTo(aDensity);
        });

      var guard = 0;
      while (calories < target && guard < 24) {
        guard++;
        for (final product in dense) {
          if (calories >= target) break;
          final cap = _capFor(product.id);
          final used = chosen[product.id] ?? 0;
          if (used >= cap) continue;
          final halfOfTarget = max(
            1,
            (target * 0.55 / product.caloriesPerUnit).floor(),
          );
          final room = target - calories;
          final wanted = max(1, (room / product.caloriesPerUnit).ceil());
          final quantity = min(cap - used, min(halfOfTarget, wanted));
          if (quantity <= 0) continue;
          take(product, quantity);
        }
      }
    }

    // Do not overshoot a small child's target by a whole extra unit.
    if (calories > target * 1.1) {
      final ids = chosen.keys.toList()..sort();
      for (final id in ids.reversed) {
        final product = productById(id);
        if (product == null || product.caloriesPerUnit <= 0) continue;
        while ((chosen[id] ?? 0) > 1 &&
            calories - product.caloriesPerUnit >= target * 0.9) {
          chosen[id] = chosen[id]! - 1;
          calories -= product.caloriesPerUnit;
        }
      }
    }

    final result = <(Product, int)>[];
    for (final entry in chosen.entries) {
      final product = productById(entry.key);
      if (product != null) result.add((product, entry.value));
    }
    // Stable order for deterministic tests.
    result.sort((a, b) => a.$1.id.compareTo(b.$1.id));
    return result;
  }

  int _capFor(String id) {
    switch (id) {
      case 'meal-chicken':
      case 'meal-veg':
        return 4;
      case 'canned-fish':
      case 'canned-meat':
      case 'canned-beans':
        return 4;
      case 'energy-bar':
        return 6;
      case 'nut-mix':
        return 2;
      case 'seeds':
        return 8;
      case 'crackers':
        return 2;
      case 'peanut-butter':
        return 2;
      case 'oats':
        return 2;

      case 'dried-fruit':
        return 4;
      case 'chocolate':
        return 2;
      case 'formula':
        return 1;
      case 'baby-food':
        return 8;
      default:
        return 4;
    }
  }

  List<_PoolLine> _waterPool(PlanRequest request) {
    final lines = <_PoolLine>[];
    for (final person in request.household) {
      final litres =
          AppConfig.waterLitresPerDay(
            person.group,
            comfort: request.tier == PlanTier.comfort,
          ) *
          3;
      final useSmallBottle =
          person.isToddler || (person.isChild && person.weightKg < 35);
      final bottle = productById(useSmallBottle ? 'water-05' : 'water-15');
      if (bottle == null) continue;
      lines.add(
        _PoolLine(
          product: bottle,
          quantity: max(1, (litres / bottle.weightKg).ceil()),
          beneficiaryId: person.id,
        ),
      );
    }
    final purification = productById('purification');
    if (purification != null) {
      lines.add(
        _PoolLine(
          product: purification,
          quantity: 1,
          beneficiaryId: request.household.first.id,
          shared: true,
        ),
      );
    }
    return lines;
  }

  Person? _strongestCarrier(PlanRequest request) {
    final adult = _strongestAdult(request);
    if (adult != null) return adult;
    Person? best;
    for (final person in request.household) {
      if (person.isToddler) continue;
      if (best == null || person.weightKg > best.weightKg) best = person;
    }
    return best;
  }

  Person? _strongestAdult(PlanRequest request) {
    Person? best;
    for (final person in request.household) {
      if (!person.isAdult) continue;
      if (best == null || person.weightKg > best.weightKg) best = person;
    }
    if (best != null) return best;
    for (final person in request.household) {
      if (person.isSenior) return person;
    }
    return null;
  }

  List<_PoolLine> _petPool(PlanRequest request) {
    final lines = <_PoolLine>[];
    final owner = _strongestCarrier(request);
    if (owner == null) return lines;
    void add(String id, {int quantity = 1}) {
      final product = productById(id);
      if (product == null) return;
      lines.add(
        _PoolLine(
          product: product,
          quantity: quantity,
          beneficiaryId: owner.id,
          shared: true,
          preferredCarrierId: owner.id,
        ),
      );
    }

    if (request.needs.petTypes.contains('dog') ||
        request.needs.petTypes.contains('pet')) {
      add('dog-food', quantity: 1);
      add('dog-dry');
      add('pet-leash');
      add('pet-bowl');
      add('pet-docs');
    }
    if (request.needs.petTypes.contains('cat')) {
      add('cat-food', quantity: 4);
      add('pet-bowl');
      add('pet-docs');
    }
    return lines;
  }

  List<_PoolLine> _comfortPool(PlanRequest request) {
    final lines = <_PoolLine>[];
    void add(String id, {int quantity = 1, Person? owner}) {
      final product = productById(id);
      if (product == null) return;
      final beneficiary = owner ?? request.household.first;
      if (!product.suitableForAge(beneficiary.age)) return;
      lines.add(
        _PoolLine(
          product: product,
          quantity: quantity,
          beneficiaryId: beneficiary.id,
          shared: true,
          preferredCarrierId: owner?.id,
        ),
      );
    }

    add('stove');
    add('radio');
    add('power-bank');
    add('usb-cable');
    add('batteries');
    return lines;
  }

  // ---------------------------------------------------------------------
  // Capacity fitting
  // ---------------------------------------------------------------------

  void _fitPersonal({
    required Person person,
    required List<Person> household,
    required Map<String, List<PlanItem>> bags,
    required Map<String, CarryLimit> limits,
    required List<String> dropped,
    required String languageCode,
  }) {
    final own = bags[person.id]!;
    final limit = limits[person.id]!.limitKg;
    var weight = _weightOf(own);
    if (weight <= limit) return;

    final protectedIds = <String>{
      if (person.isToddler) 'child-id',
      if (person.isToddler) 'child-toy',
      if (person.isChild) 'child-id',
      if (person.isChild) 'child-toy',
    };

    final candidates = [...own]
      ..sort((a, b) {
        final aProtected = protectedIds.contains(a.product.id);
        final bProtected = protectedIds.contains(b.product.id);
        if (aProtected != bProtected) return aProtected ? 1 : -1;
        final byPriority = b.product.priority.index.compareTo(
          a.product.priority.index,
        );
        if (byPriority != 0) return byPriority;
        final byProduct = a.product.id.compareTo(b.product.id);
        if (byProduct != 0) return byProduct;
        return b.weightKg.compareTo(a.weightKg);
      });

    for (final item in candidates) {
      if (weight <= limit) break;
      final carer = _findCarer(
        excludeId: person.id,
        itemWeight: item.weightKg,
        household: household,
        bags: bags,
        limits: limits,
      );
      if (carer == null) {
        // Remove from this bag; a critical gap will be reported.
        own.remove(item);
        weight -= item.weightKg;
        dropped.add('${item.product.name(languageCode)} ×${item.quantity}');
        continue;
      }
      own.remove(item);
      weight -= item.weightKg;
      bags[carer.id]!.add(
        PlanItem(
          product: item.product,
          quantity: item.quantity,
          carrierId: carer.id,
          beneficiaryId: person.id,
          shared: false,
          note: item.note,
        ),
      );
    }
  }

  Person? _findCarer({
    required String excludeId,
    required double itemWeight,
    required List<Person> household,
    required Map<String, List<PlanItem>> bags,
    required Map<String, CarryLimit> limits,
  }) {
    Person? best;
    var bestRoom = 0.0;
    for (final person in household) {
      if (person.id == excludeId) continue;
      if (!person.isAdult && !person.isSenior) continue;
      final room = limits[person.id]!.limitKg - _weightOf(bags[person.id]!);
      if (room >= itemWeight && room > bestRoom) {
        bestRoom = room;
        best = person;
      }
    }
    return best;
  }

  List<PlanItem> _distribute({
    required List<_PoolLine> pool,
    required PlanRequest request,
    required Map<String, double> remaining,
    required List<String> dropped,
    bool reportDropped = true,
  }) {
    // Critical first, then important, then comfort. Keep insertion order
    // inside each priority so the curated comfort order survives.
    final ordered = [...pool]
      ..sort((a, b) {
        final byPriority = a.product.priority.index.compareTo(
          b.product.priority.index,
        );
        if (byPriority != 0) return byPriority;
        final byProduct = a.product.id.compareTo(b.product.id);
        if (byProduct != 0) return byProduct;
        return a.beneficiaryId.compareTo(b.beneficiaryId);
      });

    final assigned = <PlanItem>[];
    for (final line in ordered) {
      final unitWeight = line.product.weightKg;
      var unitsLeft = line.quantity;
      while (unitsLeft > 0) {
        final carrier = _bestCarrier(
          request: request,
          remaining: remaining,
          unitWeight: unitWeight,
          product: line.product,
          preferredCarrierId: line.preferredCarrierId,
          strictPreferred: line.strictPreferred,
          adultsOnly: line.adultsOnly,
        );
        if (carrier == null) {
          if (reportDropped) {
            dropped.add(
              '${line.product.name(request.languageCode)} ×$unitsLeft',
            );
          }
          break;
        }
        remaining[carrier.id] = remaining[carrier.id]! - unitWeight;
        assigned.add(
          PlanItem(
            product: line.product,
            quantity: 1,
            carrierId: carrier.id,
            beneficiaryId: line.beneficiaryId,
            shared: line.shared,
          ),
        );
        unitsLeft--;
      }
    }
    return assigned;
  }

  bool _canCarry({
    required Person person,
    required PlanRequest request,
    required Map<String, double> remaining,
    required double unitWeight,
    required Product product,
    bool adultsOnly = false,
  }) {
    if (person.isToddler) return false;
    if (adultsOnly && !person.isAdult) return false;
    if (remaining[person.id]! < unitWeight) return false;
    if (product.isFood) {
      final needs = request.needs.needsFor(person.id);
      if (!product.compatibleWith(
        allergies: needs.allergies,
        diets: needs.diets,
      )) {
        return false;
      }
    }
    if (unitWeight > 1.0) return person.isAdult || person.isSenior;
    if (unitWeight > 0.5) {
      return person.isAdult || person.isSenior || person.age >= 10;
    }
    if (unitWeight > 0.25) {
      return person.isAdult || person.isSenior || person.age >= 6;
    }
    return true;
  }

  Person? _bestCarrier({
    required PlanRequest request,
    required Map<String, double> remaining,
    required double unitWeight,
    required Product product,
    String? preferredCarrierId,
    bool strictPreferred = false,
    bool adultsOnly = false,
  }) {
    if (preferredCarrierId != null) {
      for (final person in request.household) {
        if (person.id != preferredCarrierId) continue;
        if (_canCarry(
          person: person,
          request: request,
          remaining: remaining,
          unitWeight: unitWeight,
          product: product,
          adultsOnly: adultsOnly,
        )) {
          return person;
        }
      }
      if (strictPreferred) return null;
    }
    final allowed = request.household.where((person) {
      return _canCarry(
        person: person,
        request: request,
        remaining: remaining,
        unitWeight: unitWeight,
        product: product,
        adultsOnly: adultsOnly,
      );
    }).toList();

    if (allowed.isEmpty) return null;
    allowed.sort((a, b) {
      final byRoom = remaining[b.id]!.compareTo(remaining[a.id]!);
      if (byRoom != 0) return byRoom;
      return a.id.compareTo(b.id);
    });
    return allowed.first;
  }

  double _weightOf(List<PlanItem> items) =>
      items.fold(0.0, (sum, item) => sum + item.weightKg);
}

class _PoolLine {
  const _PoolLine({
    required this.product,
    required this.quantity,
    required this.beneficiaryId,
    this.shared = false,
    this.preferredCarrierId,
    this.strictPreferred = false,
    this.adultsOnly = false,
  });

  final Product product;
  final int quantity;
  final String beneficiaryId;
  final bool shared;
  final String? preferredCarrierId;
  final bool strictPreferred;
  final bool adultsOnly;
}
