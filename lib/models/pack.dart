class PackEntry {
  const PackEntry({
    this.checked = false,
    this.expiry,
    this.reminded60 = false,
    this.reminded14 = false,
    this.packedAt,
  });

  final bool checked;
  final DateTime? expiry;
  final bool reminded60;
  final bool reminded14;
  final DateTime? packedAt;

  DateTime? get reminder60 => expiry?.subtract(const Duration(days: 60));
  DateTime? get reminder14 => expiry?.subtract(const Duration(days: 14));

  PackEntry copyWith({
    bool? checked,
    DateTime? expiry,
    bool? reminded60,
    bool? reminded14,
    DateTime? packedAt,
    bool clearPackedAt = false,
  }) => PackEntry(
    checked: checked ?? this.checked,
    expiry: expiry ?? this.expiry,
    reminded60: reminded60 ?? this.reminded60,
    reminded14: reminded14 ?? this.reminded14,
    packedAt: clearPackedAt ? null : (packedAt ?? this.packedAt),
  );

  Map<String, dynamic> toJson() => {
    'checked': checked,
    'expiry': expiry?.toIso8601String(),
    'reminded60': reminded60,
    'reminded14': reminded14,
    'packedAt': packedAt?.toIso8601String(),
  };

  factory PackEntry.fromJson(Map<String, dynamic> json) => PackEntry(
    checked: json['checked'] as bool? ?? false,
    expiry: json['expiry'] == null
        ? null
        : DateTime.tryParse(json['expiry'] as String),
    reminded60: json['reminded60'] as bool? ?? false,
    reminded14: json['reminded14'] as bool? ?? false,
    packedAt: json['packedAt'] == null
        ? null
        : DateTime.tryParse(json['packedAt'] as String),
  );
}

class PackProgress {
  const PackProgress(this.entries);

  final Map<String, PackEntry> entries;

  PackEntry entryFor(String key) => entries[key] ?? const PackEntry();

  PackProgress withEntry(String key, PackEntry entry) =>
      PackProgress({...entries, key: entry});

  Map<String, dynamic> toJson() => {
    for (final entry in entries.entries) entry.key: entry.value.toJson(),
  };

  factory PackProgress.fromJson(Map<String, dynamic> json) => PackProgress({
    for (final entry in json.entries)
      entry.key: PackEntry.fromJson(entry.value as Map<String, dynamic>),
  });

  static PackProgress empty() => const PackProgress({});
}
