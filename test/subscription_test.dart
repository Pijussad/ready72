import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/models/subscription.dart';

void main() {
  test('demo family totals 16 EUR', () {
    final quote = SubscriptionQuote.forHousehold(DemoHousehold.people);
    expect(quote.totalEur, 16.0);
  });

  test('child rate ends at 14 and adult starts at 15', () {
    final at14 = SubscriptionQuote.forHousehold(const [
      Person(id: 'a', name: 'A', age: 14, weightKg: 50),
    ]);
    final at15 = SubscriptionQuote.forHousehold(const [
      Person(id: 'b', name: 'B', age: 15, weightKg: 50),
    ]);
    expect(at14.totalEur, 5.0);
    expect(at15.totalEur, 4.0);
  });

  test('senior pays 3 EUR', () {
    final quote = SubscriptionQuote.forHousehold(const [
      Person(id: 's', name: 'S', age: 71, weightKg: 62),
    ]);
    expect(quote.totalEur, 3.0);
  });

  test('empty household costs nothing', () {
    expect(SubscriptionQuote.forHousehold(const []).totalEur, 0.0);
  });
}
