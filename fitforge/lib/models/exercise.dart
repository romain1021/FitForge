class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.group,
    required this.durationMinutes,
    required this.level,
  });

  final int id;
  final String name;
  final String description;
  final String group;
  final int durationMinutes;
  final String level;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['nom'] as String,
      description: json['description'] as String,
      group: json['groupe'] as String,
      durationMinutes: json['duree'] as int,
      level: json['niveau'] as String,
    );
  }
}
