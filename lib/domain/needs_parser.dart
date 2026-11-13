import '../models/needs.dart';
import '../models/person.dart';

/// Turns a short free-text description into structured, per-person needs.
///
/// This is a deterministic, on-device parser. It never extracts doses and
/// gives no medical advice. It understands negations ("no pets", "not
/// diabetic") and attributes each clause to the nearest named person instead
/// of copying every condition to every name in the sentence.
class NeedsParser {
  const NeedsParser();

  static const Map<String, List<String>> _conditions = {
    'diabetes': ['diabet', 'cukrin'],
    'asthma': ['astm'],
    'hypertension': ['high blood pressure', 'hypertens', 'kraujospud'],
    'epilepsy': ['epilep'],
    'heart': ['heart condition', 'sirdies'],
    'kidney': ['kidney', 'inkst'],
  };

  static const Map<String, List<String>> _allergySignals = {
    'nuts': ['nut allergy', 'peanut', 'tree nut', 'nuts', 'riesut'],
    'gluten': ['gluten', 'celiac', 'celiak', 'glitim'],
    'dairy': ['lactose', 'dairy', 'laktoz', 'pieno netoler'],
    'fish': ['fish allergy', 'seafood', 'zuv', 'juru geryb'],
    'eggs': ['egg allergy', 'kiausin'],
    'soy': ['soy', 'soj'],
  };

  static const List<String> _petWords = [
    'dog',
    'dogs',
    'puppy',
    'puppies',
    'cat',
    'cats',
    'kitten',
    'kittens',
    'pet',
    'pets',
    'suo',
    'suni',
    'sunys',
    'kate',
    'katin',
    'augintin',
  ];

