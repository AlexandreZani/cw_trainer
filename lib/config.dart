import 'package:shared_preferences/shared_preferences.dart';

class CwConfig {
  int wpm;
  int ewpm;
  int frequency;

  CwConfig(this.wpm, this.ewpm, this.frequency);

  static CwConfig getDefaultConfig() {
    return CwConfig(20, 12, 500);
  }

  static CwConfig readFromShared(SharedPreferences prefs) {
    CwConfig d = CwConfig.getDefaultConfig();

    return CwConfig(
      prefs.getInt('cw_wpm') ?? d.wpm,
      prefs.getInt('cw_ewpm') ?? d.ewpm,
      prefs.getInt('cw_frequency') ?? d.frequency,
    );
  }

  Future<void> writeToShared(SharedPreferences prefs) async {
    prefs.setInt('cw_wpm', wpm);
    prefs.setInt('cw_ewpm', ewpm);
    prefs.setInt('frequency', frequency);
  }
}

class TtsConfig {
  String language;
  double rate;
  double pitch;
  double volume;

  TtsConfig(this.language, this.rate, this.pitch, this.volume);

  static TtsConfig getDefaultConfig() {
    return TtsConfig('en-US', 1.0, 1.0, 1.0);
  }

  static TtsConfig readFromShared(SharedPreferences prefs) {
    TtsConfig d = TtsConfig.getDefaultConfig();

    return TtsConfig(
      prefs.getString('tts_language') ?? d.language,
      prefs.getDouble('tts_rate') ?? d.rate,
      prefs.getDouble('tts_pitch') ?? d.pitch,
      prefs.getDouble('tts_volume') ?? d.volume,
    );
  }

  Future<void> writeToShared(SharedPreferences prefs) async {
    prefs.setString('tts_language', language);
    prefs.setDouble('tts_rate', rate);
    prefs.setDouble('tts_pitch', pitch);
    prefs.setDouble('tts_volume', volume);
  }
}

class AppConfig {
  CwConfig cwConfig;
  TtsConfig ttsConfig;

  AppConfig(this.cwConfig, this.ttsConfig);

  static AppConfig getDefaultConfig() {
    return AppConfig(CwConfig.getDefaultConfig(), TtsConfig.getDefaultConfig());
  }

  static AppConfig readFromShared(SharedPreferences prefs) {
    return AppConfig(
        CwConfig.readFromShared(prefs), TtsConfig.readFromShared(prefs));
  }

  Future<void> writeToShared(SharedPreferences prefs) async {
    cwConfig.writeToShared(prefs);
    ttsConfig.writeToShared(prefs);
  }
}

Future<AppConfig> readAppConfigFromShared() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return AppConfig.readFromShared(prefs);
}
