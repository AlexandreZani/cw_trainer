import 'package:cw_trainer/exercises/exercise_definition.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/pages/settings_widgets.dart';
import 'package:flutter/material.dart';

class ExerciseSettings extends StatelessWidget {
  final MyAppState appState;

  const ExerciseSettings({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    ExerciseDefinition def =
        ExerciseController.getCurrentDefinition(appState.appConfig);
    return Column(
        children: def
            .getPracticeSettings()
            .map((e) => switch (e) {
                  PracticeSettings.cwSpeed =>
                    CwSpeedSettings(appState: appState),
                  PracticeSettings.delayAfterSpeaking =>
                    DelayAfterSpeakingSetting(appState: appState),
                  PracticeSettings.delayBeforeSpeaking =>
                    DelayBeforeSpeakingSetting(appState: appState),
                  PracticeSettings.numberOfGroups =>
                    ExerciseNumber(appState: appState, allowContinuous: false),
                  PracticeSettings.groupSize =>
                    GroupSizeSetting(appState: appState),
                  PracticeSettings.timeBetweenGroups =>
                    TimeBetweenGroupsSetting(appState: appState),
                })
            .toList());
  }
}