  ParsedNeeds parse(String text, List<Person> people) {
    final parsed = ParsedNeeds();
    if (text.trim().isEmpty || people.isEmpty) return parsed;

    final sentences = text
        .split(RegExp(r'[\n.!?;]+'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.isNotEmpty);

    for (final sentence in sentences) {
      final clauses = sentence
          .split(
            RegExp(r',|\band\b|\bbut\b|\bir\b|\bbet\b', caseSensitive: false),
          )
          .map((clause) => clause.trim())
          .where((clause) => clause.isNotEmpty);

      String? lastNamedId;
      for (final clause in clauses) {
        final normalized = _normalize(clause);
        final named = people
            .where((person) => _mentionsName(normalized, person.name))
            .toList();
        if (named.isNotEmpty) lastNamedId = named.last.id;
        final everyone = _containsAny(normalized, const [
          'everyone',
          'everybody',
          'visi',
          'visus',
          'visiems',
        ]);

        final signals = _signalsIn(normalized);

        // Pets belong to the household, not to one bag.
        if (signals.pets.isNotEmpty) {
          parsed.petTypes.addAll(signals.pets);
        }

        final needsTargets = <Person>[];
        if (signals.hasMedicalSignal) {
          if (named.isNotEmpty) {
            needsTargets.addAll(named);
          } else if (everyone) {
            needsTargets.addAll(people);
          } else if (lastNamedId != null) {
            final inherited = people.where((p) => p.id == lastNamedId);
            if (inherited.isNotEmpty) needsTargets.add(inherited.first);
          } else {
            // Pregnancy is the one signal we refuse to guess at: applying it
            // to the first adult can lower the wrong person's carry limit.
            if (signals.pregnancy) {
              parsed.clarifications.add(
                NeedsClarification(code: 'who', detail: signals.primaryDetail),
              );
              continue;
            }
            final target = _defaultTarget(people, signals);
            if (target != null) {
              needsTargets.add(target);
              if (people.where((person) => !person.isToddler).length > 1) {
                parsed.clarifications.add(
                  NeedsClarification(
                    code: 'who',
                    detail: signals.primaryDetail,
                  ),
                );
              }
            }
          }
        }

        for (final person in needsTargets) {
          final needs = parsed.byPerson.putIfAbsent(
            person.id,
            () => PersonNeeds(personId: person.id),
          );
          _apply(needs, signals, person);
        }
      }
    }

    final seen = <String>{};
    parsed.clarifications.retainWhere(
      (item) => seen.add('${item.code}:${item.detail}'),
    );

    if (parsed.mappedNeedCount == 0 && parsed.clarifications.isEmpty) {
      parsed.clarifications.add(const NeedsClarification(code: 'unsure'));
    }

    return parsed;
  }

  Person? _defaultTarget(List<Person> people, _Signals signals) {
    if (signals.babyRelated) {
      final youngest = [...people]..sort((a, b) => a.age.compareTo(b.age));
      return youngest.first;
    }
    final adults = people.where((person) => person.isAdult).toList();
    if (adults.isNotEmpty) return adults.first;
    return people.isEmpty ? null : people.first;
  }

  void _apply(PersonNeeds needs, _Signals signals, Person person) {
    needs.conditions.addAll(signals.conditions);
    needs.medications.addAll(signals.medications);
    needs.allergies.addAll(signals.allergies);
    needs.diets.addAll(signals.diets);

    if (signals.conditions.contains('diabetes')) {
      needs.diets.add('lowSugar');
    }
    if (signals.medications.contains('insulin') ||
        signals.conditions.contains('diabetes')) {
      needs.coolingPouch = true;
    }
    if (signals.diapers || (person.isToddler && signals.babyRelated)) {
      needs.diapers = true;
    }
    if (signals.formula) needs.formula = true;
    if (signals.babyRelated) needs.babyFood = true;
    if (signals.glasses) needs.glasses = true;
    if (signals.mobility) needs.mobilityAid = true;
    if (signals.pregnancy) needs.pregnant = true;
    if (signals.backProblem) needs.backProblem = true;
    if (signals.medications.isNotEmpty) needs.healthHistory = true;
  }

  _Signals _signalsIn(String text) {
    final signals = _Signals();

    _conditions.forEach((name, keywords) {
      if (_hasAnySignal(text, keywords)) signals.conditions.add(name);
    });

    if (_hasAnySignal(text, const ['insul'])) {
      signals.medications.add('insulin');
    }
    if (_hasAnySignal(text, const [
      'medication',
      'medicine',
      'prescription',
      'vaist',
    ])) {
      signals.medications.add('prescribed');
    }

    _allergySignals.forEach((name, keywords) {
      if (_hasAnySignal(text, keywords)) signals.allergies.add(name);
    });

    if (_hasAnySignal(text, const ['vegetarian', 'vegetar'])) {
      signals.diets.add('vegetarian');
    }
    if (_hasAnySignal(text, const ['vegan'])) {
      signals.diets.add('vegan');
    }
    if (signals.allergies.contains('gluten')) {
      signals.diets.add('glutenFree');
    }
    if (signals.allergies.contains('dairy')) {
      signals.diets.add('dairyFree');
    }

    if (_hasAnySignal(text, const ['diaper', 'nappy', 'sauskeln'])) {
      signals.diapers = true;
    }
    if (_hasAnySignal(text, const ['formula', 'misinys', 'pieno misin'])) {
      signals.formula = true;
    }
    if (_hasAnySignal(text, const [
          'baby',
          'infant',
          'newborn',
          'toddler',
          'kudik',
          'naujagim',
          'vaik',
        ]) ||
        signals.diapers ||
        signals.formula) {
      signals.babyRelated = true;
    }
    if (_hasAnySignal(text, const [
      'glasses',
      'spectacles',
      'eyewear',
      'akin',
      'contact lens',
      'lesiai',
    ])) {
      signals.glasses = true;
    }
    if (_hasAnySignal(text, const [
      'wheelchair',
      'mobility aid',
      'walker',
      'crutches',
      'vezimel',
      'vaikstyn',
      'raments',
    ])) {
      signals.mobility = true;
    }
    if (_hasAnySignal(text, const [
      'pregnant',
      'pregnancy',
      'expecting',
      'nesci',
      'nestum',
    ])) {
      signals.pregnancy = true;
    }
    if (_hasAnySignal(text, const [
      'back problem',
      'back pain',
      'bad back',
      'nugar',
    ])) {
      signals.backProblem = true;
    }

    for (final word in _petWords) {
      if (_hasWordSignal(text, word)) {
        if (word.startsWith('cat') ||
            word.startsWith('kate') ||
            word.startsWith('katin')) {
          signals.pets.add('cat');
        } else if (word.startsWith('dog') ||
            word.startsWith('puppy') ||
            word.startsWith('suo') ||
            word.startsWith('suni') ||
            word.startsWith('suny')) {
          signals.pets.add('dog');
        } else {
          signals.pets.add('pet');
        }
      }
    }

    return signals;
  }

  bool _mentionsName(String normalizedText, String name) {
    final normalizedName = _normalize(name);
    if (normalizedName.isEmpty) return false;
    return RegExp(
      '(^|\\s)${RegExp.escape(normalizedName)}\\w*(\\s|\$)',
    ).hasMatch(normalizedText);
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((keyword) => text.contains(_normalize(keyword)));

  bool _hasAnySignal(String text, List<String> keywords) =>
      keywords.any((keyword) => _hasSignal(text, keyword));

  bool _hasWordSignal(String text, String word) {
    final normalized = _normalize(word);
    final pattern = RegExp('(^|\\s)${RegExp.escape(normalized)}(\\s|\$)');
    var start = 0;
    while (start < text.length) {
      final match = pattern.firstMatch(text.substring(start));
      if (match == null) return false;
      final index = start + match.start;
      if (!_isNegated(text, index)) return true;
      start = index + match.end;
    }
    return false;
  }

  bool _hasSignal(String text, String keyword) {
    final normalizedKeyword = _normalize(keyword);
    var start = 0;
    while (start < text.length) {
      final index = text.indexOf(normalizedKeyword, start);
      if (index < 0) return false;
      if (!_isNegated(text, index)) return true;
      start = index + normalizedKeyword.length;
    }
    return false;
  }

  /// A small negation window before and after the keyword. This is deliberately
  /// conservative: a false negative is better than buying dog food for a
  /// household that said "no pets".
  bool _isNegated(String text, int index) {
    final before = text.substring(index > 40 ? index - 40 : 0, index);
    final after = text.substring(
      index,
      index + 30 > text.length ? text.length : index + 30,
    );
    final negatedBefore = RegExp(
      r"(\bno\b|\bnot\b|\bwithout\b|\bnone\b|\bnever\b|\bnera\b|\bneturi\b|\bneserga\b|\bnėra\b|\bnė\b|n't\b|free of\b|be\b)",
    ).hasMatch(before);
    final negatedAfter = RegExp(
      r'^\S*\s*(\bno\b|\bnot\b|\bwithout\b|\bnone\b|\bnera\b)',
    ).hasMatch(after);
    return negatedBefore || negatedAfter;
  }

  static String _normalize(String value) {
    const replacements = {
      'ą': 'a',
      'č': 'c',
      'ę': 'e',
      'ė': 'e',
      'į': 'i',
      'š': 's',
      'ų': 'u',
      'ū': 'u',
      'ž': 'z',
      'õ': 'o',
      'ā': 'a',
      'ē': 'e',
      'ī': 'i',
      'ō': 'o',
    };
    var result = value.toLowerCase();
    replacements.forEach((from, to) {
      result = result.replaceAll(from, to);
    });
    return result;
  }
}

class _Signals {
  final Set<String> conditions = {};
  final Set<String> medications = {};
  final Set<String> allergies = {};
  final Set<String> diets = {};
  final Set<String> pets = {};
  bool diapers = false;
  bool formula = false;
  bool babyRelated = false;
  bool glasses = false;
  bool mobility = false;
  bool pregnancy = false;
  bool backProblem = false;

  bool get hasMedicalSignal =>
      conditions.isNotEmpty ||
      medications.isNotEmpty ||
      allergies.isNotEmpty ||
      diets.isNotEmpty ||
      diapers ||
      formula ||
      glasses ||
      mobility ||
      pregnancy ||
      backProblem;

  String? get primaryDetail {
    if (conditions.isNotEmpty) return conditions.first;
    if (medications.isNotEmpty) return medications.first;
    if (allergies.isNotEmpty) return allergies.first;
    if (diets.isNotEmpty) return diets.first;
    if (pregnancy) return 'pregnancy';
    if (backProblem) return 'back';
    if (mobility) return 'mobility';
    if (glasses) return 'glasses';
    if (diapers || formula) return 'baby';
    return null;
  }
}
