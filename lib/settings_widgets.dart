import 'package:cw_trainer/exercises.dart';
import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/words.dart';
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

class PracticeSettings extends StatelessWidget {
  const PracticeSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [WordsLevelSelector(appState: appState)]);
  }
}

class LevelSetting extends StatelessWidget {
  const LevelSetting({
    super.key,
    required this.appState,
    required this.exerciseType,
  });
  final MyAppState appState;
  final ExerciseType exerciseType;

  @override
  Widget build(BuildContext context) {
    var selector = switch (exerciseType) {
      ExerciseType.words => WordsLevelSelector(appState: appState),
      ExerciseType.randomGroups => RandomGroupLevelSelector(appState: appState),
    };
    return ListTile(
      title: Row(children: [
        const Text("Level", textAlign: TextAlign.left),
        const Spacer(),
        selector,
      ]),
    );
  }
}

class LevelSelectorForExercise extends StatelessWidget {
  const LevelSelectorForExercise({
    super.key,
    required this.appState,
    required this.exerciseType,
  });

  final MyAppState appState;
  final ExerciseType exerciseType;

  @override
  Widget build(BuildContext context) {
    switch (exerciseType) {
      case ExerciseType.randomGroups:
        return RandomGroupLevelSelector(appState: appState);
      case ExerciseType.words:
        throw UnimplementedError();
    }
  }
}

class RandomGroupLevelSelector extends StatelessWidget {
  const RandomGroupLevelSelector({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return LevelSelector(
      letters: appState.appConfig.randomGroups.letters,
      levelI: appState.appConfig.randomGroups.levelI,
      onChanged: (int i) {
        appState.appConfig.randomGroups.levelI = i;
      },
    );
  }
}

class WordsLevelSelector extends StatelessWidget {
  const WordsLevelSelector({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return LevelSelector(
      letters: order,
      levelI: appState.appConfig.wordsExercise.levelI,
      onChanged: (int i) {
        appState.appConfig.wordsExercise.levelI = i;
      },
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
