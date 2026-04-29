import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../models/exercise.dart';

class GenerateSessionPage extends StatefulWidget {
  const GenerateSessionPage({super.key});

  @override
  State<GenerateSessionPage> createState() => _GenerateSessionPageState();
}

class _GenerateSessionPageState extends State<GenerateSessionPage> {
  static const int _minDuration = 4;
  static const int _maxDuration = 90;
  static const Map<String, int> _levelOrder = <String, int>{
    'debutant': 0,
    'débutant': 0,
    'intermediaire': 1,
    'intermédiaire': 1,
    'avance': 2,
    'avancé': 2,
  };

  late final Future<List<Exercise>> _exercisesFuture;
  int _durationMinutes = 30;
  double _difficulty = 0;
  List<Exercise> _generatedExercises = const <Exercise>[];

  @override
  void initState() {
    super.initState();
    _exercisesFuture = const ExerciseRepository().loadExercises();
  }

  String get _durationLabel {
    final int hours = _durationMinutes ~/ 60;
    final int minutes = _durationMinutes % 60;

    if (hours == 0) {
      return '$_durationMinutes min';
    }
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }

  String get _difficultyLabel {
    switch (_difficulty.round()) {
      case 0:
        return 'Debutant';
      case 1:
        return 'Intermediaire';
      default:
        return 'Avance';
    }
  }

  String _normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll('à', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u');
  }

  int _levelToOrder(String level) {
    return _levelOrder[_normalizeText(level)] ?? 99;
  }

  List<Exercise> _buildSessionExercises(List<Exercise> allExercises) {
    if (allExercises.isEmpty) {
      return const <Exercise>[];
    }

    final int targetLevel = _difficulty.round();
    final int targetDuration = _durationMinutes;

    final List<Exercise> candidates = allExercises
        .where((exercise) => _levelToOrder(exercise.level) <= targetLevel)
        .toList(growable: false);

    final List<Exercise> baseCandidates = candidates.isNotEmpty
        ? candidates
        : allExercises;

    final List<Exercise> byDurationDesc = List<Exercise>.from(baseCandidates)
      ..sort((a, b) {
        final int durationCompare = b.durationMinutes.compareTo(
          a.durationMinutes,
        );
        if (durationCompare != 0) {
          return durationCompare;
        }
        return a.id.compareTo(b.id);
      });

    final List<Exercise> byDurationAsc = List<Exercise>.from(baseCandidates)
      ..sort((a, b) {
        final int durationCompare = a.durationMinutes.compareTo(
          b.durationMinutes,
        );
        if (durationCompare != 0) {
          return durationCompare;
        }
        return a.id.compareTo(b.id);
      });

    final List<Exercise> selected = <Exercise>[];
    int remaining = targetDuration;

    while (remaining > 0) {
      Exercise? next;

      for (final Exercise exercise in byDurationDesc) {
        if (selected.any((e) => e.id == exercise.id)) {
          continue;
        }
        if (exercise.durationMinutes <= remaining) {
          next = exercise;
          break;
        }
      }

      if (next == null) {
        for (final Exercise exercise in byDurationAsc) {
          if (selected.any((e) => e.id == exercise.id)) {
            continue;
          }
          next = exercise;
          break;
        }
      }

      if (next == null) {
        break;
      }

      selected.add(next);
      remaining -= next.durationMinutes;

      if (remaining <= 0) {
        break;
      }
      if (selected.length >= baseCandidates.length) {
        break;
      }
    }

    return selected;
  }

  int _sessionDuration(List<Exercise> exercises) {
    return exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.durationMinutes,
    );
  }

  void _generateSession(List<Exercise> allExercises) {
    setState(() {
      _generatedExercises = _buildSessionExercises(allExercises);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Exercise>>(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('Generer une seance')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duree', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  _durationLabel,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Slider(
                  value: _durationMinutes.toDouble(),
                  min: _minDuration.toDouble(),
                  max: _maxDuration.toDouble(),
                  divisions: (_maxDuration - _minDuration) ~/ 5,
                  label: _durationLabel,
                  onChanged: (value) {
                    setState(() {
                      _durationMinutes = value.round();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Difficulte',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _difficultyLabel,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Slider(
                  value: _difficulty,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  label: _difficultyLabel,
                  onChanged: (value) {
                    setState(() {
                      _difficulty = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: snapshot.hasData
                        ? () => _generateSession(
                            snapshot.data ?? const <Exercise>[],
                          )
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Generer'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_generatedExercises.isNotEmpty)
                  Text(
                    'Seance generee: ${_sessionDuration(_generatedExercises)} min (${_generatedExercises.length} exercices)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Impossible de charger les exercices.'),
                        );
                      }

                      if (_generatedExercises.isEmpty) {
                        return const Center(
                          child: Text(
                            'Choisis tes parametres puis appuie sur Generer.',
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: _generatedExercises.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final Exercise exercise = _generatedExercises[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(label: Text(exercise.group)),
                                      Chip(label: Text(exercise.level)),
                                      Chip(
                                        label: Text(
                                          '${exercise.durationMinutes} min',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(exercise.description),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
