import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';

abstract class ExerciseBase {
  final AppConfig _appConfig;

  ExerciseBase(this._appConfig);

  get appConfig => _appConfig;

  List<AudioItem>? replenishQueue();

  AudioItem silenceBeforeTts(String caption) {
    int delayMs = (_appConfig.tts.delay * 1000).round();
    if (_appConfig.sharedExercise.displayTextDuringCw) {
      return AudioItem.silence(delayMs, caption.toUpperCase());
    }
    return AudioItem.silence(delayMs, "");
  }

  AudioItem morseAudioItem(String value) {
    if (_appConfig.sharedExercise.displayTextDuringCw) {
      return AudioItem.morse(value, value.toUpperCase());
    }
    return AudioItem.morse(value, "");
  }
}