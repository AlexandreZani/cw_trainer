import 'package:cw_trainer/audio/cw.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/pages/exercise_settings.dart';
import 'package:cw_trainer/pages/settings_widgets.dart';
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
    List<Widget> children = [
      CourseSettings(appState: appState),
      const Divider(),
      CWSettings(appState: appState),
      const Divider(),
      TTSSettings(appState: appState),
      const Divider(),
      SharedExerciseSettings(appState: appState),
      const Divider(),
    ];

    if (appState.appConfig.legacyEnabled) {
      children.addAll([
        RandomGroupsSettings(appState: appState),
        const Divider(),
        WordsExerciseSettings(appState: appState),
        const Divider(),
      ]);
    }

    children.addAll([
      AboutSettings(appState: appState),
      const Divider(),
    ]);

    return ListView(children: children);
  }
}

class AboutSettings extends StatelessWidget {
  const AboutSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: const Text('About'),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MyHomePage(currentPage: Pages.about)));
        },
      ),
    ]);
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
        TimeBetweenGroupsSetting(appState: appState),
        BoolSetting(
          label: "Display Text During CW",
          initialValue: appState.appConfig.sharedExercise.displayTextDuringCw,
          onChanged: (bool v) {
            appState.appConfig.sharedExercise.displayTextDuringCw = v;
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
        ListTile(
          title: Row(
            children: [
              const Text("Level", textAlign: TextAlign.left),
              const Spacer(),
              RandomGroupLevelSelector(appState: appState),
            ],
          ),
        ),
        GroupSize(appState: appState),
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

class WordsExerciseSettings extends StatelessWidget {
  const WordsExerciseSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(title: Text('Words Exercise')),
        const Divider(),
        ListTile(
          title: Row(
            children: [
              const Text("Level", textAlign: TextAlign.left),
              const Spacer(),
              WordsLevelSelector(appState: appState),
            ],
          ),
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
        DelayBeforeSpeakingSetting(appState: appState),
        DelayAfterSpeakingSetting(appState: appState),
        NumSettingChevron(
          label: "Delay After Speaking",
          initialValue: appState.appConfig.tts.delayAfter,
          min: 0.0,
          max: 3.0,
          step: 0.25,
          onSelected: (double i) {
            appState.appConfig.tts.delayAfter = i;
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

class CourseSettings extends StatelessWidget {
  const CourseSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const ListTile(title: Text('Group Selection')),
      const Divider(),
      MultiSelector(
          label: "BC1 Groups",
          labels: bc1Groups.map(txtForDisplay).toList(),
          getSelected: () => appState.appConfig.licw.bc1GroupsSelected,
          setSelected: (selected) {
            appState.appConfig.licw.bc1GroupsSelected = selected;
          }),
      MultiSelector(
          label: "BC2 Groups",
          labels: bc2Groups.map(txtForDisplay).toList(),
          getSelected: () => appState.appConfig.licw.bc2GroupsSelected,
          setSelected: (selected) {
            appState.appConfig.licw.bc2GroupsSelected = selected;
          }),
    ]);
  }
}
