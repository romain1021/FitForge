class HistoryEntry {
  const HistoryEntry({
    required this.exerciseId,
    required this.date,
  });

  final int exerciseId;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': exerciseId,
      'date': date.toIso8601String(),
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      exerciseId: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
