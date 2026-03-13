import 'dart:math';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:cw_trainer/exercises/words.dart';
import 'package:logging/logging.dart';

class WordsExercise extends ExerciseBase {
  final log = Logger('WordsExercise');
  final Random _random = Random();
  final WordsExerciseConfig _config;
  final SharedExerciseConfig _sharedExercise;
  int _remainingWords;

  WordsExercise(super._appConfig)
      : _config = _appConfig.wordsExercise,
        _remainingWords = _appConfig.sharedExercise.exerciseNum,
        _sharedExercise = _appConfig.sharedExercise;

  String _pickLetter() {
    int levelI = _config.levelI;
    if (levelI == 1 || _random.nextDouble() > 0.5) {
      return order[levelI];
    }

    int i = _random.nextInt(levelI);
    return order[i];
  }

  @override
  List<AudioItem>? replenishQueue() {
    log.finest('_replenishQueue $_remainingWords');
    if (!_sharedExercise.repeat) {
      if (_remainingWords <= 0) {
        return null;
      }
      _remainingWords -= 1;
    }

    var c = _pickLetter();
    var words = wordsForExercise[c]!;

    int i = _random.nextInt(words.length);
    String word = words[i];

    return [
      morseAudioItem(word),
      silenceBeforeTts(word),
      AudioItem.text(word),
    ];
  }
}
