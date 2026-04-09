import 'dart:math';

import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/config/shared_state_base.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedState extends SharedStateBase {
  SharedState(super.prefs, super.prefix);

  Set<E>? getSet<E>(String k, E? Function(String) parse) {
    List<String>? strings = getStringList(k);
    if (strings == null) {
      return null;
    }

    Set<E> es = {};
    for (final s in strings) {
      final e = parse(s);
      if (e == null) {
        return null;
      }

      es.add(e);
    }

    return es;
  }

  Set<int>? getIntSet(String k) {
    return getSet(k, int.tryParse);
  }

  void setSet<E>(String k, Set<E> es, String Function(E) toString) {
    setStringList(k, es.map(toString).toList());
  }

  void setIntSet(String k, Set<int> v) {
    setStringList(k, v.map((i) => i.toString()).toList());
  }

  void setEnum(String k, ConfigEnum v) {
    setInt(k, v.i);
  }

  T? getEnum<T>(String k, List<T> values) {
    int? i = getInt(k);
    if (i == null) {
      return null;
    }

    for (T e in values) {
      var ce = e as ConfigEnum;
      if (ce.i == i && !ce.deprecated) {
        return e;
      }
    }
    return null;
  }
}

class CwConfig extends SharedState {
  CwConfig(SharedPreferences prefs) : super(prefs, 'cw');

  int get wpm => getInt('wpm') ?? 12;
  int get ewpm => getInt('ewpm') ?? 12;
  int get frequency => getInt('frequency') ?? 500;
  int get sampleRate => getInt('sample_rate') ?? 44100;

  set wpm(int wpm) {
    setInt('wpm', wpm);
  }

  set ewpm(int ewpm) {
    setInt('ewpm', ewpm);
  }

  set frequency(int frequency) {
    setInt('frequency', frequency);
  }

  set sampleRate(int frequency) {
    setInt('sample_rate', frequency);
  }
}

class TtsConfig extends SharedState {
  TtsConfig(SharedPreferences prefs) : super(prefs, 'tts');

  bool get enable => getBool('enable') ?? true;
  String get language => getString('language') ?? 'en-US';
  double get rate => getDouble('rate') ?? 0.7;
  double get pitch => getDouble('pitch') ?? 1.0;
  double get volume => getDouble('volume') ?? 1.0;
  double get delayBefore => getDouble('delay') ?? 1.0;
  double get delayAfter => getDouble('delay_after') ?? 1.0;
  bool get spellWithItu => getBool('spell_with_itu') ?? true;

  set enable(bool enable) {
    setBool('enable', enable);
  }

  set language(String language) {
    setString('language', language);
  }

  set rate(double rate) {
    setDouble('rate', rate);
  }

  set pitch(double pitch) {
    setDouble('pitch', pitch);
  }

  set volume(double volume) {
    setDouble('volume', volume);
  }

  set delayBefore(double delay) {
    setDouble('delay', delay);
  }

  set delayAfter(double delay) {
    setDouble('delay_after', delay);
  }

  set spellWithItu(bool spellWithItu) {
    setBool('spell_with_itu', spellWithItu);
  }
}

class SharedExerciseConfig extends SharedState {
  SharedExerciseConfig(SharedPreferences prefs)
      : super(prefs, 'shared_exercise');

  bool get repeat => getBool('repeat') ?? false;

  set repeat(bool v) {
    setBool('repeat', v);
  }

  int get exerciseNum => getInt('exercise_num') ?? 2;

  set exerciseNum(int n) {
    setInt('exercise_num', max(n, 1));
  }

  ExerciseType get curExerciseType {
    ExerciseType e = getEnum('cur_exercise_type', ExerciseType.values) ??
        ExerciseType.randomGroups;

    if (!currentCourse.supportedExercises.contains(e)) {
      return currentCourse.supportedExercises[0];
    }

    return e;
  }

  set curExerciseType(ExerciseType type) {
    setEnum('cur_exercise_type', type);
  }

  bool get displayTextDuringCw => getBool('display_text_during_cw') ?? true;

  set displayTextDuringCw(bool v) {
    setBool('display_text_during_cw', v);
  }

  CourseType get currentCourse =>
      getEnum('current_course', CourseType.values) ?? CourseType.bc1;

  set currentCourse(CourseType v) {
    setEnum('current_course', v);
  }

  double get betweenGroups => getDouble('between_groups') ?? 1;

  set betweenGroups(double delay) {
    setDouble('between_groups', delay);
  }
}

class RandomGroupsConfig extends SharedState {
  RandomGroupsConfig(SharedPreferences prefs) : super(prefs, 'random_groups');

  String get letters =>
      getString('letters') ?? 'KMURESNAPTLWI.JZ=FOY,VG5/Q92H38B?47C1D60X';

  set letters(String letters) {
    setString('letters', letters);
  }

  int get levelI => getInt('level_i') ?? 1;

  set levelI(int i) {
    setInt('level_i', i);
  }

  int get groupSize => getInt('group_size') ?? 4;

  set groupSize(int s) {
    setInt('group_size', s);
  }

  bool get forceLatest => getBool('force_latest') ?? true;

  set forceLatest(bool v) {
    setBool('force_latest', v);
  }
}

class WordsExerciseConfig extends SharedState {
  WordsExerciseConfig(SharedPreferences prefs) : super(prefs, 'words_exercise');

  int get levelI => getInt('level_i') ?? 2;

  set levelI(int i) {
    setInt('level_i', i);
  }
}

class LicwConfig extends SharedState {
  LicwConfig(SharedPreferences prefs) : super(prefs, 'licw');

  Set<int> get bc1GroupsSelected => getIntSet('bc1_groups_selected') ?? {0};

  set bc1GroupsSelected(Set<int> v) {
    setIntSet('bc1_groups_selected', v);
  }

  Set<int> get bc2GroupsSelected => getIntSet('bc2_groups_selected') ?? {0};

  set bc2GroupsSelected(Set<int> v) {
    setIntSet('bc2_groups_selected', v);
  }
}

class MiscConfig extends SharedState {
  static const int licenseVersion = 10;

  MiscConfig(SharedPreferences prefs) : super(prefs, 'misc');

  bool get licenseAccepted {
    var accepted = getInt('license_accepted') ?? 0;
    return licenseVersion <= accepted;
  }

  void acceptLicense() {
    setInt('license_accepted', licenseVersion);
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
