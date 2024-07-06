import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedState extends ChangeNotifier {
  final SharedPreferences _prefs;
  SharedState(this._prefs) : super();

  int? getInt(String k) {
    return _prefs.getInt(k);
  }

  double? getDouble(String k) {
    return _prefs.getDouble(k);
  }

  String? getString(String k) {
    return _prefs.getString(k);
  }

  void setInt(String k, int v) {
    _prefs.setInt(k, v);
    notifyListeners();
  }

  void setDouble(String k, double v) {
    _prefs.setDouble(k, v);
    notifyListeners();
  }

  void setString(String k, String v) {
    _prefs.setString(k, v);
    notifyListeners();
  }
}

class CwConfig extends SharedState {
  CwConfig(super._prefs);

  int get wpm => getInt('cw_wpm') ?? 20;
  int get ewpm => getInt('cw_ewpm') ?? 12;
  int get frequency => getInt('cw_frequency') ?? 500;

  set wpm(int wpm) {
    setInt('cw_wpm', wpm);
  }

  set ewpm(int ewpm) {
    setInt('cw_ewpm', ewpm);
  }

  set frequency(int frequency) {
    setInt('cw_frequency', frequency);
  }
}

class TtsConfig extends SharedState {
  TtsConfig(super._prefs);

  String get language => getString('tts_language') ?? 'en-US';
  double get rate => getDouble('tts_rate') ?? 1.0;
  double get pitch => getDouble('tts_pitch') ?? 1.0;
  double get volume => getDouble('tts_volume') ?? 1.0;

  set language(String language) {
    _prefs.setString('tts_language', language);
  }

  set rate(double rate) {
    setDouble('tts_rate', rate);
  }

  set pitch(double pitch) {
    setDouble('tts_pitch', pitch);
  }

  set volume(double volume) {
    setDouble('tts_volume', volume);
  }
}

class AppConfig extends ChangeNotifier {
  CwConfig cwConfig;
  TtsConfig ttsConfig;

  AppConfig(this.cwConfig, this.ttsConfig) {
    cwConfig.addListener(notifyListeners);
    ttsConfig.addListener(notifyListeners);
  }

  static AppConfig buildFromShared(SharedPreferences prefs) {
    return AppConfig(CwConfig(prefs), TtsConfig(prefs));
  }
}

Future<AppConfig> readAppConfigFromShared() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return AppConfig.buildFromShared(prefs);
}
