class PersonNeeds {
  PersonNeeds({
    required this.personId,
    Set<String>? conditions,
    Set<String>? medications,
    Set<String>? allergies,
    Set<String>? diets,
    this.diapers = false,
    this.formula = false,
    this.babyFood = false,
    this.glasses = false,
    this.mobilityAid = false,
    this.coolingPouch = false,
    this.pregnant = false,
    this.backProblem = false,
    this.healthHistory = false,
  }) : conditions = conditions ?? <String>{},
       medications = medications ?? <String>{},
       allergies = allergies ?? <String>{},
       diets = diets ?? <String>{};

  final String personId;
  final Set<String> conditions;
  final Set<String> medications;
  final Set<String> allergies;
  final Set<String> diets;
  bool diapers;
  bool formula;
  bool babyFood;
  bool glasses;
  bool mobilityAid;
  bool coolingPouch;
  bool pregnant;
  bool backProblem;
  bool healthHistory;

  bool get hasAny =>
      conditions.isNotEmpty ||
      medications.isNotEmpty ||
      allergies.isNotEmpty ||
      diets.isNotEmpty ||
      diapers ||
      formula ||
      babyFood ||
      glasses ||
      mobilityAid ||
      coolingPouch ||
      pregnant ||
      backProblem ||
      healthHistory;

  bool get needsReducedCapacity => pregnant || backProblem || mobilityAid;

  bool get needsCooling => coolingPouch || medications.contains('insulin');

  int get signalCount =>
      conditions.length +
      medications.length +
      allergies.length +
      diets.length +
      (diapers ? 1 : 0) +
      (formula ? 1 : 0) +
      (babyFood ? 1 : 0) +
      (glasses ? 1 : 0) +
      (mobilityAid ? 1 : 0) +
      (pregnant ? 1 : 0) +
      (backProblem ? 1 : 0);

  Map<String, dynamic> toJson() => {
    'personId': personId,
    'conditions': conditions.toList(),
    'medications': medications.toList(),
    'allergies': allergies.toList(),
    'diets': diets.toList(),
    'diapers': diapers,
    'formula': formula,
    'babyFood': babyFood,
    'glasses': glasses,
    'mobilityAid': mobilityAid,
    'coolingPouch': coolingPouch,
    'pregnant': pregnant,
    'backProblem': backProblem,
    'healthHistory': healthHistory,
  };

  factory PersonNeeds.fromJson(Map<String, dynamic> json) => PersonNeeds(
    personId: json['personId'] as String,
    conditions: _stringSet(json['conditions']),
    medications: _stringSet(json['medications']),
    allergies: _stringSet(json['allergies']),
    diets: _stringSet(json['diets']),
    diapers: json['diapers'] as bool? ?? false,
    formula: json['formula'] as bool? ?? false,
    babyFood: json['babyFood'] as bool? ?? false,
    glasses: json['glasses'] as bool? ?? false,
    mobilityAid: json['mobilityAid'] as bool? ?? false,
    coolingPouch: json['coolingPouch'] as bool? ?? false,
    pregnant: json['pregnant'] as bool? ?? false,
    backProblem: json['backProblem'] as bool? ?? false,
    healthHistory: json['healthHistory'] as bool? ?? false,
  );
}

class NeedsClarification {
  const NeedsClarification({required this.code, this.detail});

  /// Localisation key used by the UI. The parser never emits display text.
  final String code;
  final String? detail;

  Map<String, dynamic> toJson() => {'code': code, 'detail': detail};

  factory NeedsClarification.fromJson(Map<String, dynamic> json) =>
      NeedsClarification(
        code: json['code'] as String,
        detail: json['detail'] as String?,
      );
}

class ParsedNeeds {
  ParsedNeeds({
    Map<String, PersonNeeds>? byPerson,
    Set<String>? petTypes,
    List<NeedsClarification>? clarifications,
  }) : byPerson = byPerson ?? <String, PersonNeeds>{},
       petTypes = petTypes ?? <String>{},
       clarifications = clarifications ?? <NeedsClarification>[];

  final Map<String, PersonNeeds> byPerson;
  final Set<String> petTypes;
  final List<NeedsClarification> clarifications;

  bool get hasPets => petTypes.isNotEmpty;

  int get mappedNeedCount {
    var count = petTypes.length;
    for (final needs in byPerson.values) {
      count += needs.signalCount;
    }
    return count;
  }

  PersonNeeds needsFor(String personId) =>
      byPerson[personId] ?? PersonNeeds(personId: personId);

  Set<String> get allAllergies => {
    for (final needs in byPerson.values) ...needs.allergies,
  };

  Set<String> get allDiets => {
    for (final needs in byPerson.values) ...needs.diets,
  };

  bool get anyReducedCapacity =>
      byPerson.values.any((needs) => needs.needsReducedCapacity);

  ParsedNeeds copy() => ParsedNeeds(
    byPerson: {
      for (final entry in byPerson.entries)
        entry.key: PersonNeeds.fromJson(entry.value.toJson()),
    },
    petTypes: {...petTypes},
    clarifications: [...clarifications],
  );

  Map<String, dynamic> toJson() => {
    'byPerson': {
      for (final entry in byPerson.entries) entry.key: entry.value.toJson(),
    },
    'petTypes': petTypes.toList(),
    'clarifications': clarifications.map((item) => item.toJson()).toList(),
  };

  factory ParsedNeeds.fromJson(Map<String, dynamic> json) {
    final rawPeople = json['byPerson'] as Map<String, dynamic>? ?? {};
    return ParsedNeeds(
      byPerson: {
        for (final entry in rawPeople.entries)
          entry.key: PersonNeeds.fromJson(entry.value as Map<String, dynamic>),
      },
      petTypes: _stringSet(json['petTypes']),
      clarifications: ((json['clarifications'] as List<dynamic>?) ?? [])
          .map(
            (item) => NeedsClarification.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  static ParsedNeeds empty() => ParsedNeeds();
}

Set<String> _stringSet(dynamic value) {
  if (value is List) return value.map((item) => item.toString()).toSet();
  return <String>{};
}
