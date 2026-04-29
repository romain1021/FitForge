import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../models/exercise.dart';

enum ExerciseSortOption {
  nameAsc,
  durationAsc,
  durationDesc,
  levelAsc,
  groupAsc,
}

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  late final Future<List<Exercise>> _exercisesFuture;
  String _searchQuery = '';
  ExerciseSortOption _sortOption = ExerciseSortOption.nameAsc;

  static const Map<String, int> _levelOrder = <String, int>{
    'debutant': 0,
    'débutant': 0,
    'intermediaire': 1,
    'intermédiaire': 1,
    'avance': 2,
    'avancé': 2,
  };

  @override
  void initState() {
    super.initState();
    _exercisesFuture = const ExerciseRepository().loadExercises();
  }

  List<Exercise> _applySearchAndSort(List<Exercise> exercises) {
    final String query = _normalizeText(_searchQuery.trim());

    final List<Exercise> filtered = exercises
        .where((exercise) {
          if (query.isEmpty) {
            return true;
          }

          final String content = _normalizeText(
            '${exercise.name} ${exercise.description} ${exercise.group} ${exercise.level}',
          );
          return content.contains(query);
        })
        .toList(growable: false);

    final List<Exercise> sorted = List<Exercise>.from(filtered);
    sorted.sort(_exerciseComparator);
    return sorted;
  }

  int _exerciseComparator(Exercise a, Exercise b) {
    switch (_sortOption) {
      case ExerciseSortOption.nameAsc:
        return _normalizeText(a.name).compareTo(_normalizeText(b.name));
      case ExerciseSortOption.durationAsc:
        return a.durationMinutes.compareTo(b.durationMinutes);
      case ExerciseSortOption.durationDesc:
        return b.durationMinutes.compareTo(a.durationMinutes);
      case ExerciseSortOption.levelAsc:
        final int aLevel = _levelOrder[_normalizeText(a.level)] ?? 99;
        final int bLevel = _levelOrder[_normalizeText(b.level)] ?? 99;
        return aLevel.compareTo(bLevel);
      case ExerciseSortOption.groupAsc:
        return _normalizeText(a.group).compareTo(_normalizeText(b.group));
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

  String _sortLabel(ExerciseSortOption option) {
    switch (option) {
      case ExerciseSortOption.nameAsc:
        return 'Nom (A-Z)';
      case ExerciseSortOption.durationAsc:
        return 'Duree (croissante)';
      case ExerciseSortOption.durationDesc:
        return 'Duree (decroissante)';
      case ExerciseSortOption.levelAsc:
        return 'Niveau';
      case ExerciseSortOption.groupAsc:
        return 'Groupe';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des exercices')),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les exercices.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<Exercise> exercises = snapshot.data ?? const <Exercise>[];
          final List<Exercise> visibleExercises = _applySearchAndSort(
            exercises,
          );

          if (exercises.isEmpty) {
            return const Center(child: Text('Aucun exercice disponible.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Rechercher un exercice',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: DropdownButtonFormField<ExerciseSortOption>(
                  initialValue: _sortOption,
                  decoration: const InputDecoration(
                    labelText: 'Trier par',
                    border: OutlineInputBorder(),
                  ),
                  items: ExerciseSortOption.values
                      .map(
                        (option) => DropdownMenuItem<ExerciseSortOption>(
                          value: option,
                          child: Text(_sortLabel(option)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _sortOption = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: visibleExercises.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun exercice ne correspond a la recherche.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visibleExercises.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final Exercise exercise = visibleExercises[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exercise.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ],
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
