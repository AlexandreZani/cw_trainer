import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/main.dart';
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

  void onSelectedInner(num v) {
    var value = math.max(min, math.min(v, max));
    onSelected(value);
  }

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
              onSelectedInner(initialValue - step);
            }),
        TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NumDialog(
                      label: label,
                      f: f,
                      initialValue: initialValue,
                      onSelected: onSelectedInner,
                    );
                  });
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(f.format(initialValue))),
        IconButton(
            iconSize: 48,
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              onSelectedInner(initialValue + step);
            }),
      ]),
    );
  }
}

class NumDialog<T extends num> extends StatefulWidget {
  const NumDialog({
    super.key,
    required this.label,
    required this.f,
    required this.initialValue,
    required this.onSelected,
  });

  final String label;
  final NumberFormat f;
  final T initialValue;
  final Function onSelected;

  @override
  State<NumDialog<T>> createState() => _NumDialogState<T>();
}

class _NumDialogState<T extends num> extends State<NumDialog<T>> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  num? tryParse(v) {
    if (T == int) {
      return int.tryParse(v);
    }
    if (T == double) {
      return double.tryParse(v);
    }

    return null;
  }

  void onSubmitted() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(widget.label)),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: widget.f.format(widget.initialValue)),
                onSaved: (value) {
                  widget.onSelected(tryParse(value!));
                },
                onFieldSubmitted: (value) {
                  onSubmitted();
                },
                validator: (String? value) {
                  if (value == null) {
                    return "No value was entered.";
                  }
                  if (tryParse(value) == null) {
                    return "Not a valid number!";
                  }

                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: onSubmitted, child: const Text("Accept")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                ],
              )
            ],
          ),
        ),
      ),
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

class LevelSelector extends StatelessWidget {
  const LevelSelector(
      {super.key,
      required this.letters,
      required this.levelI,
      required this.onChanged});

  final String letters;
  final int levelI;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    var curChar = letters[levelI];
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(
          iconSize: 48,
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            if (levelI <= 0) {
              return;
            }

            onChanged(levelI - 1);
          }),
      Text(curChar),
      IconButton(
          iconSize: 48,
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            if (levelI >= letters.length - 1) {
              return;
            }

            onChanged(levelI + 1);
          })
    ]);
  }
}

class MultiSelector extends StatelessWidget {
  const MultiSelector(
      {super.key,
      required this.label,
      required this.labels,
      required this.getSelected,
      required this.setSelected});

  final String label;
  final List<String> labels;
  final Set<int> Function() getSelected;
  final Function(Set<int>) setSelected;

  @override
  Widget build(BuildContext context) {
    Set<int> selected = getSelected();
    return ListTile(
        title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            TextButton(
              onPressed: () => setSelected(
                  selected.length == labels.length
                      ? {}
                      : Set.from(Iterable.generate(labels.length))),
              child: Text(
                  selected.length == labels.length ? 'Select none' : 'Select all'),
            ),
          ],
        ),
        Wrap(
            spacing: 4,
            children: labels
                .asMap()
                .entries
                .map((e) => FilterChip(
                      label: Text(e.value),
                      selected: selected.contains(e.key),
                      showCheckmark: false,
                      onSelected: (bool select) {
                        Set<int> selected = getSelected();
                        if (select) {
                          selected.add(e.key);
                        } else {
                          selected.remove(e.key);
                        }
                        setSelected(selected);
                      },
                    ))
                .toList()),
      ],
    ));
  }
}

class ConfigEnumPicker<T extends ConfigEnum> extends StatelessWidget {
  const ConfigEnumPicker({
    super.key,
    required this.initialValue,
    required this.onSelected,
    required this.values,
  });

  final T initialValue;
  final List<T> values;
  final Function onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      onSelected: (T? v) {
        if (v != null) {
          onSelected(v);
        }
      },
      initialSelection: initialValue,
      dropdownMenuEntries: values.map(
        (T v) {
          return DropdownMenuEntry(
            label: v.displayName,
            value: v,
          );
        },
      ).toList(),
    );
  }
}

class AdvancedSetting extends StatelessWidget {
  final MyAppState appState;
  final StatelessWidget child;

  const AdvancedSetting(
      {super.key, required this.appState, required this.child});

  @override
  Widget build(BuildContext context) {
    if (appState.appConfig.misc.advancedSettingsEnabled) {
      return child;
    }

    return const Column();
  }
}

class ExerciseNumber extends StatelessWidget {
  const ExerciseNumber({
    super.key,
    required this.appState,
    required this.allowContinuous,
  });

  final MyAppState appState;
  final bool allowContinuous;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (!allowContinuous || !appState.appConfig.sharedExercise.repeat) {
      children.add(NumSettingChevron(
        label: "Exercise Number",
        initialValue: appState.appConfig.sharedExercise.exerciseNum,
        min: 1,
        max: 15,
        step: 1,
        onSelected: (int i) {
          appState.appConfig.sharedExercise.exerciseNum = i;
        },
      ));
    }

    if (allowContinuous) {
      children.add(BoolSetting(
        label: "Continuous Exercise",
        initialValue: appState.appConfig.sharedExercise.repeat,
        onChanged: (bool v) {
          appState.appConfig.sharedExercise.repeat = v;
        },
      ));
    }
    return Column(
      children: children,
    );
  }
}

class GroupSizeSetting extends StatelessWidget {
  const GroupSizeSetting({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumSettingChevron(
          label: "Min Letters Per Group",
          initialValue: appState.appConfig.randomGroups.minGroupSize,
          min: 1,
          max: 10,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.randomGroups.minGroupSize = i;
          },
        ),
        NumSettingChevron(
          label: "Max Letters Per Group",
          initialValue: appState.appConfig.randomGroups.maxGroupSize,
          min: 1,
          max: 10,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.randomGroups.maxGroupSize = i;
          },
        ),
      ],
    );
  }
}

class DelayBeforeSpeakingSetting extends StatelessWidget {
  const DelayBeforeSpeakingSetting({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return NumSettingChevron(
      label: "Delay Before Speaking",
      initialValue: appState.appConfig.tts.delayBefore,
      min: 0.0,
      max: 3.0,
      step: 0.25,
      onSelected: (double i) {
        appState.appConfig.tts.delayBefore = i;
      },
    );
  }
}

class DelayAfterSpeakingSetting extends StatelessWidget {
  const DelayAfterSpeakingSetting({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return NumSettingChevron(
      label: "Delay After Speaking",
      initialValue: appState.appConfig.tts.delayAfter,
      min: 0.0,
      max: 3.0,
      step: 0.25,
      onSelected: (double i) {
        appState.appConfig.tts.delayAfter = i;
      },
    );
  }
}

class TimeBetweenGroupsSetting extends StatelessWidget {
  const TimeBetweenGroupsSetting({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return NumSettingChevron(
      label: "Time Between Groups",
      initialValue: appState.appConfig.sharedExercise.betweenGroups,
      min: 0.0,
      max: 3.0,
      step: 0.25,
      onSelected: (double i) {
        appState.appConfig.sharedExercise.betweenGroups = i;
      },
    );
  }
}

class CwSpeedSettings extends StatelessWidget {
  const CwSpeedSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}
