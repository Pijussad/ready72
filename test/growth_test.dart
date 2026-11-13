import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/domain/growth.dart';
import 'package:ready72/models/person.dart';

void main() {
  final now = DateTime(2026, 11, 13);

  test('young children are reviewed every six months', () {
    final growth = project(
      const Person(id: 'm', name: 'Mia', age: 2, weightKg: 13),
      now: now,
    );
    expect(growth.reviewMonths, 6);
    expect(growth.nextReview, DateTime(2027, 5, 13));
    expect(growth.nextHeightCm, greaterThan(growth.currentHeightCm));
    expect(growth.clothingSize, isNotEmpty);
    expect(growth.nextClothingSize, isNotEmpty);
  });

  test('older children and adults are reviewed every twelve months', () {
    expect(
      project(
        const Person(id: 'c', name: 'C', age: 10, weightKg: 30),
        now: now,
      ).reviewMonths,
      12,
    );
    expect(
      project(
        const Person(id: 'a', name: 'A', age: 34, weightKg: 82),
        now: now,
      ).reviewMonths,
      12,
    );
    expect(
      project(
        const Person(id: 'a', name: 'A', age: 34, weightKg: 82),
        now: now,
      ).nextReview,
      DateTime(2027, 11, 13),
    );
  });

  test('expiry reminders are 60 and 14 days before expiry', () {
    final expiry = DateTime(2027, 6, 1);
    final reminders = ExpiryReminders.forExpiry(expiry);
    expect(reminders.sixtyDays, DateTime(2027, 4, 2));
    expect(reminders.fourteenDays, DateTime(2027, 5, 18));
  });
}
