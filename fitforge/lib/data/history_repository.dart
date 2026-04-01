import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/history_entry.dart';

class HistoryRepository {
  const HistoryRepository();

  static const String _assetPath = 'assets/historique.json';
  static const String _fileName = 'historique.json';

  List<File> _workspaceHistoryCandidates() {
    final Set<String> candidatePaths = <String>{
      _assetPath,
      '${Directory.current.path}/$_assetPath',
      '${Directory.current.path}/assets/$_fileName',
    };

    Directory cursor = Directory.current;
    for (int i = 0; i < 10; i++) {
      candidatePaths.add('${cursor.path}/assets/$_fileName');
      final Directory parent = cursor.parent;
      if (parent.path == cursor.path) {
        break;
      }
      cursor = parent;
    }

    return candidatePaths.map((path) => File(path)).toList(growable: false);
  }

  Future<void> _addScriptBasedCandidates(Set<String> candidatePaths) async {
    final Uri scriptUri = Platform.script;
    if (scriptUri.scheme == 'file') {
      final Directory scriptDir = File.fromUri(scriptUri).parent;
      Directory cursor = scriptDir;
      for (int i = 0; i < 12; i++) {
        candidatePaths.add('${cursor.path}/assets/$_fileName');
        final Directory parent = cursor.parent;
        if (parent.path == cursor.path) {
          break;
        }
        cursor = parent;
      }
    }

    final Uri? packageMainUri = await Isolate.resolvePackageUri(
      Uri.parse('package:fitforge/main.dart'),
    );

    if (packageMainUri == null || packageMainUri.scheme != 'file') {
      return;
    }

    final Directory libDir = File.fromUri(packageMainUri).parent;
    final Directory projectRoot = libDir.parent;
    candidatePaths.add('${projectRoot.path}/assets/$_fileName');
  }

  Future<String> _loadInitialContent() async {
    try {
      return await rootBundle.loadString(_assetPath);
    } catch (_) {
      return '[]';
    }
  }

  Future<File?> _getWorkspaceHistoryFileIfWritable() async {
    final Set<String> candidatePaths = _workspaceHistoryCandidates()
        .map((file) => file.path)
        .toSet();
    await _addScriptBasedCandidates(candidatePaths);

    for (final String path in candidatePaths) {
      final File workspaceFile = File(path);
      if (!await workspaceFile.exists()) {
        continue;
      }

      try {
        final String content = await workspaceFile.readAsString();
        if (content.trim().isEmpty) {
          await workspaceFile.writeAsString('[]', flush: true);
        }
        return workspaceFile;
      } catch (_) {
        continue;
      }
    }

    return null;
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
    final String json = jsonEncode(
      updated.map((entry) => entry.toJson()).toList(),
    );
    await file.writeAsString(json, flush: true);
  }
}
