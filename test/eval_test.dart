import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/data/lt72.dart';
import 'package:ready72/domain/needs_parser.dart';
import 'package:ready72/domain/plan_optimizer.dart';
import 'package:ready72/models/needs.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/models/plan.dart';
import 'package:ready72/models/product.dart';

class EvalCase {
  const EvalCase({
    required this.name,
    required this.people,
    required this.text,
    required this.expectedTokens,
    this.expectNoNuts = false,
  });

  final String name;
  final List<Person> people;
  final String text;
  final List<String> expectedTokens;
  final bool expectNoNuts;
}

void main() {
  const parser = NeedsParser();
  const optimizer = PlanOptimizer();

  final cases = <EvalCase>[
    EvalCase(
      name: 'demo-en',
      people: DemoHousehold.people,
      text: DemoHousehold.needsText,
      expectedTokens: [
        'p-ona:diabetes',
        'p-ona:insulin',
        'p-mia:diapers',
        'pet:dog',
      ],
    ),
    EvalCase(
      name: 'vague',
      people: const [Person(id: 'a', name: 'Alex', age: 30, weightKg: 70)],
      text: 'Not sure, just a normal bag please.',
      expectedTokens: [],
    ),
    EvalCase(
      name: 'insulin-senior',
      people: const [Person(id: 'a', name: 'Marta', age: 72, weightKg: 60)],
      text: 'Marta has diabetes and takes insulin.',
      expectedTokens: ['a:diabetes', 'a:insulin'],
    ),
    EvalCase(
      name: 'nut-allergy',
      people: const [
        Person(id: 'a', name: 'Tomas', age: 35, weightKg: 80),
        Person(id: 'b', name: 'Ieva', age: 33, weightKg: 60),
      ],
      text: 'Ieva has a severe nut allergy.',
      expectedTokens: ['b:nuts'],
      expectNoNuts: true,
    ),
    EvalCase(
      name: 'newborn',
      people: const [
        Person(id: 'a', name: 'Aistė', age: 29, weightKg: 62),
        Person(id: 'b', name: 'Baby', age: 0, weightKg: 3.4),
      ],
      text: 'Baby needs formula and nappies.',
      expectedTokens: ['b:formula', 'b:diapers'],
    ),
    EvalCase(
      name: 'wheelchair',
      people: const [
        Person(id: 'a', name: 'Darius', age: 44, weightKg: 85),
        Person(id: 'b', name: 'Rasa', age: 41, weightKg: 65),
      ],
      text: 'Darius uses a wheelchair and has back pain.',
      expectedTokens: ['a:mobility', 'a:back'],
    ),
    EvalCase(
      name: 'two-pets',
      people: const [Person(id: 'a', name: 'Jurgis', age: 38, weightKg: 78)],
      text: 'We have a dog and a cat.',
      expectedTokens: ['pet:dog', 'pet:cat'],
    ),
    EvalCase(
      name: 'lithuanian-vegan',
      people: const [
        Person(id: 'a', name: 'Liepa', age: 28, weightKg: 58),
        Person(id: 'b', name: 'Mia', age: 6, weightKg: 20),
      ],
      text: 'Liepa yra veganė. Mia turi riešutų alergiją. Turime katę.',
      expectedTokens: ['a:vegan', 'b:nuts', 'pet:cat'],
      expectNoNuts: true,
    ),
  ];

  test('evaluation harness hard metrics', () {
    var extractionHits = 0;
    var extractionTotal = 0;
    var weightPass = 0;
    var coveragePass = 0;
    var casesWithAllergies = 0;
    var allergyPass = 0;
    var doseHits = 0;
    final rows = <String>[];

    for (final evalCase in cases) {
      final needs = parser.parse(evalCase.text, evalCase.people);
      final plan = optimizer.build(
        PlanRequest(
          household: evalCase.people,
          needs: needs,
          tier: PlanTier.comfort,
          languageCode: 'en',
        ),
      );

      extractionTotal += evalCase.expectedTokens.length;
      for (final token in evalCase.expectedTokens) {
        extractionHits += _tokenMatches(token, needs) ? 1 : 0;
      }

      final weightOk = plan.bags.values.every((bag) => bag.withinLimit);
      weightPass += weightOk ? 1 : 0;

      final covered = criticalCategories.difference(plan.coveredCategories);
      coveragePass += covered.isEmpty ? 1 : 0;

      final allergyNeeds = needs.byPerson.values
          .where((person) => person.allergies.isNotEmpty)
          .toList();
      var allergiesOk = true;
      for (final personNeeds in allergyNeeds) {
        for (final item in plan.items) {
          final touches =
              item.carrierId == personNeeds.personId ||
              item.beneficiaryId == personNeeds.personId;
          if (!touches) continue;
          if (item.product.allergens.any(personNeeds.allergies.contains)) {
            allergiesOk = false;
          }
        }
      }
      if (allergyNeeds.isNotEmpty) {
        casesWithAllergies++;
        allergyPass += allergiesOk ? 1 : 0;
      }

      for (final item in plan.items) {
        if (item.product.category == LCategory.medication &&
            RegExp(
              r'\b\d+\s*(mg|mcg|units?|iu)\b',
              caseSensitive: false,
            ).hasMatch('${item.product.nameEn} ${item.note ?? ''}')) {
          doseHits++;
        }
      }

      rows.add(
        '${evalCase.name.padRight(18)} kcal=${plan.caloriesByPerson.values.join('/')} '
        'weight=${plan.totalWeight.toStringAsFixed(1)} '
        'gaps=${covered.map((c) => c.name).join(',')} '
        'allergy=${allergiesOk ? 'ok' : 'FAIL'}',
      );
    }

    final extraction = extractionTotal == 0
        ? 1.0
        : extractionHits / extractionTotal;
    final weightRate = weightPass / cases.length;
    final coverageRate = coveragePass / cases.length;
    final allergyRate = casesWithAllergies == 0
        ? 1.0
        : allergyPass / casesWithAllergies;

    // ignore: avoid_print
    print('\nAI + optimiser evaluation');
    for (final row in rows) {
      // ignore: avoid_print
      print(row);
    }
    // ignore: avoid_print
    print(
      'needs extraction ${(extraction * 100).toStringAsFixed(0)}% · '
      'weight ${(weightRate * 100).toStringAsFixed(0)}% · '
      'critical coverage ${(coverageRate * 100).toStringAsFixed(0)}% · '
      'allergy ${(allergyRate * 100).toStringAsFixed(0)}% · doses $doseHits',
    );

    expect(extraction, greaterThanOrEqualTo(0.9));
    expect(weightRate, 1.0);
    expect(allergyRate, 1.0);
    expect(coverageRate, greaterThanOrEqualTo(0.9));
    expect(doseHits, 0);
  });
}

bool _tokenMatches(String token, ParsedNeeds needs) {
  final parts = token.split(':');
  if (parts[0] == 'pet') {
    return needs.petTypes.contains(parts[1]);
  }
  final person = needs.needsFor(parts[0]);
  final value = parts[1];
  switch (value) {
    case 'diabetes':
    case 'asthma':
    case 'hypertension':
      return person.conditions.contains(value);
    case 'insulin':
      return person.medications.contains('insulin');
    case 'nuts':
    case 'gluten':
    case 'dairy':
      return person.allergies.contains(value);
    case 'vegan':
    case 'vegetarian':
      return person.diets.contains(value);
    case 'diapers':
      return person.diapers;
    case 'formula':
      return person.formula;
    case 'mobility':
      return person.mobilityAid;
    case 'back':
      return person.backProblem;
    default:
      return false;
  }
}
