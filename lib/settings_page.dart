import 'package:cw_trainer/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        const ListTile(title: Text('CW')),
        const Divider(),
        NumSetting(
          label: "WPM",
          initialValue: appState.appConfig.cw.wpm,
          min: 5,
          max: 40,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.cw.wpm = i;
          },
        ),
        NumSetting(
          label: "EWPM",
          initialValue: appState.appConfig.cw.ewpm,
          min: 5,
          max: 40,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.cw.ewpm = i;
          },
        ),
        NumSetting(
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
        const Divider(),
        const ListTile(title: Text('Text-to-Speech')),
        const Divider(),
        NumSetting(
          label: "Speech Rate",
          initialValue: appState.appConfig.tts.rate,
          min: 0.1,
          max: 1.0,
          step: 0.1,
          onSelected: (double i) {
            appState.appConfig.tts.rate = i;
          },
        ),
        NumSetting(
          label: "Pitch",
          initialValue: appState.appConfig.tts.pitch,
          min: 0.1,
          max: 1.0,
          step: 0.1,
          onSelected: (double i) {
            appState.appConfig.tts.pitch = i;
          },
        ),
        NumSetting(
          label: "Volume",
          initialValue: appState.appConfig.tts.volume,
          min: 0.1,
          max: 1.0,
          step: 0.1,
          onSelected: (double i) {
            appState.appConfig.tts.volume = i;
          },
        ),
        const Divider(),
        const ListTile(title: Text('Farnsworth')),
        const Divider(),
        ListSetting(
          label: "Level",
          initialValue: appState.appConfig.farnsworth.level,
          values: appState.appConfig.farnsworth.letters.split(''),
          onSelected: (String i) {
            appState.appConfig.farnsworth.level = i;
          },
        ),
        NumSetting(
          label: "Letters Per Group",
          initialValue: appState.appConfig.farnsworth.groupSize,
          min: 1,
          max: 10,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.farnsworth.groupSize = i;
          },
        ),
        NumSetting(
          label: "Number of Groups",
          initialValue: appState.appConfig.farnsworth.groupNum,
          min: 1,
          max: 15,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.farnsworth.groupNum = i;
          },
        ),
      ],
    );
  }
}

class ListSetting<T extends dynamic> extends StatelessWidget {
  const ListSetting({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onSelected,
    required this.values,
  });

  final T initialValue;
  final String label;
  final List<T> values;
  final Function onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(children: [
        Text(label, textAlign: TextAlign.left),
        const Spacer(),
        DropdownMenu(
          onSelected: (T? i) {
            if (i != null) {
              onSelected(i);
            }
          },
          initialSelection: initialValue,
          dropdownMenuEntries: values.map(
            (T v) {
              return DropdownMenuEntry(
                label: v.toString(),
                value: v,
              );
            },
          ).toList(),
        ),
      ]),
    );
  }
}

class NumSetting<T extends num> extends StatelessWidget {
  const NumSetting({
    super.key,
    required this.initialValue,
    required this.label,
    required this.min,
    required this.max,
    required this.step,
    required this.onSelected,
  });

  final T initialValue;
  final T min;
  final T max;
  final T step;
  final String label;
  final Function onSelected;

  @override
  Widget build(BuildContext context) {
    int numEntries = 1 + (max - min) ~/ step;
    return ListTile(
      title: Row(children: [
        Text(label, textAlign: TextAlign.left),
        const Spacer(),
        DropdownMenu(
          onSelected: (T? i) {
            if (i != null) {
              onSelected(i);
            }
          },
          initialSelection: initialValue,
          dropdownMenuEntries: List.generate(
            numEntries,
            (int i) {
              T value = (i * step + min) as T;
              var f = NumberFormat("######.##", "en_US");
              return DropdownMenuEntry(
                label: f.format(value),
                value: value,
              );
            },
          ).toList(),
        ),
      ]),
    );
  }
}
