import 'package:cw_trainer/audio/cw.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/main.dart';
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
    return ListView(children: [
      CourseSettings(appState: appState),
      const Divider(),
      CWSettings(appState: appState),
      const Divider(),
      TTSSettings(appState: appState),
      const Divider(),
      SharedExerciseSettings(appState: appState),
      const Divider(),
      MiscSettings(appState: appState),
      const Divider(),
      AboutSettings(appState: appState),
      const Divider(),
    ]);
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
        GroupSizeSetting(appState: appState),
        TimeBetweenGroupsSetting(appState: appState),
        AdvancedSetting(
          appState: appState,
          child: BoolSetting(
            label: "Display Text During CW",
            initialValue: appState.appConfig.sharedExercise.displayTextDuringCw,
            onChanged: (bool v) {
              appState.appConfig.sharedExercise.displayTextDuringCw = v;
            },
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
        AdvancedSetting(
          appState: appState,
          child: NumSettingChevron(
            label: "Speech Rate",
            initialValue: appState.appConfig.tts.rate,
            min: 0.1,
            max: 1.0,
            step: 0.1,
            onSelected: (double i) {
              appState.appConfig.tts.rate = i;
            },
          ),
        ),
        AdvancedSetting(
          appState: appState,
          child: NumSettingChevron(
            label: "Pitch",
            initialValue: appState.appConfig.tts.pitch,
            min: 0.1,
            max: 1.0,
            step: 0.1,
            onSelected: (double i) {
              appState.appConfig.tts.pitch = i;
            },
          ),
        ),
        AdvancedSetting(
          appState: appState,
          child: NumSettingChevron(
            label: "Volume",
            initialValue: appState.appConfig.tts.volume,
            min: 0.1,
            max: 1.0,
            step: 0.1,
            onSelected: (double i) {
              appState.appConfig.tts.volume = i;
            },
          ),
        ),
        DelayBeforeSpeakingSetting(appState: appState),
        DelayAfterSpeakingSetting(appState: appState),
        AdvancedSetting(
          appState: appState,
          child: BoolSetting(
            label: "Spell with ITU",
            initialValue: appState.appConfig.tts.spellWithItu,
            onChanged: (bool v) {
              appState.appConfig.tts.spellWithItu = v;
            },
          ),
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
        CwSpeedSettings(appState: appState),
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
        AdvancedSetting(
          appState: appState,
          child: ListSetting(
            label: "Sample Rate",
            initialValue: appState.appConfig.cw.sampleRate,
            values: const [44100, 22050, 11025],
            onSelected: (int i) {
              appState.appConfig.cw.sampleRate = i;
            },
          ),
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

class MiscSettings extends StatelessWidget {
  const MiscSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      BoolSetting(
        label: "Advanced Settings",
        initialValue: appState.appConfig.misc.advancedSettingsEnabled,
        onChanged: (bool v) {
          appState.appConfig.misc.advancedSettingsEnabled = v;
        },
      ),
      AdvancedSetting(
        appState: appState,
        child: ListSettingChevron(
          initialValue: appState.appConfig.misc.themeMode,
          label: "Theme",
          onSelected: (ThemeMode m) {
            appState.appConfig.misc.themeMode = m;
          },
          values: const [
            ThemeMode.system,
            ThemeMode.light,
            ThemeMode.dark,
          ],
          tToString: (ThemeMode m) => switch (m) {
            ThemeMode.system => "System",
            ThemeMode.light => "Light Mode",
            ThemeMode.dark => "Dark Mode",
          },
        ),
      ),
    ]);
  }
}
