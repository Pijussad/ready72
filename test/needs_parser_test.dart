import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/domain/needs_parser.dart';
import 'package:ready72/models/person.dart';

void main() {
  const parser = NeedsParser();
  final household = DemoHousehold.people;

  test('demo English text maps to the right people', () {
    final needs = parser.parse(DemoHousehold.needsText, household);
    final ona = needs.needsFor('p-ona');
    final mia = needs.needsFor('p-mia');
    expect(ona.conditions, contains('diabetes'));
    expect(ona.medications, isEmpty);
    expect(ona.needsCooling, isTrue);
    expect(mia.diapers, isTrue);
    expect(needs.petTypes, contains('dog'));
  });

  test('Lithuanian text maps too', () {
    final text =
        'Močiutei Mariai yra diabetas, ji vartoja insulį. Mia dar nešioja sauskelnes. Turime šunį.';
    final needs = parser.parse(text, household);
    expect(needs.needsFor('p-ona').conditions, contains('diabetes'));
    expect(needs.needsFor('p-ona').medications, contains('insulin'));
    expect(needs.needsFor('p-mia').diapers, isTrue);
    expect(needs.petTypes, contains('dog'));
  });

  test('allergies and diets are canonicalised', () {
    final needs = parser.parse(
      'Rūta is vegetarian and has a nut allergy. Maria is dairy free.',
      household,
    );
    expect(needs.needsFor('p-ruta').allergies, contains('nuts'));
    expect(needs.needsFor('p-ruta').diets, contains('vegetarian'));
    expect(needs.needsFor('p-ona').diets, contains('dairyFree'));
  });

  test('mobility and pregnancy are flagged for a lower carry limit', () {
    final needs = parser.parse(
      'Rūta is pregnant. Jonas uses a wheelchair and has back pain.',
      household,
    );
    expect(needs.needsFor('p-ruta').pregnant, isTrue);
    expect(needs.needsFor('p-jonas').mobilityAid, isTrue);
    expect(needs.needsFor('p-jonas').backProblem, isTrue);
  });

  test('never extracts a medicine dose', () {
    final needs = parser.parse(
      'Maria takes insulin 20 units twice a day.',
      household,
    );
    final json = jsonEncode(needs.toJson());
    expect(json, isNot(contains('20')));
    expect(json, isNot(contains('units')));
    expect(needs.needsFor('p-ona').medications, contains('insulin'));
  });

  test('ambiguous needs produce one clarifying question', () {
    final needs = parser.parse('There is diabetes in the family.', household);
    expect(needs.clarifications, isNotEmpty);
    expect(needs.clarifications.first.code, 'who');
  });

  test('unrecognised text asks for clarification instead of ignoring it', () {
    final needs = parser.parse(
      'We just want a normal bag, nothing special.',
      household,
    );
    expect(needs.clarifications, isNotEmpty);
    expect(needs.clarifications.first.code, 'unsure');
  });

  test('negation is respected in English and Lithuanian', () {
    for (final text in [
      'No allergies, not diabetic.',
      'We do not have a dog.',
      'No pets.',
      'Nėra augintinių.',
      'Rūta is not pregnant.',
      'Maria is not allergic to nuts.',
    ]) {
      final needs = parser.parse(text, household);
      expect(needs.petTypes, isEmpty, reason: text);
      expect(needs.needsFor('p-ona').conditions, isEmpty, reason: text);
      expect(needs.needsFor('p-ruta').pregnant, isFalse, reason: text);
      expect(needs.needsFor('p-ona').allergies, isEmpty, reason: text);
    }
  });

  test('substring false positives do not create pets', () {
    for (final text in [
      'We have a competition tomorrow.',
      'We have a carpet and a trumpet.',
      'He works with petroleum.',
      'She is dogmatic.',
    ]) {
      expect(parser.parse(text, household).petTypes, isEmpty, reason: text);
    }
  });

  test('one sentence maps each condition to the nearest name', () {
    final needs = parser.parse(
      'Jonas has diabetes and Rūta is pregnant. '
      'Mia has a peanut allergy and Rūta has a dairy allergy.',
      household,
    );
    expect(needs.needsFor('p-jonas').conditions, contains('diabetes'));
    expect(needs.needsFor('p-ruta').pregnant, isTrue);
    expect(needs.needsFor('p-mia').allergies, contains('nuts'));
    expect(needs.needsFor('p-ruta').allergies, contains('dairy'));
    expect(needs.needsFor('p-jonas').allergies, isEmpty);
  });

  test('Lithuanian inflections are understood', () {
    final needs = parser.parse(
      'Jonas turi aukštą kraujospūdį. Maria turi diabetą ir Rūta yra nėščia.',
      household,
    );
    expect(needs.needsFor('p-jonas').conditions, contains('hypertension'));
    expect(needs.needsFor('p-ona').conditions, contains('diabetes'));
    expect(needs.needsFor('p-ruta').pregnant, isTrue);
  });

  test('empty text produces an empty result', () {
    final needs = parser.parse('   ', household);
    expect(needs.byPerson, isEmpty);
    expect(needs.petTypes, isEmpty);
    expect(needs.clarifications, isEmpty);
  });
}
