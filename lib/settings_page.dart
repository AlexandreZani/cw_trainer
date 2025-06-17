import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/settings_widgets.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final MyAppState appState;
  const SettingsPage({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    print('building settings page');
    return ListView(
      children: [
        CWSettings(appState: appState),
        const Divider(),
        TTSSettings(appState: appState),
        const Divider(),
        FarnsworthSettings(appState: appState),
        BoolSetting(
          label: "Force Latest Letter",
          initialValue: appState.appConfig.farnsworth.forceLatest,
          onChanged: (bool v) {
            appState.appConfig.farnsworth.forceLatest = v;
          },
        ),
      ],
    );
  }
}

class FarnsworthSettings extends StatelessWidget {
  const FarnsworthSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(title: Text('Farnsworth')),
        const Divider(),
        LevelSetting(appState: appState),
        NumSettingChevron(
          label: "Letters Per Group",
          initialValue: appState.appConfig.farnsworth.groupSize,
          min: 1,
          max: 10,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.farnsworth.groupSize = i;
          },
        ),
        NumSettingChevron(
          label: "Number of Groups",
          initialValue: appState.appConfig.farnsworth.groupNum,
          min: 1,
          max: 15,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.farnsworth.groupNum = i;
          },
        ),
        BoolSetting(
          label: "Repeat",
          initialValue: appState.appConfig.farnsworth.repeat,
          onChanged: (bool v) {
            appState.appConfig.farnsworth.repeat = v;
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
          initialValue: appState.appConfig.farnsworth.delay,
          min: 0.0,
          max: 3.0,
          step: 0.5,
          onSelected: (double i) {
            appState.appConfig.farnsworth.delay = i;
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
