import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/words.dart';
import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/pages/settings_widgets.dart';
import 'package:flutter/material.dart';

class ExerciseSettings extends StatelessWidget {
  const ExerciseSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    switch (appState.appConfig.sharedExercise.curExerciseType) {
      case ExerciseType.randomGroups:
        return RandomGroupLevelSelector(appState: appState);
      case ExerciseType.words:
        return WordsLevelSelector(appState: appState);
      case ExerciseType.recognition:
        return RecognitionPracticeSettings(appState: appState);
      case ExerciseType.familiarity:
        return const Column();
      case ExerciseType.copyGroups:
        return CopyGroupsSettings(appState: appState);
      case ExerciseType.sending:
        return SendingPracticeSettings(appState: appState);
    }
  }
}

class RandomGroupLevelSelector extends StatelessWidget {
  const RandomGroupLevelSelector({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LevelSelector(
          letters: appState.appConfig.randomGroups.letters,
          levelI: appState.appConfig.randomGroups.levelI,
          onChanged: (int i) {
            appState.appConfig.randomGroups.levelI = i;
          },
        ),
      ],
    );
  }
}

class WordsLevelSelector extends StatelessWidget {
  const WordsLevelSelector({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LevelSelector(
          letters: order,
          levelI: appState.appConfig.wordsExercise.levelI,
          onChanged: (int i) {
            appState.appConfig.wordsExercise.levelI = i;
          },
        ),
      ],
    );
  }
}

class RecognitionPracticeSettings extends StatelessWidget {
  const RecognitionPracticeSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DelayBeforeSpeakingSetting(appState: appState),
        GroupSize(appState: appState),
        ExerciseNumber(appState: appState, allowContinuous: true)
      ],
    );
  }
}

class CopyGroupsSettings extends StatelessWidget {
  const CopyGroupsSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimeBetweenGroupsSetting(appState: appState),
        GroupSize(appState: appState),
        ExerciseNumber(appState: appState, allowContinuous: false),
      ],
    );
  }
}

class SendingPracticeSettings extends StatelessWidget {
  const SendingPracticeSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimeBetweenGroupsSetting(appState: appState),
        GroupSize(appState: appState),
        ExerciseNumber(appState: appState, allowContinuous: true),
      ],
    );
  }
}

class FamiliarityPracticeSettings extends StatelessWidget {
  const FamiliarityPracticeSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DelayAfterSpeakingSetting(appState: appState),
        TimeBetweenGroupsSetting(appState: appState),
        ExerciseNumber(appState: appState, allowContinuous: true),
      ],
    );
  }
}
