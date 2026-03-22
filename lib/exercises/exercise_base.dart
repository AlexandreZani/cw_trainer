import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';

abstract class ExerciseBase {
  final AppConfig _appConfig;

  ExerciseBase(this._appConfig);

  get appConfig => _appConfig;

  List<AudioItem>? replenishQueue();

  AudioItem silenceBeforeTts(String caption, {bool forceCaption = false}) {
    int delayMs = (_appConfig.tts.delayBefore * 1000).round();
    if (_appConfig.sharedExercise.displayTextDuringCw || forceCaption) {
      return AudioItem.silence(delayMs, caption: caption.toUpperCase());
    }
    return AudioItem.silence(delayMs);
  }

  AudioItem silenceAfterTts(String caption, {bool forceCaption = false}) {
    int delayMs = (_appConfig.tts.delayAfter * 1000).round();
    if (_appConfig.sharedExercise.displayTextDuringCw || forceCaption) {
      return AudioItem.silence(delayMs, caption: caption.toUpperCase());
    }
    return AudioItem.silence(delayMs);
  }

  AudioItem morseAudioItem(String value, {bool forceCaption = false}) {
    if (_appConfig.sharedExercise.displayTextDuringCw || forceCaption) {
      return AudioItem.morse(value, caption: value.toUpperCase());
    }
    return AudioItem.morse(value);
  }
}
