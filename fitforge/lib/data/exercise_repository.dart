import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exercise.dart';

class ExerciseRepository {
  const ExerciseRepository();

  static const List<String> _exerciseAssetPaths = <String>[
    'assets/exercices.json',
  ];

  Future<List<Exercise>> loadExercises() async {
    final List<Exercise> allExercises = <Exercise>[];

    for (final String assetPath in _exerciseAssetPaths) {
      final String rawJson = await rootBundle.loadString(assetPath);
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;

      allExercises.addAll(
        decoded.map((item) => Exercise.fromJson(item as Map<String, dynamic>)),
      );
    }

    allExercises.sort((a, b) => a.id.compareTo(b.id));
    return List<Exercise>.unmodifiable(allExercises);
  }
}
