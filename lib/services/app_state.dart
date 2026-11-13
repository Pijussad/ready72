import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../domain/growth.dart';
import '../domain/needs_parser.dart';
import '../domain/plan_optimizer.dart';
import '../models/needs.dart';
import '../models/order.dart';
import '../models/pack.dart';
import '../models/person.dart';
import '../models/plan.dart';
import '../models/subscription.dart';
import 'consent.dart';
import 'deepseek_client.dart';
import 'notifications.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  AppState(this._storage, {DeepSeekClient? ai, this.notifications})
    : _ai = ai ?? DeepSeekClient();

  final StorageService _storage;
  final DeepSeekClient _ai;
  final NotificationService? notifications;
  final NeedsParser _parser = const NeedsParser();
  final PlanOptimizer _optimizer = const PlanOptimizer();

  String _locale = 'en';
  List<Person> _household = [];
  String _needsText = '';
  ParsedNeeds _needs = ParsedNeeds.empty();
  ConsentRecord? _consent;
  PlanTier _tier = PlanTier.comfort;
  PlanResult? _essentialPlan;
  PlanResult? _comfortPlan;
  OrderData? _order;
  bool _subscriptionActive = false;
  PackProgress _pack = PackProgress.empty();
  String? _packPersonId;
  bool _orderPlaced = false;
  DateTime? _orderCreatedAt;
  String? _planError;
  bool _loaded = false;

  bool get loaded => _loaded;
  bool get aiConfigured => _ai.enabled;
  bool get orderPlaced => _orderPlaced;
  String? get planError => _planError;
  bool get hasPlan => _comfortPlan != null && hasConsent;
  String get locale => _locale;
  List<Person> get household => List.unmodifiable(_household);
  String get needsText => _needsText;
  ParsedNeeds get needs => _needs;
  ConsentRecord? get consent => _consent;
  bool get hasConsent => _consent != null;
  bool get reminders => _consent?.reminders ?? false;
  PlanTier get tier => _tier;
  bool get subscriptionActive => _subscriptionActive;
  PackProgress get pack => _pack;
  SubscriptionQuote get subscriptionQuote =>
      SubscriptionQuote.forHousehold(_household);

  PlanResult? get essentialPlan => _essentialPlan;
  PlanResult? get comfortPlan => _comfortPlan;

  PlanResult? get selectedPlan {
    if (!hasConsent) return null;
    return _tier == PlanTier.essential ? _essentialPlan : _comfortPlan;
  }

  OrderData? get order => _order;

  String? get packPersonId => _packPersonId;

  Person? get packPerson {
    for (final person in _household) {
      if (person.id == _packPersonId) return person;
    }
    return _household.isEmpty ? null : _household.first;
  }

  Future<void> init() async {
    _locale = _storage.loadLocale() ?? 'en';
    final snapshot = _storage.load();
    if (snapshot == null) {
      _clearInMemory();
    } else if (snapshot.cleared) {
      _clearInMemory();
    } else {
      _household = snapshot.household;
      _needsText = snapshot.needsText;
      _needs = snapshot.needs;
      _consent = snapshot.consent;
      _tier = snapshot.tier;
      _subscriptionActive = snapshot.subscriptionActive;
      _pack = snapshot.pack;
      _orderPlaced = snapshot.orderPlaced;
      _orderCreatedAt = snapshot.orderCreatedAt;
      _packPersonId = _defaultPackPerson();
    }
    if (_consent != null && _household.isNotEmpty) {
      if (_needs.byPerson.isEmpty &&
          _needs.petTypes.isEmpty &&
          _needsText.isNotEmpty) {
        _needs = _parser.parse(_needsText, _household);
      }
      _rebuildPlans();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    if (locale == _locale) return;
    _locale = locale;
    if (_consent != null && _household.isNotEmpty) {
      _rebuildPlans();
      await _persist();
    }
    await _storage.saveLocale(locale);
    notifyListeners();
  }

  Future<void> setHousehold(List<Person> people) async {
    _household = List.of(people);
    _needs = hasConsent
        ? _parser.parse(_needsText, _household)
        : ParsedNeeds.empty();
    if (_packPersonId == null ||
        !_household.any((person) => person.id == _packPersonId)) {
      _packPersonId = _defaultPackPerson();
    }
    if (_consent != null) {
      _rebuildPlans();
      await _persist();
    }
    notifyListeners();
  }

  /// The raw text is kept in memory while typing. It is parsed only after
  /// consent, so no health text is processed or persisted before the gate.
  void previewNeeds(String text) {
    _needsText = text;
    notifyListeners();
  }

  Future<void> commitNeeds(String text) async {
    _needsText = text;
    if (hasConsent) {
      _needs = _parser.parse(text, _household);
      _rebuildPlans();
      await _persist();
    }
    notifyListeners();
  }

  Future<void> agreeAndSend({required bool reminders}) async {
    _consent = ConsentRecord(
      version: AppConfig.consentVersion,
      grantedAt: DateTime.now(),
      purposes: {'plan', if (reminders) 'reminders'},
      reminders: reminders,
    );

    // Consent has now been given. The deterministic parser is the only
    // processor in this build; the optional AI client is not called unless a
    // separate 'ai' purpose has been granted (there is no such UI yet).
    _needs = _parser.parse(_needsText, _household);
    if (_ai.enabled && _consent!.purposes.contains('ai')) {
      try {
        final aiNeeds = await _ai.extractNeeds(
          text: _needsText,
          household: _household,
          consent: _consent,
        );
        if (aiNeeds != null) _needs = _mergeNeeds(_needs, aiNeeds);
      } catch (_) {
        // Fall back silently; never log the health text.
      }
    }

    _rebuildPlans();
    if (reminders && notifications != null) {
      await notifications!.requestPermissions();
      for (final person in _household) {
        final review = project(person).nextReview;
        notifications?.schedule(
          id: 3000 + person.id.hashCode.abs() % 1000,
          when: DateTime(review.year, review.month, review.day, 9),
          title: 'Ready72 · bag review',
          body: 'Check ${person.name}’s bag today.',
        );
      }
    }
    await _persist();
    notifyListeners();
  }

  void selectTier(PlanTier tier) {
    if (_tier == tier) return;
    _tier = tier;
    _orderPlaced = false;
    _order = selectedPlan == null
        ? null
        : OrderSplitter.fromPlan(selectedPlan!, now: _orderCreatedAt);
    _persist();
    notifyListeners();
  }

  Future<void> subscribe() async {
    _subscriptionActive = true;
    await _persist();
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    _subscriptionActive = false;
    await _persist();
    notifyListeners();
  }

  Future<void> placeOrder() async {
    _orderPlaced = true;
    _orderCreatedAt ??= DateTime.now();
    await _persist();
    notifyListeners();
  }

  void setPackPerson(String personId) {
    _packPersonId = personId;
    _persist();
    notifyListeners();
  }

  Future<void> loadDemo() async {
    _household = List.of(DemoHousehold.people);
    _needsText = DemoHousehold.needsText;
    _needs = ParsedNeeds.empty();
    _packPersonId = _defaultPackPerson();
    if (hasConsent) _rebuildPlans();
    notifyListeners();
  }

  void togglePacked(PlanItem item) {
    final entry = _pack.entryFor(item.key);
    _pack = _pack.withEntry(
      item.key,
      entry.copyWith(
        checked: !entry.checked,
        packedAt: !entry.checked ? DateTime.now() : null,
        clearPackedAt: entry.checked,
      ),
    );
    _persist();
    notifyListeners();
  }

  void markAllPacked(List<PlanItem> items) {
    for (final item in items) {
      final entry = _pack.entryFor(item.key);
      if (!entry.checked) {
        _pack = _pack.withEntry(
          item.key,
          entry.copyWith(checked: true, packedAt: DateTime.now()),
        );
      }
    }
    _persist();
    notifyListeners();
  }

  void unpackAll(List<PlanItem> items) {
    for (final item in items) {
      final entry = _pack.entryFor(item.key);
      if (entry.checked) {
        _pack = _pack.withEntry(
          item.key,
          entry.copyWith(checked: false, clearPackedAt: true),
        );
      }
    }
    _persist();
    notifyListeners();
  }

  void setExpiry(PlanItem item, DateTime expiry) {
    final entry = _pack.entryFor(item.key);
    _pack = _pack.withEntry(item.key, entry.copyWith(expiry: expiry));
    if (reminders && notifications != null) {
      final name = item.product.name(_locale);
      final sixty = expiry.subtract(const Duration(days: 60));
      final fourteen = expiry.subtract(const Duration(days: 14));
      notifications?.schedule(
        id: 1000 + item.key.hashCode.abs() % 1000,
        when: DateTime(sixty.year, sixty.month, sixty.day, 9),
        title: 'Ready72 · food check',
        body: '$name expires in 60 days.',
      );
      notifications?.schedule(
        id: 2000 + item.key.hashCode.abs() % 1000,
        when: DateTime(fourteen.year, fourteen.month, fourteen.day, 9),
        title: 'Ready72 · food check',
        body: '$name expires in 14 days.',
      );
    }
    _persist();
    notifyListeners();
  }

  GrowthProjection reviewFor(Person person) => project(person);

  Future<void> deleteAll() async {
    await notifications?.cancelAll();
    _clearInMemory();
    await _storage.clear();
    notifyListeners();
  }

  String exportData() {
    return const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'household': _household.map((person) => person.toJson()).toList(),
      'needsText': _needsText,
      'needs': _needs.toJson(),
      'consent': _consent?.toJson(),
      'subscriptionActive': _subscriptionActive,
      'tier': _tier.name,
      'selectedPlan': selectedPlan == null
          ? null
          : {
              'tier': selectedPlan!.tier.name,
              'totalPrice': selectedPlan!.totalPrice,
              'totalWeight': selectedPlan!.totalWeight,
              'gaps': selectedPlan!.gaps.map((gap) => gap.name).toList(),
            },
      'pack': _pack.toJson(),
    });
  }

  void _rebuildPlans() {
    _planError = null;
    if (_household.isEmpty) {
      _essentialPlan = null;
      _comfortPlan = null;
      _order = null;
      return;
    }
    try {
      _orderCreatedAt ??= DateTime.now();
      _essentialPlan = _optimizer.build(
        PlanRequest(
          household: _household,
          needs: _needs,
          tier: PlanTier.essential,
          languageCode: _locale,
        ),
      );
      _comfortPlan = _optimizer.build(
        PlanRequest(
          household: _household,
          needs: _needs,
          tier: PlanTier.comfort,
          languageCode: _locale,
        ),
      );
      final chosen = selectedPlan;
      _order = chosen == null
          ? null
          : OrderSplitter.fromPlan(chosen, now: _orderCreatedAt);
    } catch (error) {
      _planError = error.toString();
      _essentialPlan = null;
      _comfortPlan = null;
      _order = null;
    }
  }

  String? _defaultPackPerson() {
    if (_household.isEmpty) return null;
    Person? senior;
    for (final person in _household) {
      if (person.isSenior) {
        senior = person;
        break;
      }
    }
    return (senior ?? _household.first).id;
  }

  void _clearInMemory() {
    _household = [];
    _needsText = '';
    _needs = ParsedNeeds.empty();
    _consent = null;
    _tier = PlanTier.comfort;
    _essentialPlan = null;
    _comfortPlan = null;
    _order = null;
    _subscriptionActive = false;
    _pack = PackProgress.empty();
    _packPersonId = null;
    _orderPlaced = false;
    _orderCreatedAt = null;
    _planError = null;
  }

  Future<void> _persist() async {
    if (_consent == null) return;
    await _storage.save(
      StorageSnapshot(
        household: _household,
        needsText: _needsText,
        needs: _needs,
        consent: _consent,
        tier: _tier,
        subscriptionActive: _subscriptionActive,
        pack: _pack,
        cleared: false,
        orderPlaced: _orderPlaced,
        orderCreatedAt: _orderCreatedAt,
      ),
    );
  }

  /// Keep the deterministic parse and only let AI add safe, unknown values.
  ParsedNeeds _mergeNeeds(ParsedNeeds base, ParsedNeeds ai) {
    final merged = base.copy();
    for (final entry in ai.byPerson.entries) {
      final target = merged.byPerson.putIfAbsent(
        entry.key,
        () => PersonNeeds(personId: entry.key),
      );
      target.conditions.addAll(entry.value.conditions);
      target.medications.addAll(entry.value.medications);
      target.allergies.addAll(entry.value.allergies);
      target.diets.addAll(entry.value.diets);
      target.diapers = target.diapers || entry.value.diapers;
      target.formula = target.formula || entry.value.formula;
      target.babyFood = target.babyFood || entry.value.babyFood;
      target.glasses = target.glasses || entry.value.glasses;
      target.mobilityAid = target.mobilityAid || entry.value.mobilityAid;
      target.coolingPouch = target.coolingPouch || entry.value.coolingPouch;
      target.pregnant = target.pregnant || entry.value.pregnant;
      target.backProblem = target.backProblem || entry.value.backProblem;
      if (target.conditions.contains('diabetes')) {
        target.diets.add('lowSugar');
      }
      if (target.conditions.contains('diabetes') ||
          target.medications.contains('insulin')) {
        target.coolingPouch = true;
      }
      if (target.allergies.contains('gluten')) target.diets.add('glutenFree');
      if (target.allergies.contains('dairy')) target.diets.add('dairyFree');
    }
    merged.petTypes.addAll(ai.petTypes);
    return merged;
  }
}
