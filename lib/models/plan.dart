import '../data/lt72.dart';
import 'needs.dart';
import 'person.dart';
import 'product.dart';

enum PlanTier { essential, comfort }

class PlanItem {
  const PlanItem({
    required this.product,
    required this.quantity,
    required this.carrierId,
    required this.beneficiaryId,
    this.shared = false,
    this.note,
  });

  final Product product;
  final int quantity;

  /// The person whose bag physically carries this line.
  final String carrierId;

  /// The person the line is intended for (may differ for dependants).
  final String beneficiaryId;

  final bool shared;
  final String? note;

  double get weightKg => product.weightKg * quantity;
  double get priceEur => product.userSupplied ? 0 : product.priceEur * quantity;
  int get calories => product.caloriesPerUnit * quantity;

  String get key => '$carrierId|$beneficiaryId|${product.id}';

  PlanItem copyWith({int? quantity, String? carrierId, bool? shared}) =>
      PlanItem(
        product: product,
        quantity: quantity ?? this.quantity,
        carrierId: carrierId ?? this.carrierId,
        beneficiaryId: beneficiaryId,
        shared: shared ?? this.shared,
        note: note,
      );
}

class PersonBag {
  PersonBag({required this.person, required this.limitKg, required this.items});

  final Person person;
  final double limitKg;
  final List<PlanItem> items;

  double get weightKg =>
      items.fold(0.0, (total, item) => total + item.weightKg);

  bool get withinLimit => weightKg <= limitKg + 0.0001;

  double get fillRatio => limitKg == 0 ? 0 : weightKg / limitKg;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
}

class GuardrailCheck {
  const GuardrailCheck({
    required this.id,
    required this.statement,
    required this.blocker,
    required this.passed,
    this.detail,
  });

  final String id;
  final String statement;
  final bool blocker;
  final bool passed;
  final String? detail;
}

class GuardrailReport {
  const GuardrailReport(this.checks);

  final List<GuardrailCheck> checks;

  int get blockersFired =>
      checks.where((check) => check.blocker && !check.passed).length;

  bool get clean => blockersFired == 0;

  List<GuardrailCheck> get fired =>
      checks.where((check) => !check.passed).toList();
}

class PlanResult {
  PlanResult({
    required this.tier,
    required this.items,
    required this.bags,
    required this.coveredCategories,
    required this.gaps,
    required this.dropped,
    required this.caloriesByPerson,
    required this.guardrails,
    this.notes = const [],
    this.unverifiedPriceCount = 0,
  });

  final PlanTier tier;
  final List<PlanItem> items;
  final Map<String, PersonBag> bags;
  final Set<LCategory> coveredCategories;
  final Set<LCategory> gaps;
  final List<String> dropped;
  final Map<String, int> caloriesByPerson;
  final GuardrailReport guardrails;
  final List<String> notes;
  final int unverifiedPriceCount;

  double get totalPrice =>
      items.fold(0.0, (total, item) => total + item.priceEur);

  double get totalWeight =>
      bags.values.fold(0.0, (total, bag) => total + bag.weightKg);

  bool get everyBagWithinLimit => bags.values.every((bag) => bag.withinLimit);

  PersonBag bagFor(String personId) => bags[personId]!;

  /// 0–1 coverage of the critical LT72 categories. Diagram-ready assignment
  /// lives in [bags] and in each item's carrier/beneficiary ids.
  double get coverageScore {
    final total = criticalCategories.length;
    return (coveredCategories.length / total).clamp(0, 1).toDouble();
  }

  List<PlanItem> itemsForCarrier(String personId) =>
      items.where((item) => item.carrierId == personId).toList();
}

class PlanRequest {
  const PlanRequest({
    required this.household,
    required this.needs,
    required this.tier,
    required this.languageCode,
  });

  final List<Person> household;
  final ParsedNeeds needs;
  final PlanTier tier;
  final String languageCode;
}
