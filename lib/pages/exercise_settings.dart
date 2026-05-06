import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/pages/settings_widgets.dart';
import 'package:flutter/material.dart';

class ExerciseSettings extends StatelessWidget {
  const ExerciseSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  Widget perExerciseSettings() {
    switch (appState.appConfig.sharedExercise.curExerciseType) {
      case ExerciseType.ttr:
        return RecognitionPracticeSettings(appState: appState);
      case ExerciseType.familiarity:
        return FamiliarityPracticeSettings(appState: appState);
      case ExerciseType.copyGroups:
        return CopyGroupsSettings(appState: appState);
      case ExerciseType.sending:
        return SendingPracticeSettings(appState: appState);
      case ExerciseType.words:
        return WordsPracticeSettings(appState: appState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CwSpeedSettings(appState: appState),
      perExerciseSettings(),
    ]);
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
        GroupSizeSetting(appState: appState),
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
        GroupSizeSetting(appState: appState),
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
        GroupSizeSetting(appState: appState),
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
      ],
    );
  }
}

class WordsPracticeSettings extends StatelessWidget {
  const WordsPracticeSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DelayBeforeSpeakingSetting(appState: appState),
      ],
    );
  }
}
