import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:logging/logging.dart';

abstract class RepeatedExerciseBase extends ExerciseBase {
  final log = Logger('RepeatedExerciseBase');
  final bool voiceBefore;
  final bool voiceAfter;
  final int repeatNum;
  final bool recapAtEnd;
  final bool spellText;
  final SharedExerciseConfig _sharedExerciseConfig;
  int _remainingExercises;
  List<AudioItem> _recap;

  RepeatedExerciseBase(super.appConfig,
      {required this.voiceBefore,
      required this.voiceAfter,
      required this.repeatNum,
      required this.recapAtEnd,
      required this.spellText})
      : _sharedExerciseConfig = appConfig.sharedExercise,
        _remainingExercises = appConfig.sharedExercise.exerciseNum,
        _recap = [];

  String nextExerciseChunk();

  AudioItem ttsText(String text) {
    if (spellText) {
      return AudioItem.spell(text);
    } else {
      return AudioItem.text(text);
    }
  }

  @override
  List<AudioItem>? replenishQueue() {
    log.finest('_replenishQueue $_remainingExercises');
    if (!_sharedExerciseConfig.repeat || recapAtEnd) {
      if (_remainingExercises <= 0) {
        if (_recap.isEmpty) {
          return null;
        }

        List<AudioItem> chunk = _recap;
        _recap = [];
        return chunk;
      }
      _remainingExercises -= 1;
    }

    String text = nextExerciseChunk();
    if (recapAtEnd) {
      if (_recap.isEmpty) {
        _recap.add(
            AudioItem.silenceFromDouble(_sharedExerciseConfig.betweenGroups));
      }

      _recap.addAll([
        ttsText(text),
        AudioItem.silenceFromDouble(_sharedExerciseConfig.betweenGroups)
      ]);
    }

    List<AudioItem> chunk = [];
    if (voiceBefore) {
      chunk.addAll([
        ttsText(text),
        silenceAfterTts(text),
      ]);
    }

    for (int i = 0; i < repeatNum; i++) {
      chunk.add(AudioItem.morse(text));
      if (i < repeatNum - 1) {
        chunk.add(
            AudioItem.silenceFromDouble(_sharedExerciseConfig.betweenGroups));
      }
    }

    if (voiceAfter) {
      chunk.add(silenceBeforeTts(''));
      chunk.add(ttsText(text));
    }

    chunk.add(AudioItem.silenceFromDouble(_sharedExerciseConfig.betweenGroups));

    return chunk;
  }
}
