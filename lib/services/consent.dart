class ConsentRecord {
  const ConsentRecord({
    required this.version,
    required this.grantedAt,
    required this.purposes,
    required this.reminders,
    this.ipHash,
  });

  final String version;
  final DateTime grantedAt;
  final Set<String> purposes;
  final bool reminders;

  /// No IP is collected in this on-device prototype. The field exists so a
  /// production backend can store a salted hash instead of a raw address.
  final String? ipHash;

  Map<String, dynamic> toJson() => {
    'version': version,
    'grantedAt': grantedAt.toIso8601String(),
    'purposes': purposes.toList(),
    'reminders': reminders,
    'ipHash': ipHash,
  };

  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
    version: json['version'] as String,
    grantedAt: DateTime.parse(json['grantedAt'] as String),
    purposes: ((json['purposes'] as List<dynamic>?) ?? [])
        .map((item) => item.toString())
        .toSet(),
    reminders: json['reminders'] as bool? ?? false,
    ipHash: json['ipHash'] as String?,
  );
}

class ConsentRequiredException implements Exception {
  const ConsentRequiredException();

  @override
  String toString() => 'ConsentRequiredException';
}
