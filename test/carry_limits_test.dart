import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/domain/carry_limits.dart';
import 'package:ready72/models/needs.dart';
import 'package:ready72/models/person.dart';

void main() {
  group('carry limits', () {
    test('70 kg adult gives 14 kg', () {
      final limit = CarryLimits.computeFor(
        const Person(id: 'a', name: 'A', age: 30, weightKg: 70),
      );
      expect(limit.limitKg, closeTo(14.0, 0.001));
    });

    test('absolute cap applies to heavy adults', () {
      final limit = CarryLimits.computeFor(
        const Person(id: 'a', name: 'A', age: 30, weightKg: 100),
      );
      expect(limit.limitKg, 15.0);
    });

    test('very heavy adults get a lower cap than body-weight percentage', () {
      final heavy = CarryLimits.computeFor(
        const Person(id: 'a', name: 'A', age: 30, weightKg: 160),
      );
      final veryHeavy = CarryLimits.computeFor(
        const Person(id: 'b', name: 'B', age: 30, weightKg: 200),
      );
      expect(heavy.limitKg, 12.0);
      expect(veryHeavy.limitKg, 10.0);
    });

    test('age group boundaries', () {
      expect(
        CarryLimits.computeFor(
          const Person(id: 'c', name: 'C', age: 14, weightKg: 50),
        ).limitKg,
        closeTo(7.5, 0.001),
      );
      expect(
        CarryLimits.computeFor(
          const Person(id: 'c', name: 'C', age: 15, weightKg: 50),
        ).limitKg,
        closeTo(10.0, 0.001),
      );
      expect(
        CarryLimits.computeFor(
          const Person(id: 's', name: 'S', age: 65, weightKg: 50),
        ).limitKg,
        closeTo(6.0, 0.001),
      );
    });

    test('toddler limit is 3 percent of actual weight', () {
      final limit = CarryLimits.computeFor(
        const Person(id: 't', name: 'T', age: 2, weightKg: 13),
      );
      expect(limit.limitKg, closeTo(0.39, 0.001));
    });

    test('very low weight is clamped to the safe input minimum', () {
      final limit = CarryLimits.computeFor(
        const Person(id: 'x', name: 'X', age: 30, weightKg: 0),
      );
      expect(limit.limitKg, closeTo(0.4, 0.001));
    });

    test('back problem, pregnancy and mobility reduce the limit', () {
      final person = const Person(id: 'a', name: 'A', age: 30, weightKg: 70);
      final needs = PersonNeeds(personId: 'a', backProblem: true);
      expect(CarryLimits.compute(person, needs).limitKg, closeTo(8.4, 0.001));
      final pregnant = PersonNeeds(personId: 'a', pregnant: true);
      expect(
        CarryLimits.compute(person, pregnant).limitKg,
        closeTo(8.4, 0.001),
      );
      final mobility = PersonNeeds(personId: 'a', mobilityAid: true);
      expect(
        CarryLimits.compute(person, mobility).limitKg,
        closeTo(8.4, 0.001),
      );
      expect(CarryLimits.compute(person, mobility).reduced, isTrue);
    });
  });
}
