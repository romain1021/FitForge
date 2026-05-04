# FitForge

FitForge est une application Flutter de fitness qui propose un catalogue d'exercices et un générateur de séance simple.

## Fonctionnalités

### Accueil

L'écran d'accueil donne accès aux deux fonctions principales de l'application :

- Générer une séance d'entraînement.
- Consulter le catalogue des exercices.

### Catalogue des exercices

La page de liste permet de :

- charger les exercices depuis le fichier `assets/exercices.json` ;
- rechercher un exercice par nom, description, groupe ou niveau ;
- trier les résultats par nom, durée, niveau ou groupe ;
- consulter pour chaque exercice son nom, son groupe, son niveau, sa durée et sa description.

### Génération de séance

La page de génération permet de :

- choisir une durée cible entre 4 et 90 minutes ;
- choisir un niveau de difficulté entre débutant, intermédiaire et avancé ;
- générer automatiquement une liste d'exercices adaptée aux paramètres choisis ;
- afficher la durée totale et le nombre d'exercices de la séance produite.

## Structure des données

- `lib/models/exercise.dart` définit le modèle `Exercise`.
- `lib/data/exercise_repository.dart` charge et trie les exercices.
- `lib/pages/home_page.dart` affiche l'écran d'accueil.
- `lib/pages/exercise_list_page.dart` affiche le catalogue et les filtres.
- `lib/pages/generate_session_page.dart` gère la génération de séance.

## Lancer l'application

```bash
flutter pub get
flutter run
```
