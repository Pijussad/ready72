import 'dart:convert';
import 'dart:io';

import 'package:ready72/domain/growth.dart';
import 'package:ready72/domain/needs_parser.dart';
import 'package:ready72/domain/plan_optimizer.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/models/plan.dart';
import 'package:ready72/models/subscription.dart';

void main() {
  const parser = NeedsParser();
  final needs = parser.parse(DemoHousehold.needsText, DemoHousehold.people);
  final plan = PlanOptimizer().build(
    PlanRequest(
      household: DemoHousehold.people,
      needs: needs,
      tier: PlanTier.comfort,
      languageCode: 'en',
    ),
  );
  final subscription = SubscriptionQuote.forHousehold(DemoHousehold.people);

  final data = {
    'tier': 'comfort',
    'totalPrice': plan.totalPrice,
    'totalWeight': plan.totalWeight,
    'dropped': plan.dropped.length,
    'blockers': plan.guardrails.blockersFired,
    'checks': plan.guardrails.checks.length,
    'checksPassed': plan.guardrails.checks.where((c) => c.passed).length,
    'coverage': plan.coverageScore,
    'subscriptionMonthly': subscription.totalEur,
    'calories': plan.caloriesByPerson,
    'bags': [
      for (final bag in plan.bags.values)
        {
          'id': bag.person.id,
          'name': bag.person.name,
          'age': bag.person.age,
          'weightKg': bag.person.weightKg,
          'limitKg': bag.limitKg,
          'bagKg': bag.weightKg,
          'fill': bag.fillRatio,
          'items': bag.itemCount,
          'lines': bag.items.length,
          'withinLimit': bag.withinLimit,
        },
    ],
    'items': [
      for (final item in plan.items)
        {
          'product': item.product.nameEn,
          'quantity': item.quantity,
          'carrier': item.carrierId,
          'beneficiary': item.beneficiaryId,
          'shared': item.shared,
          'weightKg': item.weightKg,
          'priceEur': item.priceEur,
          'category': item.product.category.name,
          'store': item.product.store.name,
        },
    ],
    'growth': [
      for (final person in DemoHousehold.people)
        if (person.isChild || person.isToddler)
          {
            'name': person.name,
            'age': person.age,
            'currentHeightCm': project(person).currentHeightCm,
            'nextHeightCm': project(person).nextHeightCm,
            'clothingSize': project(person).clothingSize,
            'nextClothingSize': project(person).nextClothingSize,
            'reviewMonths': project(person).reviewMonths,
          },
    ],
    'guardrails': [
      for (final check in plan.guardrails.checks)
        {'id': check.id, 'passed': check.passed, 'blocker': check.blocker},
    ],
  };

  final out = File('video/src/data/plan.json');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  stdout.writeln('wrote ${out.path}');
}
