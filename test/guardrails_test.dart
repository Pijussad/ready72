import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/domain/carry_limits.dart';
import 'package:ready72/domain/needs_parser.dart';
import 'package:ready72/domain/plan_optimizer.dart';
import 'package:ready72/domain/guardrails.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/models/plan.dart';
import 'package:ready72/models/product.dart';

void main() {
  final household = DemoHousehold.people;
  final needs = const NeedsParser().parse(DemoHousehold.needsText, household);
  final request = PlanRequest(
    household: household,
    needs: needs,
    tier: PlanTier.comfort,
    languageCode: 'en',
  );
  final good = const PlanOptimizer().build(request);
  final limits = {
    for (final person in household)
      person.id: CarryLimits.compute(person, needs.needsFor(person.id)),
  };

  PlanResult variant({
    List<PlanItem>? items,
    Map<String, PersonBag>? bags,
    Map<String, int>? calories,
    Set<LCategory>? covered,
    Set<LCategory>? gaps,
  }) {
    return PlanResult(
      tier: good.tier,
      items: items ?? good.items,
      bags: bags ?? good.bags,
      coveredCategories: covered ?? good.coveredCategories,
      gaps: gaps ?? good.gaps,
      dropped: good.dropped,
      caloriesByPerson: calories ?? good.caloriesByPerson,
      guardrails: const GuardrailReport([]),
    );
  }

  bool failed(GuardrailReport report, String id) {
    final check = report.checks.firstWhere((check) => check.id == id);
    return !check.passed;
  }

  test('good plan passes all blockers', () {
    final report = PlanGuardrails.validate(
      request: request,
      plan: good,
      limits: limits,
    );
    expect(report.blockersFired, 0);
  });

  test('deliberate failure: no food is caught', () {
    final items = good.items
        .where((item) => item.product.category != LCategory.food)
        .toList();
    final bad = variant(
      items: items,
      calories: {for (final person in household) person.id: 0},
    );
    final report = PlanGuardrails.validate(
      request: request,
      plan: bad,
      limits: limits,
    );
    expect(failed(report, 'food-mandatory'), isTrue);
  });

  test('deliberate failure: an overweight bag is caught', () {
    final bags = Map<String, PersonBag>.from(good.bags);
    final target = bags['p-jonas']!;
    bags['p-jonas'] = PersonBag(
      person: target.person,
      limitKg: 1.0,
      items: target.items,
    );
    final report = PlanGuardrails.validate(
      request: request,
      plan: variant(bags: bags),
      limits: limits,
    );
    expect(failed(report, 'carry-limit'), isTrue);
  });

  test('deliberate failure: an invented product is caught', () {
    final invented = Product(
      id: 'invented-widget',
      nameEn: 'Invented emergency widget',
      nameLt: 'Išgalvotas daiktas',
      category: LCategory.tools,
      store: Store.barbora,
      priceEur: 10,
      weightKg: 0.1,
      shelfLifeMonths: 12,
      allergens: const {},
      diets: const {},
      caloriesPerUnit: 0,
      priority: Priority.important,
      ageMin: 0,
      ageMax: 120,
      tags: const {},
      url: 'https://example.invalid',
    );
    final item = PlanItem(
      product: invented,
      quantity: 1,
      carrierId: 'p-jonas',
      beneficiaryId: 'p-jonas',
    );
    final items = [...good.items, item];
    final bags = Map<String, PersonBag>.from(good.bags);
    final target = bags['p-jonas']!;
    bags['p-jonas'] = PersonBag(
      person: target.person,
      limitKg: target.limitKg,
      items: [...target.items, item],
    );
    final report = PlanGuardrails.validate(
      request: request,
      plan: variant(items: items, bags: bags),
      limits: limits,
    );
    expect(failed(report, 'product-exists'), isTrue);
  });

  test('deliberate failure: a wrong catalogue price is caught', () {
    final original = good.items.first.product;
    final wrong = Product(
      id: original.id,
      nameEn: original.nameEn,
      nameLt: original.nameLt,
      category: original.category,
      store: original.store,
      priceEur: original.priceEur + 10,
      weightKg: original.weightKg,
      shelfLifeMonths: original.shelfLifeMonths,
      allergens: original.allergens,
      diets: original.diets,
      caloriesPerUnit: original.caloriesPerUnit,
      priority: original.priority,
      ageMin: original.ageMin,
      ageMax: original.ageMax,
      tags: original.tags,
      url: original.url,
    );
    final badItem = PlanItem(
      product: wrong,
      quantity: good.items.first.quantity,
      carrierId: good.items.first.carrierId,
      beneficiaryId: good.items.first.beneficiaryId,
    );
    final items = [badItem, ...good.items.skip(1)];
    final report = PlanGuardrails.validate(
      request: request,
      plan: variant(items: items),
      limits: limits,
    );
    expect(failed(report, 'price-snapshot'), isTrue);
  });

  test('deliberate failure: missing water is caught', () {
    final items = good.items
        .where((item) => item.product.category != LCategory.water)
        .toList();
    final covered = {...good.coveredCategories}..remove(LCategory.water);
    final gaps = {...good.gaps, LCategory.water};
    final report = PlanGuardrails.validate(
      request: request,
      plan: variant(items: items, covered: covered, gaps: gaps),
      limits: limits,
    );
    expect(failed(report, 'water-mandatory'), isTrue);
    expect(failed(report, 'critical-coverage'), isTrue);
  });

  test('deliberate failure: a medicine dose is caught', () {
    final doseProduct = Product(
      id: 'insulin-dose',
      nameEn: 'Insulin 20 units',
      nameLt: 'Insulinas 20 vienetų',
      category: LCategory.medication,
      store: Store.eurovaistine,
      priceEur: 0,
      weightKg: 0.1,
      shelfLifeMonths: 0,
      allergens: const {},
      diets: const {},
      caloriesPerUnit: 0,
      priority: Priority.critical,
      ageMin: 0,
      ageMax: 120,
      tags: const {'userSupplied'},
      url: 'https://example.invalid',
    );
    final item = PlanItem(
      product: doseProduct,
      quantity: 1,
      carrierId: 'p-ona',
      beneficiaryId: 'p-ona',
    );
    final items = [...good.items, item];
    final report = PlanGuardrails.validate(
      request: request,
      plan: variant(items: items),
      limits: limits,
    );
    expect(failed(report, 'no-doses'), isTrue);
  });
}
