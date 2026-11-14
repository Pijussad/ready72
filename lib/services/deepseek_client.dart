import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/store_catalogue.dart';
import '../models/needs.dart';
import '../models/person.dart';
import 'consent.dart';

/// Thin DeepSeek client for the needs parser.
///
/// Uses DeepSeek's OpenAI-compatible chat completions endpoint with JSON
/// output. The API key comes from `--dart-define=DEEPSEEK_API_KEY=...` and is
/// never committed. With no key the app uses the deterministic on-device
/// parser, so the demo runs offline. `DEEPSEEK_REPLAY=true` replays a recorded
/// response instead of making a request.
class DeepSeekClient {
  DeepSeekClient({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: '',
  );
  static const String _baseUrl = String.fromEnvironment(
    'DEEPSEEK_BASE_URL',
    defaultValue: 'https://api.deepseek.com',
  );
  static const String _model = String.fromEnvironment(
    'DEEPSEEK_MODEL',
    defaultValue: 'deepseek-chat',
  );
  static const bool _replay = bool.fromEnvironment(
    'DEEPSEEK_REPLAY',
    defaultValue: false,
  );

  final http.Client _client;

  bool get enabled => _apiKey.isNotEmpty || _replay;

  bool get configured => _apiKey.isNotEmpty || _replay;

  Future<ParsedNeeds?> extractNeeds({
    required String text,
    required List<Person> household,
    required ConsentRecord? consent,
  }) async {
    if (consent == null) {
      throw const ConsentRequiredException();
    }
    if (!enabled) return null;
    if (_replay) {
      return _fromJson(_replayFixture, household);
    }

    final payload = {
      'model': _model,
      'temperature': 0,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': jsonEncode({
            'household': [
              for (final person in household)
                {'id': person.id, 'name': person.name, 'age': person.age},
            ],
            'needs_text': text,
          }),
        },
      ],
    };

    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _client
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 25));
        if (response.statusCode != 200) {
          throw StateError('DeepSeek HTTP ${response.statusCode}');
        }
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = body['choices'] as List<dynamic>;
        final message =
            (choices.first as Map<String, dynamic>)['message']
                as Map<String, dynamic>;
        final content = message['content'] as String;
        final decoded = jsonDecode(content) as Map<String, dynamic>;
        return _fromJson(decoded, household);
      } catch (error) {
        lastError = error;
        await Future<void>.delayed(Duration(seconds: attempt + 1));
      }
    }
    // Never log the prompt or the health text.
    throw StateError('DeepSeek failed after retries: $lastError');
  }

  /// Ask DeepSeek to choose from a shortlist of real store offers. The model
  /// never sees the whole database and never sets a price: it only returns ids
  /// that must exist in [candidates]. The caller re-reads names, prices and
  /// URLs from the database.
  Future<List<String>?> pickFromCatalogue({
    required String query,
    required List<Person> household,
    required ParsedNeeds needs,
    required List<StoreOffer> candidates,
    required ConsentRecord? consent,
  }) async {
    if (consent == null) throw const ConsentRequiredException();
    if (!enabled || candidates.isEmpty) return null;

    final shortlist = candidates
        .take(60)
        .map(
          (offer) => {
            'id': offer.id,
            'name': offer.name,
            'store': offer.store,
            'price_eur': offer.priceEur,
            'pack': offer.pack,
            'role': offer.role,
          },
        )
        .toList();

    final payload = {
      'model': _model,
      'temperature': 0,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': _cataloguePrompt},
        {
          'role': 'user',
          'content': jsonEncode({
            'request': query,
            'household': [
              for (final person in household)
                {
                  'id': person.id,
                  'age': person.age,
                  if (needs.needsFor(person.id).allergies.isNotEmpty)
                    'allergies': needs.needsFor(person.id).allergies.toList(),
                  if (needs.needsFor(person.id).diets.isNotEmpty)
                    'diets': needs.needsFor(person.id).diets.toList(),
                },
            ],
            'candidates': shortlist,
          }),
        },
      ],
    };

    final response = await _client
        .post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw StateError('DeepSeek HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>;
    final message =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>;
    final decoded =
        jsonDecode(message['content'] as String) as Map<String, dynamic>;
    final allowed = candidates.map((offer) => offer.id).toSet();
    final picks = (decoded['product_ids'] as List? ?? const [])
        .map((value) => value.toString())
        .where(allowed.contains)
        .toSet()
        .take(12)
        .toList(growable: false);
    return picks;
  }

  static const String _cataloguePrompt = '''
You choose real products from a supplied shortlist for a 72-hour emergency bag.
Return strict JSON: {"product_ids": ["id", "..."]}.
Rules:
- Only ids present in `candidates`. Never invent products, prices or stores.
- Choose at most 12 products that directly answer the request and are age-safe.
- Respect every listed allergy and diet. If unsure, leave the product out.
- Prefer shelf-stable, high-calorie, compact, essential items.
- Do not give medical advice, doses, diagnoses or treatment plans.
- If nothing fits, return {"product_ids": []}.
''';

  static const String _systemPrompt = '''
You convert a household's free-text needs into strict JSON for Ready72.
You must not give medical advice, interpret symptoms, or invent doses.
Only return fields from the schema below. Use person ids exactly as supplied.
If a need cannot be attached to a person, add a clarifying question with
code "who" and a detail token from the allowed list.

Schema:
{
  "people": [{
    "person_id": "string",
    "conditions": ["diabetes","asthma","hypertension","epilepsy","heart","kidney"],
    "medications": ["insulin","prescribed"],
    "allergies": ["nuts","gluten","dairy","fish","eggs","soy"],
    "diets": ["vegetarian","vegan","glutenFree","dairyFree","lowSugar"],
    "diapers": false,
    "formula": false,
    "baby_food": false,
    "glasses": false,
    "mobility_aid": false,
    "cooling_pouch": false,
    "pregnant": false,
    "back_problem": false
  }],
  "pets": ["dog","cat","pet"],
  "clarifying_questions": [{"code":"who","detail":"diabetes"}]
}

Never add medicine names, doses or free-text medical advice.
''';

  static ParsedNeeds? _fromJson(
    Map<String, dynamic> json,
    List<Person> household,
  ) {
    final ids = household.map((person) => person.id).toSet();
    final byPerson = <String, PersonNeeds>{};
    final people = json['people'] as List<dynamic>? ?? [];
    for (final raw in people) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['person_id'] as String?;
      if (id == null || !ids.contains(id)) continue;
      byPerson[id] = PersonNeeds(
        personId: id,
        conditions: _allowed(raw['conditions'], const {
          'diabetes',
          'asthma',
          'hypertension',
          'epilepsy',
          'heart',
          'kidney',
        }),
        medications: _allowed(raw['medications'], const {
          'insulin',
          'prescribed',
        }),
        allergies: _allowed(raw['allergies'], const {
          'nuts',
          'gluten',
          'dairy',
          'fish',
          'eggs',
          'soy',
        }),
        diets: _allowed(raw['diets'], const {
          'vegetarian',
          'vegan',
          'glutenFree',
          'dairyFree',
          'lowSugar',
        }),
        diapers: raw['diapers'] == true,
        formula: raw['formula'] == true,
        babyFood: raw['baby_food'] == true,
        glasses: raw['glasses'] == true,
        mobilityAid: raw['mobility_aid'] == true,
        coolingPouch: raw['cooling_pouch'] == true,
        pregnant: raw['pregnant'] == true,
        backProblem: raw['back_problem'] == true,
        healthHistory:
            raw['medications'] is List &&
            (raw['medications'] as List<dynamic>).isNotEmpty,
      );
    }

    final pets = _allowed(json['pets'], const {'dog', 'cat', 'pet'});
    final clarifications = <NeedsClarification>[];
    final rawQuestions = json['clarifying_questions'] as List<dynamic>? ?? [];
    for (final raw in rawQuestions) {
      if (raw is! Map<String, dynamic>) continue;
      if (raw['code'] != 'who') continue;
      final detail = raw['detail'] as String?;
      if (detail == null) continue;
      clarifications.add(NeedsClarification(code: 'who', detail: detail));
    }

    return ParsedNeeds(
      byPerson: byPerson,
      petTypes: pets,
      clarifications: clarifications,
    );
  }

  static Set<String> _allowed(dynamic value, Set<String> allowed) {
    if (value is! List) return <String>{};
    return value.map((item) => item.toString()).where(allowed.contains).toSet();
  }

  static const Map<String, dynamic> _replayFixture = {
    'people': [
      {
        'person_id': 'p-ona',
        'conditions': ['diabetes'],
        'medications': ['insulin'],
        'allergies': [],
        'diets': ['lowSugar'],
        'cooling_pouch': true,
      },
      {'person_id': 'p-mia', 'diapers': true, 'baby_food': true},
    ],
    'pets': ['dog'],
    'clarifying_questions': [],
  };
}
