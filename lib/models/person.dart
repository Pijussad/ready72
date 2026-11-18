import '../config/app_config.dart';

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.age,
    required this.weightKg,
  });

  final String id;
  final String name;
  final int age;
  final double weightKg;

  AgeGroup get group => AppConfig.ageGroupFor(age);
  bool get isChild => group == AgeGroup.child;
  bool get isToddler => group == AgeGroup.toddler;
  bool get isSenior => group == AgeGroup.senior;
  bool get isAdult => group == AgeGroup.adult;
  bool get canCarrySharedLoad => isAdult && weightKg >= 40;
  bool get isDependent => isToddler;

  Person copyWith({String? name, int? age, double? weightKg}) => Person(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    weightKg: weightKg ?? this.weightKg,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'weightKg': weightKg,
  };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    name: json['name'] as String,
    age: (json['age'] as num).toInt(),
    weightKg: (json['weightKg'] as num).toDouble(),
  );
}

class DemoHousehold {
  DemoHousehold._();

  static const List<Person> people = [
    Person(id: 'p-jonas', name: 'Jonas', age: 34, weightKg: 82),
    Person(id: 'p-ruta', name: 'Rūta', age: 32, weightKg: 64),
    Person(id: 'p-mia', name: 'Mia', age: 2, weightKg: 13),
    Person(id: 'p-ona', name: 'Maria', age: 71, weightKg: 62),
  ];

  static const String needsText =
      'Grandma Maria has diabetes. Mia is 2 and still in diapers. We have a dog.';
}
