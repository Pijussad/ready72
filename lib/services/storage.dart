import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/needs.dart';
import '../models/pack.dart';
import '../models/person.dart';
import '../models/plan.dart';
import 'consent.dart';

class StorageSnapshot {
  const StorageSnapshot({
    required this.household,
    required this.needsText,
    required this.needs,
    required this.consent,
    required this.tier,
    required this.subscriptionActive,
    required this.pack,
    required this.cleared,
    this.orderPlaced = false,
    this.orderCreatedAt,
  });

  final List<Person> household;
  final String needsText;
  final ParsedNeeds needs;
  final ConsentRecord? consent;
  final PlanTier tier;
  final bool subscriptionActive;
  final PackProgress pack;
  final bool cleared;
  final bool orderPlaced;
  final DateTime? orderCreatedAt;

  Map<String, dynamic> toJson() => {
    'household': household.map((person) => person.toJson()).toList(),
    'needsText': needsText,
    'needs': needs.toJson(),
    'consent': consent?.toJson(),
    'tier': tier.name,
    'subscriptionActive': subscriptionActive,
    'pack': pack.toJson(),
    'cleared': cleared,
    'orderPlaced': orderPlaced,
    'orderCreatedAt': orderCreatedAt?.toIso8601String(),
  };

  factory StorageSnapshot.fromJson(Map<String, dynamic> json) =>
      StorageSnapshot(
        household: ((json['household'] as List<dynamic>?) ?? [])
            .map((item) => Person.fromJson(item as Map<String, dynamic>))
            .toList(),
        needsText: json['needsText'] as String? ?? '',
        needs: json['needs'] == null
            ? ParsedNeeds.empty()
            : ParsedNeeds.fromJson(json['needs'] as Map<String, dynamic>),
        consent: json['consent'] == null
            ? null
            : ConsentRecord.fromJson(json['consent'] as Map<String, dynamic>),
        tier: json['tier'] == 'essential'
            ? PlanTier.essential
            : PlanTier.comfort,
        subscriptionActive: json['subscriptionActive'] as bool? ?? false,
        pack: json['pack'] == null
            ? PackProgress.empty()
            : PackProgress.fromJson(json['pack'] as Map<String, dynamic>),
        cleared: json['cleared'] as bool? ?? false,
        orderPlaced: json['orderPlaced'] as bool? ?? false,
        orderCreatedAt: json['orderCreatedAt'] == null
            ? null
            : DateTime.tryParse(json['orderCreatedAt'] as String),
      );

  static StorageSnapshot clearedSnapshot() => StorageSnapshot(
    household: const [],
    needsText: '',
    needs: ParsedNeeds.empty(),
    consent: null,
    tier: PlanTier.comfort,
    subscriptionActive: false,
    pack: PackProgress.empty(),
    cleared: true,
  );
}

class StorageService {
  StorageService._(this._prefs);

  static const String _snapshotKey = 'ready72.snapshot.v2';
  static const String _legacySnapshotKey = 'ready72.snapshot.v1';
  static const String _localeKey = 'ready72.locale.v1';

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacy(prefs);
    return StorageService._(prefs);
  }

  /// v1 could contain the old auto-seeded demo family. Drop that seed so the
  /// upgrade matches the "no prefilled fields" product decision, but preserve
  /// a household the user actually typed in.
  static Future<void> _migrateLegacy(SharedPreferences prefs) async {
    final raw = prefs.getString(_legacySnapshotKey);
    if (raw == null) return;
    try {
      final snapshot = StorageSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final isAutoSeed =
          snapshot.household.length == DemoHousehold.people.length &&
          snapshot.household.asMap().entries.every(
            (entry) => entry.value.id == DemoHousehold.people[entry.key].id,
          ) &&
          snapshot.needsText == DemoHousehold.needsText;
      if (!isAutoSeed) {
        await prefs.setString(_snapshotKey, raw);
      }
    } catch (_) {
      // Discard an unreadable legacy snapshot.
    }
    await prefs.remove(_legacySnapshotKey);
  }

  StorageSnapshot? load() {
    final raw = _prefs.getString(_snapshotKey);
    if (raw == null) return null;
    try {
      return StorageSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A corrupt local snapshot is discarded, never sent anywhere.
      return null;
    }
  }

  Future<void> save(StorageSnapshot snapshot) async {
    await _prefs.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_snapshotKey);
    await _prefs.remove(_legacySnapshotKey);
  }

  String? loadLocale() => _prefs.getString(_localeKey);

  Future<void> saveLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }
}
