import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/data/catalogue.dart';
import 'package:ready72/models/product.dart';

void main() {
  test('catalogue ids are unique', () {
    final ids = <String>{};
    for (final product in catalogue) {
      expect(ids.add(product.id), isTrue, reason: 'duplicate id ${product.id}');
    }
  });

  test('prices, weights and shelf lives are usable fixture data', () {
    for (final product in catalogue) {
      expect(product.priceEur, isNonNegative, reason: product.id);
      expect(product.weightKg, greaterThan(0), reason: product.id);
      expect(
        product.shelfLifeMonths,
        greaterThanOrEqualTo(0),
        reason: product.id,
      );
      expect(
        product.caloriesPerUnit,
        greaterThanOrEqualTo(0),
        reason: product.id,
      );
      expect(product.ageMin, inInclusiveRange(0, 18), reason: product.id);
      expect(product.ageMax, inInclusiveRange(0, 120), reason: product.id);
      expect(
        product.ageMin,
        lessThanOrEqualTo(product.ageMax),
        reason: product.id,
      );
    }
  });

  test('every product has a store, search URL and bilingual name', () {
    for (final product in catalogue) {
      expect(Store.values, contains(product.store));
      expect(Uri.tryParse(product.url)?.hasScheme, isTrue, reason: product.id);
      expect(product.nameEn.trim(), isNotEmpty, reason: product.id);
      expect(product.nameLt.trim(), isNotEmpty, reason: product.id);
      if (product.verified) {
        expect(product.url, contains('/p/'), reason: product.id);
        expect(product.priceEur, greaterThan(0), reason: product.id);
      }
    }
  });

  test('store links use a Lithuanian search, not a dead product page', () {
    for (final product in catalogue) {
      final uri = Uri.parse(product.orderUrl);
      expect(uri.path, isNot(contains('/p/')), reason: product.id);
      expect(
        product.orderUrl,
        isNot(product.store.homeUrl),
        reason: product.id,
      );
      final queryKey =
          product.store == Store.decathlon || product.store == Store.rimi
          ? 'query'
          : 'q';
      expect(uri.queryParameters[queryKey], product.nameLt, reason: product.id);
    }

    final peanut = catalogue.firstWhere((p) => p.id == 'peanut-butter');
    expect(peanut.orderUrl, startsWith('https://barbora.lt/search?q='));
    expect(
      Uri.parse(peanut.orderUrl).queryParameters['q'],
      'Žemės riešutų sviestas',
    );

    final tent = catalogue.firstWhere((p) => p.id == 'tent');
    expect(
      tent.orderUrl,
      startsWith('https://www.decathlon.lt/search/?query='),
    );
  });

  test('food rows carry calories and a shelf life of at least 12 months', () {
    for (final product in catalogue.where((p) => p.isFood)) {
      expect(product.caloriesPerUnit, greaterThan(0), reason: product.id);
      expect(
        product.shelfLifeMonths,
        greaterThanOrEqualTo(12),
        reason: product.id,
      );
    }
  });

  test('every store has products', () {
    for (final store in Store.values) {
      expect(
        catalogue.where((product) => product.store == store),
        isNotEmpty,
        reason: store.name,
      );
    }
  });
}
