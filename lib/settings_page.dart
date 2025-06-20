import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SettingsPage extends StatelessWidget {
  final log = Logger('SettingsPage');
  final MyAppState appState;

  SettingsPage({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    log.finest('building settings page');
    return ListView(
      children: [
        CWSettings(appState: appState),
        const Divider(),
        TTSSettings(appState: appState),
        SharedExerciseSettings(appState: appState),
        const Divider(),
        RandomGroupsSettings(appState: appState),
      ],
    );
  }
}

class SharedExerciseSettings extends StatelessWidget {
  const SharedExerciseSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const ListTile(title: Text('Exercises')),
        const Divider(),
        BoolSetting(
          label: "Continuous Exercise",
          initialValue: appState.appConfig.sharedExercise.repeat,
          onChanged: (bool v) {
            appState.appConfig.sharedExercise.repeat = v;
          },
        ),
        NumSettingChevron(
          label: "Exercise Number",
          initialValue: appState.appConfig.sharedExercise.exerciseNum,
          min: 1,
          max: 15,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.sharedExercise.exerciseNum = i;
          },
        ),
      ],
    );
  }
}

class RandomGroupsSettings extends StatelessWidget {
  const RandomGroupsSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(title: Text('Random Groups')),
        const Divider(),
        LevelSetting(appState: appState),
        NumSettingChevron(
          label: "Letters Per Group",
          initialValue: appState.appConfig.randomGroups.groupSize,
          min: 1,
          max: 10,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.randomGroups.groupSize = i;
          },
        ),
        BoolSetting(
          label: "Force Latest Letter",
          initialValue: appState.appConfig.randomGroups.forceLatest,
          onChanged: (bool v) {
            appState.appConfig.randomGroups.forceLatest = v;
          },
        ),
      ],
    );
  }
}

class TTSSettings extends StatelessWidget {
  const TTSSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(title: Text('Text-to-Speech')),
        const Divider(),
        NumSettingChevron(
          label: "Speech Rate",
          initialValue: appState.appConfig.tts.rate,
          min: 0.1,
          max: 1.0,
          step: 0.1,
          onSelected: (double i) {
            appState.appConfig.tts.rate = i;
          },
        ),
        NumSettingChevron(
          label: "Pitch",
          initialValue: appState.appConfig.tts.pitch,
          min: 0.1,
          max: 1.0,
          step: 0.1,
          onSelected: (double i) {
            appState.appConfig.tts.pitch = i;
          },
        ),
        NumSettingChevron(
          label: "Volume",
          initialValue: appState.appConfig.tts.volume,
          min: 0.1,
          max: 1.0,
          step: 0.1,
          onSelected: (double i) {
            appState.appConfig.tts.volume = i;
          },
        ),
        NumSettingChevron(
          label: "Delay Before Speaking",
          initialValue: appState.appConfig.tts.delay,
          min: 0.0,
          max: 3.0,
          step: 0.5,
          onSelected: (double i) {
            appState.appConfig.tts.delay = i;
          },
        ),
        BoolSetting(
          label: "Spell with ITU",
          initialValue: appState.appConfig.tts.spellWithItu,
          onChanged: (bool v) {
            appState.appConfig.tts.spellWithItu = v;
          },
        ),
      ],
    );
  }
}

class CWSettings extends StatelessWidget {
  const CWSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(title: Text('CW')),
        const Divider(),
        NumSettingChevron(
          label: "WPM",
          initialValue: appState.appConfig.cw.wpm,
          min: 5,
          max: 40,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.cw.wpm = i;
          },
        ),
        NumSettingChevron(
          label: "EWPM",
          initialValue: appState.appConfig.cw.ewpm,
          min: 5,
          max: 40,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.cw.ewpm = i;
          },
        ),
        NumSettingChevron(
          label: "Frequency",
          initialValue: appState.appConfig.cw.frequency,
          min: 400,
          max: 1000,
          step: 50,
          onSelected: (int i) {
            appState.appConfig.cw.frequency = i;
          },
        ),
        ListSetting(
          label: "Sample Rate",
          initialValue: appState.appConfig.cw.sampleRate,
          values: const [44100, 22050, 11025],
          onSelected: (int i) {
            appState.appConfig.cw.sampleRate = i;
          },
        ),
      ],
    );
  }
}
