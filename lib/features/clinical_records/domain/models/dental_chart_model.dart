enum ToothCondition {
  healthy,
  decayed,
  filled,
  crown,
  missing,
  rct,
  impacted,
}

class ToothRecord {
  final int toothNumber; // FDI 11-48
  final ToothCondition condition;
  final String? clinicalNote;

  const ToothRecord({
    required this.toothNumber,
    this.condition = ToothCondition.healthy,
    this.clinicalNote,
  });

  ToothRecord copyWith({
    int? toothNumber,
    ToothCondition? condition,
    String? clinicalNote,
  }) {
    return ToothRecord(
      toothNumber: toothNumber ?? this.toothNumber,
      condition: condition ?? this.condition,
      clinicalNote: clinicalNote ?? this.clinicalNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'toothNumber': toothNumber,
        'condition': condition.name,
        'clinicalNote': clinicalNote,
      };

  factory ToothRecord.fromJson(Map<String, dynamic> json) => ToothRecord(
        toothNumber: json['toothNumber'] as int,
        condition: ToothCondition.values.firstWhere(
          (e) => e.name == json['condition'],
          orElse: () => ToothCondition.healthy,
        ),
        clinicalNote: json['clinicalNote'] as String?,
      );
}
