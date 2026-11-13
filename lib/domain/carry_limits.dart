import '../config/app_config.dart';
import '../models/needs.dart';
import '../models/person.dart';

class CarryLimit {
  const CarryLimit({
    required this.limitKg,
    required this.share,
    required this.capKg,
    required this.reduced,
    required this.reasons,
  });

  final double limitKg;
  final double share;
  final double capKg;
  final bool reduced;
  final List<String> reasons;
}

class CarryLimits {
  CarryLimits._();

  static CarryLimit compute(Person person, PersonNeeds needs) {
    final weight = person.weightKg.clamp(2.0, 300.0);
    final share = _share(person.group);
    var cap = _cap(person.group);
    if (person.group == AgeGroup.adult) {
      if (weight >= AppConfig.veryHeavyAdultWeightKg) {
        if (cap > AppConfig.veryHeavyAdultCapKg) {
          cap = AppConfig.veryHeavyAdultCapKg;
        }
      } else if (weight >= AppConfig.heavyAdultWeightKg) {
        if (cap > AppConfig.heavyAdultCapKg) {
          cap = AppConfig.heavyAdultCapKg;
        }
      }
    }
    var limit = weight * share;
    if (limit > cap) limit = cap;
    final reduced = needs.needsReducedCapacity;
    if (reduced) limit *= AppConfig.reducedCapacityFactor;
    return CarryLimit(
      limitKg: _round(limit),
      share: share,
      capKg: cap,
      reduced: reduced,
      reasons: [
        if (needs.backProblem) 'back',
        if (needs.pregnant) 'pregnancy',
        if (needs.mobilityAid) 'mobility',
      ],
    );
  }

  static CarryLimit computeFor(Person person) =>
      compute(person, PersonNeeds(personId: person.id));

  static double _share(AgeGroup group) {
    switch (group) {
      case AgeGroup.toddler:
        return AppConfig.toddlerShare;
      case AgeGroup.child:
        return AppConfig.childShare;
      case AgeGroup.adult:
        return AppConfig.adultShare;
      case AgeGroup.senior:
        return AppConfig.seniorShare;
    }
  }

  static double _cap(AgeGroup group) {
    switch (group) {
      case AgeGroup.toddler:
        return AppConfig.toddlerCapKg;
      case AgeGroup.child:
        return AppConfig.childCapKg;
      case AgeGroup.adult:
        return AppConfig.adultCapKg;
      case AgeGroup.senior:
        return AppConfig.seniorCapKg;
    }
  }

  static double _round(double value) => (value * 100).roundToDouble() / 100;
}
