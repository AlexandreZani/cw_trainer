import 'dart:math';

import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/config/prefixed_shared_preferences.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedState extends ChangeNotifier {
  final PrefixedSharedPreferences _prefs;

  SharedState(this._prefs) : super();

  void _setInt(String k, int v) {
    _prefs.setInt(k, v);
    notifyListeners();
  }

  void _setDouble(String k, double v) {
    _prefs.setDouble(k, v);
    notifyListeners();
  }

  void _setString(String k, String v) {
    _prefs.setString(k, v);
    notifyListeners();
  }

  void _setBool(String k, bool v) {
    _prefs.setBool(k, v);
    notifyListeners();
  }

  void _setIntSet(String k, Set<int> v) {
    _prefs.setIntSet(k, v);
    notifyListeners();
  }

  void _setEnum(String k, ConfigEnum v) {
    _prefs.setEnum(k, v);
    notifyListeners();
  }
}

class CwConfig extends SharedState {
  CwConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'cw'));

  int get wpm => _prefs.getInt('wpm') ?? 12;
  int get ewpm => _prefs.getInt('ewpm') ?? 12;
  int get frequency => _prefs.getInt('frequency') ?? 500;
  int get sampleRate => _prefs.getInt('sample_rate') ?? 44100;

  set wpm(int v) {
    if (v < ewpm) {
      _prefs.setInt('ewpm', v);
    }
    _setInt('wpm', v);
  }

  set ewpm(int v) {
    if (wpm < v) {
      _prefs.setInt('wpm', v);
    }
    _setInt('ewpm', v);
  }

  set frequency(int frequency) {
    _setInt('frequency', frequency);
  }

  set sampleRate(int frequency) {
    _setInt('sample_rate', frequency);
  }
}

class TtsConfig extends SharedState {
  TtsConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'tts'));

  bool get enable => _prefs.getBool('enable') ?? true;
  String get language => _prefs.getString('language') ?? 'en-US';
  double get rate => _prefs.getDouble('rate') ?? 0.7;
  double get pitch => _prefs.getDouble('pitch') ?? 1.0;
  double get volume => _prefs.getDouble('volume') ?? 1.0;
  double get delayBefore => _prefs.getDouble('delay') ?? 1.0;
  double get delayAfter => _prefs.getDouble('delay_after') ?? 1.0;
  bool get spellWithItu => _prefs.getBool('spell_with_itu') ?? true;

  set enable(bool enable) {
    _setBool('enable', enable);
  }

  set language(String language) {
    _setString('language', language);
  }

  set rate(double rate) {
    _setDouble('rate', rate);
  }

  set pitch(double pitch) {
    _setDouble('pitch', pitch);
  }

  set volume(double volume) {
    _setDouble('volume', volume);
  }

  set delayBefore(double delay) {
    _setDouble('delay', delay);
  }

  set delayAfter(double delay) {
    _setDouble('delay_after', delay);
  }

  set spellWithItu(bool spellWithItu) {
    _setBool('spell_with_itu', spellWithItu);
  }
}

class SharedExerciseConfig extends SharedState {
  SharedExerciseConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'shared_exercise'));

  bool get repeat => _prefs.getBool('repeat') ?? false;

  set repeat(bool v) {
    _setBool('repeat', v);
  }

  int get exerciseNum => _prefs.getInt('exercise_num') ?? 2;

  set exerciseNum(int n) {
    _setInt('exercise_num', max(n, 1));
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
    _setEnum('cur_exercise_type', type);
  }

  bool get displayTextDuringCw =>
      _prefs.getBool('display_text_during_cw') ?? true;

  set displayTextDuringCw(bool v) {
    _setBool('display_text_during_cw', v);
  }

  CourseType get currentCourse =>
      _prefs.getEnum('current_course', CourseType.values) ?? CourseType.bc1;

  set currentCourse(CourseType v) {
    _setEnum('current_course', v);
  }

  double get betweenGroups => _prefs.getDouble('between_groups') ?? 1;

  set betweenGroups(double delay) {
    _setDouble('between_groups', delay);
  }
}

class RandomGroupsConfig extends SharedState {
  RandomGroupsConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'random_groups'));

  String get letters =>
      _prefs.getString('letters') ??
      'KMURESNAPTLWI.JZ=FOY,VG5/Q92H38B?47C1D60X';

  set letters(String letters) {
    _setString('letters', letters);
  }

  int get levelI => _prefs.getInt('level_i') ?? 1;

  set levelI(int i) {
    _setInt('level_i', i);
  }

  int get groupSize => _prefs.getInt('group_size') ?? 4;

  set groupSize(int s) {
    _setInt('group_size', s);
  }

  bool get forceLatest => _prefs.getBool('force_latest') ?? true;

  set forceLatest(bool v) {
    _setBool('force_latest', v);
  }
}

class WordsExerciseConfig extends SharedState {
  WordsExerciseConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'words_exercise'));

  int get levelI => _prefs.getInt('level_i') ?? 2;

  set levelI(int i) {
    _setInt('level_i', i);
  }
}

class LicwConfig extends SharedState {
  LicwConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'licw'));

  Set<int> get bc1GroupsSelected =>
      _prefs.getIntSet('bc1_groups_selected') ?? {0};

  set bc1GroupsSelected(Set<int> v) {
    _setIntSet('bc1_groups_selected', v);
  }

  Set<int> get bc2GroupsSelected =>
      _prefs.getIntSet('bc2_groups_selected') ?? {0};

  set bc2GroupsSelected(Set<int> v) {
    _setIntSet('bc2_groups_selected', v);
  }
}

class MiscConfig extends SharedState {
  static const int licenseVersion = 10;

  MiscConfig(SharedPreferences prefs)
      : super(PrefixedSharedPreferences(prefs, 'misc'));

  bool get licenseAccepted {
    var accepted = _prefs.getInt('license_accepted') ?? 0;
    return licenseVersion <= accepted;
  }

  void acceptLicense() {
    _setInt('license_accepted', licenseVersion);
  }
}

class AppConfig extends ChangeNotifier {
  CwConfig cw;
  TtsConfig tts;
  SharedExerciseConfig sharedExercise;
  RandomGroupsConfig randomGroups;
  WordsExerciseConfig wordsExercise;
  LicwConfig licw;
  MiscConfig misc;
  final bool legacyEnabled = false;

  AppConfig(this.cw, this.tts, this.sharedExercise, this.randomGroups,
      this.wordsExercise, this.licw, this.misc) {
    cw.addListener(notifyListeners);
    tts.addListener(notifyListeners);
    randomGroups.addListener(notifyListeners);
    sharedExercise.addListener(notifyListeners);
    wordsExercise.addListener(notifyListeners);
    licw.addListener(notifyListeners);
    misc.addListener(notifyListeners);
  }

  static AppConfig buildFromShared(SharedPreferences prefs) {
    return AppConfig(
        CwConfig(prefs),
        TtsConfig(prefs),
        SharedExerciseConfig(prefs),
        RandomGroupsConfig(prefs),
        WordsExerciseConfig(prefs),
        LicwConfig(prefs),
        MiscConfig(prefs));
  }
}

Future<AppConfig> readAppConfigFromShared() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return AppConfig.buildFromShared(prefs);
}
