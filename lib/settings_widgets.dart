import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class BoolSetting extends StatelessWidget {
  const BoolSetting({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  final bool initialValue;
  final String label;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Row(
      children: [
        Text(label, textAlign: TextAlign.left),
        const Spacer(),
        Switch(
            value: initialValue,
            onChanged: (bool v) {
              onChanged(v);
            })
      ],
    ));
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

class NumSettingChevron<T extends num> extends StatelessWidget {
  const NumSettingChevron({
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
    var f = NumberFormat("######.##", "en_US");
    return ListTile(
      title: Row(children: [
        Text(label, textAlign: TextAlign.left),
        const Spacer(),
        IconButton(
            iconSize: 48,
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              var newValue = math.max(min, initialValue - step);
              onSelected(newValue);
            }),
        Text(f.format(initialValue)),
        IconButton(
            iconSize: 48,
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              var newValue = math.min(max, initialValue + step);
              onSelected(newValue);
            }),
      ]),
    );
  }
}

class NumSettingList<T extends num> extends StatelessWidget {
  const NumSettingList({
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
