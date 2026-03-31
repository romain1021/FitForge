import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/history_entry.dart';

class HistoryRepository {
  const HistoryRepository();

  static const String _assetPath = 'assets/historique.json';
  static const String _fileName = 'historique.json';

  Future<String> _loadInitialContent() async {
    try {
      return await rootBundle.loadString(_assetPath);
    } catch (_) {
      return '[]';
    }
  }

  Future<File?> _getWorkspaceHistoryFileIfWritable() async {
    final File workspaceFile = File(_assetPath);

    if (!await workspaceFile.exists()) {
      return null;
    }

    try {
      final String content = await workspaceFile.readAsString();
      if (content.trim().isEmpty) {
        await workspaceFile.writeAsString('[]', flush: true);
      }
      return workspaceFile;
    } catch (_) {
      return null;
    }
  }

  Future<File> _getHistoryFile() async {
    final File? workspaceFile = await _getWorkspaceHistoryFileIfWritable();
    if (workspaceFile != null) {
      return workspaceFile;
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    final File historyFile = File('${directory.path}/$_fileName');

    if (await historyFile.exists()) {
      return historyFile;
    }

    final String initialContent = await _loadInitialContent();
    await historyFile.writeAsString(initialContent, flush: true);
    return historyFile;
  }

  Future<List<HistoryEntry>> loadHistory() async {
    final File file = await _getHistoryFile();
    final String rawJson = await file.readAsString();

    if (rawJson.trim().isEmpty) {
      return const <HistoryEntry>[];
    }

    final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;

    final List<HistoryEntry> entries = decoded
        .map((item) => HistoryEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> addExercise(int exerciseId) async {
    final List<HistoryEntry> current = await loadHistory();

    final List<HistoryEntry> updated = <HistoryEntry>[
      HistoryEntry(exerciseId: exerciseId, date: DateTime.now()),
      ...current,
    ];

    final File file = await _getHistoryFile();
    final String json = jsonEncode(updated.map((entry) => entry.toJson()).toList());
    await file.writeAsString(json, flush: true);
  }
}
