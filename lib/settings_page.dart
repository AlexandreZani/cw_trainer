import 'package:cw_trainer/main.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    print('building settings page');
    return ListView(
      children: [
        const ListTile(title: Text('CW Settings')),
        const Divider(),
        ListTile(
          title: IntSetting(
            label: "WPM",
            initialValue: appState.appConfig.cwConfig.wpm,
            min: 5,
            max: 40,
            step: 1,
            onSelected: (int i) {
              appState.appConfig.cwConfig.wpm = i;
            },
          ),
        ),
        IntSetting(
          label: "EWPM",
          initialValue: appState.appConfig.cwConfig.ewpm,
          min: 5,
          max: 40,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.cwConfig.ewpm = i;
          },
        ),
        IntSetting(
          label: "Frequency",
          initialValue: appState.appConfig.cwConfig.frequency,
          min: 400,
          max: 1000,
          step: 50,
          onSelected: (int i) {
            appState.appConfig.cwConfig.frequency = i;
          },
        )
      ],
    );
  }
}

class IntSetting extends StatelessWidget {
  const IntSetting({
    super.key,
    required this.initialValue,
    required this.label,
    required this.min,
    required this.max,
    required this.step,
    required this.onSelected,
  });

  final int initialValue;
  final int min;
  final int max;
  final int step;
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
          onSelected: (int? i) {
            if (i != null) {
              onSelected(i);
            }
          },
          initialSelection: initialValue,
          dropdownMenuEntries: List.generate(
            numEntries,
            (int i) {
              int value = i * step + min;
              return DropdownMenuEntry(
                label: (value).toString(),
                value: value,
              );
            },
          ).toList(),
        ),
      ]),
    );
  }
}
