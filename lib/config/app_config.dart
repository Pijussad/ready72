/// Product and safety configuration for Ready72.
///
/// All thresholds live here so they can be reviewed in one place.
/// Sources are documented in docs/RESEARCH.md.
library;

enum AgeGroup { toddler, child, adult, senior }

class AppConfig {
  AppConfig._();

  static const String consentVersion = '1.0';
  static const int seniorAge = 65;
  static const int childMaxAge = 14;
  static const int toddlerMaxAge = 4;

  /// LT72 recommends carrying no more than one fifth of body weight.
  /// We apply that as the adult ceiling, with lower caps for dependants.
  static const double adultShare = 0.20;
  static const double seniorShare = 0.12;
  static const double childShare = 0.15;
  static const double toddlerShare = 0.03;

  /// Absolute caps keep a heavy adult from carrying a 30 kg load even when
  /// 20% of body weight would allow it. Body weight is not a proxy for
  /// strength: above 120 kg we lower the ceiling again, and above 180 kg
  /// further still. See docs/RESEARCH.md.
  static const double adultCapKg = 15.0;
  static const double seniorCapKg = 10.0;
  static const double childCapKg = 8.0;
  static const double toddlerCapKg = 2.5;

  static const double heavyAdultWeightKg = 120.0;
  static const double heavyAdultCapKg = 12.0;
  static const double veryHeavyAdultWeightKg = 180.0;
  static const double veryHeavyAdultCapKg = 10.0;

  /// A disclosed back problem, pregnancy or mobility aid lowers the limit.
  static const double reducedCapacityFactor = 0.60;

  static const int medicationBufferDays = 14;

  /// Minimum remaining shelf life for food bought into a stored bag.
  static const int minimumShelfLifeMonths = 12;

  /// Subscription prices in EUR per month.
  static const double childMonthly = 5.0;
  static const double adultMonthly = 4.0;
  static const double seniorMonthly = 3.0;

  /// Water carried per person per day. LT72 states 2-4 litres; carrying all
  /// of it would break every carry limit, so Ready72 carries a baseline and
  /// relies on the mandatory filter/tablets for the rest. The plan states
  /// this trade-off instead of hiding it.
  static const double essentialWaterLitresPerDay = 1.0;

  /// Both tiers carry the same baseline. Comfort spends spare capacity on
  /// warmth and shelter, not on extra water weight.
  static const double comfortWaterLitresPerDay = 1.0;

  /// Daily calorie targets for 72 hours (mild activity, no cooking fuel
  /// assumptions beyond the included stove).
  static const double adultCaloriesPerDay = 2000;
  static const double seniorCaloriesPerDay = 1800;
  static const double childCaloriesPerDay = 1400;
  static const double toddlerCaloriesPerDay = 1000;

  static const String privacyNoticeUrl = '';
  static const String lt72SourceUrl = 'https://lt72.lt/isvykimo-krepsys-5/';
  static const String lt72Retrieved = '2026-11-13';

  static AgeGroup ageGroupFor(int age) {
    if (age < toddlerMaxAge) return AgeGroup.toddler;
    if (age <= childMaxAge) return AgeGroup.child;
    if (age >= seniorAge) return AgeGroup.senior;
    return AgeGroup.adult;
  }

  static double dailyCalories(AgeGroup group) {
    switch (group) {
      case AgeGroup.toddler:
        return toddlerCaloriesPerDay;
      case AgeGroup.child:
        return childCaloriesPerDay;
      case AgeGroup.adult:
        return adultCaloriesPerDay;
      case AgeGroup.senior:
        return seniorCaloriesPerDay;
    }
  }

  static double waterLitresPerDay(AgeGroup group, {required bool comfort}) {
    final base = comfort
        ? comfortWaterLitresPerDay
        : essentialWaterLitresPerDay;
    if (group == AgeGroup.toddler) return base * 0.6;
    if (group == AgeGroup.senior) return base * 0.85;
    return base;
  }

  static double monthlyPrice(AgeGroup group) {
    switch (group) {
      case AgeGroup.toddler:
      case AgeGroup.child:
        return childMonthly;
      case AgeGroup.adult:
        return adultMonthly;
      case AgeGroup.senior:
        return seniorMonthly;
    }
  }
}
