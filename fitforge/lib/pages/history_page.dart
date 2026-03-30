import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../data/history_repository.dart';
import '../models/exercise.dart';
import '../models/history_entry.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final Future<_HistoryViewData> _historyViewDataFuture;

  @override
  void initState() {
    super.initState();
    _historyViewDataFuture = _loadViewData();
  }

  Future<_HistoryViewData> _loadViewData() async {
    final ExerciseRepository exerciseRepository = const ExerciseRepository();
    final HistoryRepository historyRepository = const HistoryRepository();

    final List<Exercise> exercises = await exerciseRepository.loadExercises();
    final List<HistoryEntry> historyEntries = await historyRepository.loadHistory();

    final Map<int, Exercise> byId = <int, Exercise>{
      for (final Exercise exercise in exercises) exercise.id: exercise,
    };

    final Map<int, _ExerciseHistoryItem> grouped = <int, _ExerciseHistoryItem>{};

    for (final HistoryEntry entry in historyEntries) {
      final _ExerciseHistoryItem? current = grouped[entry.exerciseId];
      if (current == null) {
        grouped[entry.exerciseId] = _ExerciseHistoryItem(
          exerciseId: entry.exerciseId,
          count: 1,
          lastDate: entry.date,
          exercise: byId[entry.exerciseId],
        );
      } else {
        grouped[entry.exerciseId] = current.copyWith(
          count: current.count + 1,
          lastDate: entry.date.isAfter(current.lastDate)
              ? entry.date
              : current.lastDate,
        );
      }
    }

    final List<_ExerciseHistoryItem> items = grouped.values.toList(growable: false)
      ..sort((a, b) => b.lastDate.compareTo(a.lastDate));

    return _HistoryViewData(items: items);
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  String _buildDetails(Exercise? exercise) {
    if (exercise == null) {
      return 'Exercice introuvable dans le catalogue actuel.';
    }

    return '${exercise.description}\n'
        'Groupe: ${exercise.group} | Niveau: ${exercise.level} | Duree: ${exercise.durationMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: FutureBuilder<_HistoryViewData>(
        future: _historyViewDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Impossible de charger l\'historique.'),
              ),
            );
          }

          final List<_ExerciseHistoryItem> items = snapshot.data?.items ?? const <_ExerciseHistoryItem>[];

          if (items.isEmpty) {
            return const Center(
              child: Text('Aucun exercice n\'a encore ete ajoute a l\'historique.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final _ExerciseHistoryItem item = items[index];
              final Exercise? exercise = item.exercise;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise?.name ?? 'Exercice #${item.exerciseId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Derniere date: ${_formatDate(item.lastDate)}'),
                      const SizedBox(height: 6),
                      Text('Nombre de fois realise: ${item.count}'),
                      const SizedBox(height: 8),
                      Text(_buildDetails(exercise)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryViewData {
  const _HistoryViewData({required this.items});

  final List<_ExerciseHistoryItem> items;
}

class _ExerciseHistoryItem {
  const _ExerciseHistoryItem({
    required this.exerciseId,
    required this.count,
    required this.lastDate,
    required this.exercise,
  });

  final int exerciseId;
  final int count;
  final DateTime lastDate;
  final Exercise? exercise;

  _ExerciseHistoryItem copyWith({
    int? count,
    DateTime? lastDate,
  }) {
    return _ExerciseHistoryItem(
      exerciseId: exerciseId,
      count: count ?? this.count,
      lastDate: lastDate ?? this.lastDate,
      exercise: exercise,
    );
  }
}
