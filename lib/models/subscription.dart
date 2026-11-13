import '../config/app_config.dart';
import 'person.dart';

class SubscriptionLine {
  const SubscriptionLine({required this.person, required this.monthlyEur});

  final Person person;
  final double monthlyEur;
}

class SubscriptionQuote {
  const SubscriptionQuote(this.lines);

  final List<SubscriptionLine> lines;

  double get totalEur => lines.fold(0.0, (sum, line) => sum + line.monthlyEur);

  bool get hasChildren =>
      lines.any((line) => line.person.isChild || line.person.isToddler);

  static SubscriptionQuote forHousehold(List<Person> people) {
    return SubscriptionQuote([
      for (final person in people)
        SubscriptionLine(
          person: person,
          monthlyEur: AppConfig.monthlyPrice(person.group),
        ),
    ]);
  }
}
