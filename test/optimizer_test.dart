import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/config/app_config.dart';
import 'package:ready72/data/lt72.dart';
import 'package:ready72/domain/carry_limits.dart';
import 'package:ready72/domain/needs_parser.dart';
import 'package:ready72/domain/plan_optimizer.dart';
import 'package:ready72/models/needs.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/models/plan.dart';
import 'package:ready72/models/product.dart';

void main() {
  const optimizer = PlanOptimizer();
  const parser = NeedsParser();
  final household = DemoHousehold.people;
  final needs = parser.parse(DemoHousehold.needsText, household);

  PlanRequest request(PlanTier tier) => PlanRequest(
    household: household,
    needs: needs,
    tier: tier,
    languageCode: 'en',
  );

  group('optimiser', () {
    test('never exceeds a person carry limit', () {
      for (final tier in PlanTier.values) {
        final plan = optimizer.build(request(tier));
        for (final bag in plan.bags.values) {
          expect(
            bag.weightKg,
            lessThanOrEqualTo(bag.limitKg + 0.001),
            reason: '${bag.person.name} ${bag.weightKg} > ${bag.limitKg}',
          );
        }
      }
    });

    test('covers every critical LT72 category for the demo family', () {
      final plan = optimizer.build(request(PlanTier.comfort));
      expect(plan.gaps, isEmpty);
      expect(plan.coveredCategories, containsAll(criticalCategories));
    });

    test('every person gets at least 90 percent of their calories', () {
      for (final tier in PlanTier.values) {
        final plan = optimizer.build(request(tier));
        for (final person in household) {
          final target = AppConfig.dailyCalories(person.group) * 3;
          expect(
            plan.caloriesByPerson[person.id]!,
            greaterThanOrEqualTo(target * 0.9),
            reason: '${person.name} calories in ${tier.name}',
          );
        }
      }
    });

    test('Essential is never heavier or more expensive than Comfort', () {
      final essential = optimizer.build(request(PlanTier.essential));
      final comfort = optimizer.build(request(PlanTier.comfort));
      expect(essential.totalWeight, lessThanOrEqualTo(comfort.totalWeight));
      expect(essential.totalPrice, lessThanOrEqualTo(comfort.totalPrice));
    });

    test('deterministic for the same input', () {
      final first = optimizer.build(request(PlanTier.comfort));
      final second = optimizer.build(request(PlanTier.comfort));
      expect(first.totalPrice, closeTo(second.totalPrice, 0.0001));
      expect(first.totalWeight, closeTo(second.totalWeight, 0.0001));
      expect(
        first.items.map((item) => item.key).toList(),
        second.items.map((item) => item.key).toList(),
      );
    });

    test('all guardrail blockers pass for the demo family', () {
      final plan = optimizer.build(request(PlanTier.comfort));
      expect(plan.guardrails.blockersFired, 0);
      expect(
        plan.guardrails.fired.map((check) => check.id).toList(),
        isNot(contains('food-mandatory')),
      );
    });

    test('excludes allergens for the allergic person everywhere', () {
      final allergyNeeds = parser.parse(
        '${DemoHousehold.needsText} Maria has a severe nut allergy.',
        household,
      );
      final req = PlanRequest(
        household: household,
        needs: allergyNeeds,
        tier: PlanTier.comfort,
        languageCode: 'en',
      );
      final plan = optimizer.build(req);
      for (final item in plan.items) {
        final touchesOna =
            item.carrierId == 'p-ona' || item.beneficiaryId == 'p-ona';
        if (touchesOna) {
          expect(
            item.product.allergens.contains('nuts'),
            isFalse,
            reason: '${item.product.id} touches Ona',
          );
        }
      }
    });

    test('vegetarian and vegan diets are respected', () {
      final vegNeeds = parser.parse(
        'Rūta is vegetarian. Maria is vegan.',
        household,
      );
      final req = PlanRequest(
        household: household,
        needs: vegNeeds,
        tier: PlanTier.comfort,
        languageCode: 'en',
      );
      final plan = optimizer.build(req);
      for (final personId in ['p-ruta', 'p-ona']) {
        final person = household.firstWhere((p) => p.id == personId);
        for (final item in plan.items.where(
          (item) => item.beneficiaryId == personId && item.product.isFood,
        )) {
          expect(
            item.product.diets.contains('vegan') ||
                (personId == 'p-ruta' &&
                    item.product.diets.contains('vegetarian')),
            isTrue,
            reason: '${item.product.id} is not compatible with ${person.name}',
          );
        }
      }
    });

    test('prescribed medicine is a reminder, never a dose', () {
      final plan = optimizer.build(request(PlanTier.comfort));
      final prescription = plan.items.where(
        (item) => item.product.id == 'prescription',
      );
      expect(prescription, isNotEmpty);
      expect(prescription.first.priceEur, 0);
      expect(prescription.first.note, isNotNull);
      expect(
        plan.items
            .where((item) => item.product.category == LCategory.medication)
            .any(
              (item) =>
                  RegExp(r'\d+\s*(mg|units?)').hasMatch(item.product.nameEn),
            ),
        isFalse,
      );
    });

    test('heavy shared items never go to a child or toddler', () {
      final plan = optimizer.build(request(PlanTier.comfort));
      for (final item in plan.items.where((item) => item.shared)) {
        if (item.product.weightKg * item.quantity > 0.5) {
          final carrier = household.firstWhere((p) => p.id == item.carrierId);
          expect(
            carrier.isAdult || carrier.isSenior,
            isTrue,
            reason: item.product.id,
          );
        }
      }
    });

    test('three-adult household gets 1.5 l water bottles and no olive oil', () {
      final people = [
        const Person(id: 'a', name: 'A', age: 16, weightKg: 60),
        const Person(id: 'b', name: 'B', age: 19, weightKg: 70),
        const Person(id: 'c', name: 'C', age: 54, weightKg: 80),
      ];
      final plan = optimizer.build(
        PlanRequest(
          household: people,
          needs: ParsedNeeds.empty(),
          tier: PlanTier.comfort,
          languageCode: 'en',
        ),
      );
      expect(plan.items.any((item) => item.product.id == 'olive-oil'), isFalse);
      final water = plan.items.where((item) => item.product.id == 'water-15');
      expect(water, isNotEmpty);
      expect(water.fold(0, (sum, item) => sum + item.quantity), 6);
      expect(water.every((item) => item.product.weightKg > 1), isTrue);
      expect(plan.items.every((item) => item.quantity <= 8), isTrue);
      expect(plan.guardrails.blockersFired, 0);
    });

    test('single-person Comfort does not report dropped items', () {
      for (final people in [
        [const Person(id: 's', name: 'S', age: 75, weightKg: 60)],
        [
          const Person(id: 'a', name: 'A', age: 30, weightKg: 70),
          const Person(id: 'b', name: 'B', age: 0, weightKg: 3.4),
        ],
      ]) {
        final plan = optimizer.build(
          PlanRequest(
            household: people,
            needs: ParsedNeeds.empty(),
            tier: PlanTier.comfort,
            languageCode: 'en',
          ),
        );
        expect(plan.dropped, isEmpty);
      }
    });

    test('limit map is reported for every person', () {
      final plan = optimizer.build(request(PlanTier.essential));
      for (final person in household) {
        final limit = CarryLimits.compute(person, needs.needsFor(person.id));
        expect(plan.bags[person.id]!.limitKg, limit.limitKg);
      }
    });
    test('demo plans are in the approved price band with nothing dropped', () {
      for (final tier in PlanTier.values) {
        final plan = optimizer.build(request(tier));
        expect(plan.dropped, isEmpty, reason: tier.name);
        expect(plan.guardrails.blockersFired, 0, reason: tier.name);
        final min = tier == PlanTier.essential ? 250.0 : 380.0;
        final max = tier == PlanTier.essential ? 400.0 : 560.0;
        expect(plan.totalPrice, inInclusiveRange(min, max), reason: tier.name);
      }
    });

    test('children-only household with a pet does not crash', () {
      final people = [const Person(id: 'c', name: 'Kid', age: 8, weightKg: 25)];
      final parsed = parser.parse('We have a dog.', people);
      for (final tier in PlanTier.values) {
        final plan = optimizer.build(
          PlanRequest(
            household: people,
            needs: parsed,
            tier: tier,
            languageCode: 'en',
          ),
        );
        expect(plan.bags, isNotEmpty);
      }
    });

    test('vegan and vegetarian households have no false allergen blockers', () {
      for (final text in ['V is vegan.', 'V is vegetarian.']) {
        final people = [
          const Person(id: 'v', name: 'V', age: 30, weightKg: 70),
        ];
        final plan = optimizer.build(
          PlanRequest(
            household: people,
            needs: parser.parse(text, people),
            tier: PlanTier.essential,
            languageCode: 'en',
          ),
        );
        expect(plan.guardrails.blockersFired, 0, reason: text);
      }
    });

    test('toddler food is age-appropriate and capped', () {
      final plan = optimizer.build(request(PlanTier.essential));
      final mia = plan.bags['p-mia']!;
      for (final item in plan.items.where(
        (item) => item.beneficiaryId == 'p-mia' && item.product.isFood,
      )) {
        expect(item.product.id, isNot('meal-chicken'));
        expect(item.product.id, isNot('nut-mix'));
        expect(item.product.id, isNot('seeds'));
      }
      expect(plan.caloriesByPerson['p-mia'], lessThan(3000 * 1.1));
      expect(plan.caloriesByPerson['p-mia'], greaterThan(3000 * 0.9));
      expect(mia.weightKg, lessThanOrEqualTo(mia.limitKg + 0.001));
    });
  });
}
