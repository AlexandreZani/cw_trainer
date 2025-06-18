import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedState extends ChangeNotifier {
  final SharedPreferences _prefs;
  final String _prefix;
  SharedState(this._prefs, this._prefix) : super();

  String key(String k) {
    return '${_prefix}_$k';
  }

  int? getInt(String k) {
    return _prefs.getInt(key(k));
  }

  double? getDouble(String k) {
    return _prefs.getDouble(key(k));
  }

  String? getString(String k) {
    return _prefs.getString(key(k));
  }

  bool? getBool(String k) {
    return _prefs.getBool(k);
  }

  void setInt(String k, int v) {
    _prefs.setInt(key(k), v);
    notifyListeners();
  }

  void setDouble(String k, double v) {
    _prefs.setDouble(key(k), v);
    notifyListeners();
  }

  void setString(String k, String v) {
    _prefs.setString(key(k), v);
    notifyListeners();
  }

  void setBool(String k, bool v) {
    _prefs.setBool(k, v);
    notifyListeners();
  }
}

class CwConfig extends SharedState {
  CwConfig(SharedPreferences prefs) : super(prefs, 'cw');

  int get wpm => getInt('wpm') ?? 20;
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
  double get delay => getDouble('delay') ?? 1.0;
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

  set delay(double delay) {
    setDouble('delay', delay);
  }

  set spellWithItu(bool spellWithItu) {
    setBool('spell_with_itu', spellWithItu);
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

  int get groupNum => getInt('group_num') ?? 2;

  set groupNum(int n) {
    setInt('group_num', max(n, 1));
  }

  bool get repeat => getBool('repeat') ?? false;

  set repeat(bool v) {
    setBool('repeat', v);
  }

  bool get forceLatest => getBool('force_latest') ?? true;

  set forceLatest(bool v) {
    setBool('force_latest', v);
  }
}

class AppConfig extends ChangeNotifier {
  CwConfig cw;
  TtsConfig tts;
  RandomGroupsConfig randomGroups;

  AppConfig(this.cw, this.tts, this.randomGroups) {
    cw.addListener(notifyListeners);
    tts.addListener(notifyListeners);
    randomGroups.addListener(notifyListeners);
  }

  static AppConfig buildFromShared(SharedPreferences prefs) {
    return AppConfig(
        CwConfig(prefs), TtsConfig(prefs), RandomGroupsConfig(prefs));
  }
}

Future<AppConfig> readAppConfigFromShared() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return AppConfig.buildFromShared(prefs);
}
