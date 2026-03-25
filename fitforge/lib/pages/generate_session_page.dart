import 'package:flutter/material.dart';

class GenerateSessionPage extends StatefulWidget {
  const GenerateSessionPage({super.key});

  @override
  State<GenerateSessionPage> createState() => _GenerateSessionPageState();
}

class _GenerateSessionPageState extends State<GenerateSessionPage> {
  static const int _minDuration = 10;
  static const int _maxDuration = 180;

  int _durationMinutes = 30;
  double _difficulty = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generer une seance')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duree', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_durationLabel, style: Theme.of(context).textTheme.bodyLarge),
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
            Text('Difficulte', style: Theme.of(context).textTheme.titleMedium),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Generer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
