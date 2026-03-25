import 'package:flutter/material.dart';

import 'exercise_list_page.dart';
import 'generate_session_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Accueil FitForge'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const GenerateSessionPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generer une seance'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const ExerciseListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.fitness_center),
                label: const Text('Catalogue'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history),
                label: const Text('Historique'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
