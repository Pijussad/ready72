import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/data/catalogue.dart';
import 'package:ready72/data/offer_matches.dart';
import 'package:ready72/domain/needs_parser.dart';
import 'package:ready72/domain/plan_optimizer.dart';
import 'package:ready72/models/offer_match.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/models/plan.dart';

Map<String, OfferMatch> _loadFromDisk() {
  final raw =
      jsonDecode(File('assets/catalogue/matches.json').readAsStringSync())
          as Map<String, dynamic>;
  return (raw['matches'] as Map<String, dynamic>).map(
    (id, row) => MapEntry(id, OfferMatch.fromJson(row as Map<String, dynamic>)),
  );
}

void main() {
  const optimizer = PlanOptimizer();
  final household = DemoHousehold.people;
  final needs = const NeedsParser().parse(DemoHousehold.needsText, household);

  PlanRequest request(PlanTier tier) => PlanRequest(
    household: household,
    needs: needs,
    tier: tier,
    languageCode: 'en',
  );

  tearDown(() => OfferMatches.install(const {}));

  test('matches only reference real curated product ids', () {
    final matches = _loadFromDisk();
    expect(matches.length, greaterThan(50));
    for (final id in matches.keys) {
      expect(fixtureCatalogue.any((p) => p.id == id), isTrue, reason: id);
    }
  });

  test('matched products take real price and URL but keep safety inputs', () {
    final matches = _loadFromDisk();
    OfferMatches.install(matches);
    for (final fixture in fixtureCatalogue) {
      final match = matches[fixture.id];
      if (match == null) continue;
      final resolved = productById(fixture.id)!;
      expect(resolved.priceEur, match.priceEur);
      expect(resolved.orderUrl, match.url);
      expect(resolved.verified, isTrue);
      expect(resolved.weightKg, fixture.weightKg, reason: fixture.id);
      expect(resolved.caloriesPerUnit, fixture.caloriesPerUnit);
      expect(resolved.shelfLifeMonths, fixture.shelfLifeMonths);
      expect(resolved.allergens, fixture.allergens);
      expect(resolved.ageMin, fixture.ageMin);
      expect(resolved.ageMax, fixture.ageMax);
    }
  });

  test('plan stays safe with real prices and has fewer unverified lines', () {
    final before = optimizer.build(request(PlanTier.comfort));
    OfferMatches.install(_loadFromDisk());
    for (final tier in PlanTier.values) {
      final plan = optimizer.build(request(tier));
      expect(plan.gaps, isEmpty);
      for (final bag in plan.bags.values) {
        expect(bag.weightKg, lessThanOrEqualTo(bag.limitKg + 0.001));
      }
    }
    final after = optimizer.build(request(PlanTier.comfort));
    expect(after.unverifiedPriceCount, lessThan(before.unverifiedPriceCount));
    expect(after.totalWeight, closeTo(before.totalWeight, 0.5));
  });

  test('without matches the fixture catalogue is untouched', () {
    expect(productById('tent')!.priceEur, 89.99);
    expect(productById('tent')!.offer, isNull);
  });
}
