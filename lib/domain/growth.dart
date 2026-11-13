import '../models/person.dart';

/// Simple growth projection. Heights are approximate WHO median height-for-age
/// values for a unisex child, interpolated by year. This is a planning hint,
/// not a medical measurement. Method and sources live in docs/RESEARCH.md.
class GrowthProjection {
  const GrowthProjection({
    required this.currentHeightCm,
    required this.nextHeightCm,
    required this.clothingSize,
    required this.nextClothingSize,
    required this.backpackLitres,
    required this.nextReview,
    required this.reviewMonths,
  });

  final double currentHeightCm;
  final double nextHeightCm;
  final String clothingSize;
  final String nextClothingSize;
  final int backpackLitres;
  final DateTime nextReview;
  final int reviewMonths;

  bool get needsBiggerBackpack =>
      backpackLitresForAge(_ageForHeight(nextHeightCm)) > backpackLitres;
}

GrowthProjection project(Person person, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final age = person.age;
  final current = _medianHeight(age);
  final next = _medianHeight(age + 1);
  final reviewMonths = age < 6 ? 6 : 12;
  return GrowthProjection(
    currentHeightCm: current,
    nextHeightCm: next,
    clothingSize: _clothingSize(current),
    nextClothingSize: _clothingSize(next),
    backpackLitres: backpackLitresForAge(age),
    nextReview: DateTime(today.year, today.month + reviewMonths, today.day),
    reviewMonths: reviewMonths,
  );
}

int backpackLitresForAge(int age) {
  if (age < 4) return 12;
  if (age < 8) return 20;
  if (age < 12) return 30;
  if (age <= 14) return 35;
  return 45;
}

DateTime nextReviewDate(Person person, {DateTime? now}) =>
    project(person, now: now).nextReview;

/// Median height-for-age, 0-18 years, unisex approximation.
const List<double> _heights = [
  50.0,
  76.0,
  87.0,
  96.0,
  103.0,
  110.0,
  116.0,
  122.0,
  128.0,
  133.0,
  138.0,
  144.0,
  151.0,
  158.0,
  163.0,
  167.0,
  170.0,
  172.0,
  173.0,
];

double _medianHeight(int age) {
  if (age <= 0) return _heights.first;
  if (age >= _heights.length) return _heights.last;
  return _heights[age];
}

int _ageForHeight(double heightCm) {
  for (var age = 0; age < _heights.length; age++) {
    if (_heights[age] >= heightCm) return age;
  }
  return 18;
}

String _clothingSize(double heightCm) {
  const sizes = [
    (56.0, '50/56'),
    (68.0, '62/68'),
    (80.0, '74/80'),
    (92.0, '86/92'),
    (104.0, '98/104'),
    (116.0, '110/116'),
    (128.0, '122/128'),
    (140.0, '134/140'),
    (152.0, '146/152'),
    (164.0, '158/164'),
  ];
  for (final size in sizes) {
    if (heightCm < size.$1) return size.$2;
  }
  return '170/176';
}

class ExpiryReminders {
  const ExpiryReminders({required this.sixtyDays, required this.fourteenDays});

  final DateTime sixtyDays;
  final DateTime fourteenDays;

  static ExpiryReminders forExpiry(DateTime expiry) => ExpiryReminders(
    sixtyDays: expiry.subtract(const Duration(days: 60)),
    fourteenDays: expiry.subtract(const Duration(days: 14)),
  );
}
