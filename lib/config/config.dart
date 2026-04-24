import 'dart:math';

import 'package:cw_trainer/config/prefixed_shared_state.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CwConfig {
  final NotifyingPrefixedSharedState _prefs;

  CwConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('cw');

  int get wpm => _prefs.get('wpm') ?? 12;
  int get ewpm => _prefs.get('ewpm') ?? 12;
  int get frequency => _prefs.get('frequency') ?? 500;
  int get sampleRate => _prefs.get('sample_rate') ?? 44100;

  set wpm(int v) {
    if (v < ewpm) {
      _prefs.nonNotifying().set('ewpm', v);
    }
    _prefs.set('wpm', v);
  }

  set ewpm(int v) {
    if (wpm < v) {
      _prefs.nonNotifying().set('wpm', v);
    }
    _prefs.set('ewpm', v);
  }

  set frequency(int frequency) {
    _prefs.set('frequency', frequency);
  }

  set sampleRate(int frequency) {
    _prefs.set('sample_rate', frequency);
  }
}

class TtsConfig {
  final NotifyingPrefixedSharedState _prefs;

  TtsConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('tts');

  bool get enable => _prefs.get('enable') ?? true;
  String get language => _prefs.get('language') ?? 'en-US';
  double get rate => _prefs.get('rate') ?? 0.7;
  double get pitch => _prefs.get('pitch') ?? 1.0;
  double get volume => _prefs.get('volume') ?? 1.0;
  double get delayBefore => _prefs.get('delay') ?? 1.0;
  double get delayAfter => _prefs.get('delay_after') ?? 1.0;
  bool get spellWithItu => _prefs.get('spell_with_itu') ?? true;

  set enable(bool enable) {
    _prefs.set('enable', enable);
  }

  set language(String language) {
    _prefs.set('language', language);
  }

  set rate(double rate) {
    _prefs.set('rate', rate);
  }

  set pitch(double pitch) {
    _prefs.set('pitch', pitch);
  }

  set volume(double volume) {
    _prefs.set('volume', volume);
  }

  set delayBefore(double delay) {
    _prefs.set('delay', delay);
  }

  set delayAfter(double delay) {
    _prefs.set('delay_after', delay);
  }

  set spellWithItu(bool spellWithItu) {
    _prefs.set('spell_with_itu', spellWithItu);
  }
}

class SharedExerciseConfig {
  final NotifyingPrefixedSharedState _prefs;

  SharedExerciseConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('shared_exercise');

  bool get repeat => _prefs.get('repeat') ?? false;

  set repeat(bool v) {
    _prefs.set('repeat', v);
  }

  int get exerciseNum => _prefs.get('exercise_num') ?? 2;

  set exerciseNum(int n) {
    _prefs.set('exercise_num', max(n, 1));
  }

  ExerciseType get curExerciseType {
    ExerciseType e = _prefs.getEnum('cur_exercise_type', ExerciseType.values) ??
        ExerciseType.randomGroups;

    if (!currentCourse.supportedExercises.contains(e)) {
      return currentCourse.supportedExercises[0];
    }

    return e;
  }

  set curExerciseType(ExerciseType type) {
    _prefs.set('cur_exercise_type', type);
  }

  bool get displayTextDuringCw => _prefs.get('display_text_during_cw') ?? true;

  set displayTextDuringCw(bool v) {
    _prefs.set('display_text_during_cw', v);
  }

  CourseType get currentCourse =>
      _prefs.getEnum('current_course', CourseType.values) ?? CourseType.bc1;

  set currentCourse(CourseType v) {
    _prefs.set('current_course', v);
  }

  double get betweenGroups => _prefs.get('between_groups') ?? 1;

  set betweenGroups(double delay) {
    _prefs.set('between_groups', delay);
  }
}

class RandomGroupsConfig {
  final NotifyingPrefixedSharedState _prefs;

  RandomGroupsConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('random_groups');

  String get letters =>
      _prefs.get('letters') ?? 'KMURESNAPTLWI.JZ=FOY,VG5/Q92H38B?47C1D60X';

  set letters(String letters) {
    _prefs.set('letters', letters);
  }

  int get levelI => _prefs.get('level_i') ?? 1;

  set levelI(int i) {
    _prefs.set('level_i', i);
  }

  int get groupSize => _prefs.get('group_size') ?? 4;

  set groupSize(int s) {
    _prefs.set('group_size', s);
  }

  bool get forceLatest => _prefs.get('force_latest') ?? true;

  set forceLatest(bool v) {
    _prefs.set('force_latest', v);
  }
}

class WordsExerciseConfig {
  final NotifyingPrefixedSharedState _prefs;

  WordsExerciseConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('words_exercise');

  int get levelI => _prefs.get('level_i') ?? 2;

  set levelI(int i) {
    _prefs.set('level_i', i);
  }
}

class LicwConfig {
  final NotifyingPrefixedSharedState _prefs;

  LicwConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('licw');

  Set<int> get bc1GroupsSelected => _prefs.get('bc1_groups_selected') ?? {0};

  set bc1GroupsSelected(Set<int> v) {
    _prefs.set('bc1_groups_selected', v);
  }

  Set<int> get bc2GroupsSelected => _prefs.get('bc2_groups_selected') ?? {0};

  set bc2GroupsSelected(Set<int> v) {
    _prefs.set('bc2_groups_selected', v);
  }
}

class MiscConfig {
  static const int licenseVersion = 10;

  final NotifyingPrefixedSharedState _prefs;

  MiscConfig(NotifyingPrefixedSharedState Function(String) builder)
      : _prefs = builder('misc');

  bool get licenseAccepted {
    var accepted = _prefs.get('license_accepted') ?? 0;
    return licenseVersion <= accepted;
  }

  void acceptLicense() {
    _prefs.set('license_accepted', licenseVersion);
  }
}

class AppConfig extends ChangeNotifier {
  final SharedPreferences _prefs;
  final bool legacyEnabled = false;

  NotifyingPrefixedSharedState _builder(String prefix) =>
      NotifyingPrefixedSharedState(_prefs, prefix, notifyListeners);

  CwConfig get cw => CwConfig(_builder);
  TtsConfig get tts => TtsConfig(_builder);
  SharedExerciseConfig get sharedExercise => SharedExerciseConfig(_builder);
  RandomGroupsConfig get randomGroups => RandomGroupsConfig(_builder);
  WordsExerciseConfig get wordsExercise => WordsExerciseConfig(_builder);
  LicwConfig get licw => LicwConfig(_builder);
  MiscConfig get misc => MiscConfig(_builder);

  AppConfig(this._prefs);
}

Future<AppConfig> readAppConfigFromShared() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return AppConfig(prefs);
}
