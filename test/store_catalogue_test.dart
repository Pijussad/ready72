import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/data/store_catalogue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generated catalogue loads with real prices and three stores', () async {
    final catalogue = await StoreCatalogue.load();
    expect(catalogue.offers.length, greaterThan(30000));
    expect(catalogue.storeCounts['barbora'], greaterThan(20000));
    expect(catalogue.storeCounts['decathlon'], greaterThan(3000));
    expect(catalogue.storeCounts['eurovaistine'], greaterThan(4000));
    for (final offer in catalogue.offers.take(500)) {
      expect(offer.priceEur, greaterThan(0));
      expect(Uri.tryParse(offer.url)?.hasScheme, isTrue);
      expect(offer.name.trim(), isNotEmpty);
    }
  });

  test('search uses Lithuanian names and returns exact store rows', () async {
    final catalogue = await StoreCatalogue.load();
    final peanut = catalogue.search('žemės riešutų sviestas', limit: 10);
    expect(peanut, isNotEmpty);
    expect(peanut.first.name.toLowerCase(), contains('sviest'));
    expect(peanut.first.store, anyOf('barbora', 'decathlon'));
    expect(peanut.first.url, startsWith('https://'));
    expect(peanut.first.priceEur, greaterThan(0));

    final tent = catalogue.search('palapinė', stores: {'decathlon'}, limit: 10);
    expect(tent, isNotEmpty);
    expect(tent.every((offer) => offer.store == 'decathlon'), isTrue);
  });
}
