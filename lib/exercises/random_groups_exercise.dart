import 'dart:math';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:logging/logging.dart';

abstract class RepeatedExerciseBase extends ExerciseBase {
  final log = Logger('RepeatedExerciseBase');
  final SharedExerciseConfig _sharedExerciseConfig;
  int _remainingExercises;

  RepeatedExerciseBase(super._appConfig)
      : _sharedExerciseConfig = _appConfig.sharedExercise,
        _remainingExercises = _appConfig.sharedExercise.exerciseNum;

  List<AudioItem> nextExerciseChunk();

  @override
  List<AudioItem>? replenishQueue() {
    log.finest('_replenishQueue $_remainingExercises');
    if (!_sharedExerciseConfig.repeat) {
      if (_remainingExercises <= 0) {
        return null;
      }
      _remainingExercises -= 1;
    }

    return nextExerciseChunk();
  }
}

abstract class RandomGroupsExerciseBase extends RepeatedExerciseBase {
  final Random _random = Random();
  final RandomGroupsConfig _config;

  RandomGroupsExerciseBase(super._appConfig)
      : _config = _appConfig.randomGroups;

  String charPool();

  String _randomGroup() {
    String letters = charPool();
    //print(letters);
    String group = '';
    while (group.length < _config.groupSize) {
      int i = _random.nextInt(letters.length);
      group += letters[i];
    }

    String latest = letters[letters.length - 1];
    if (_config.forceLatest && !group.contains(latest)) {
      int i = _random.nextInt(group.length);
      group = group.replaceRange(i, i + 1, latest);
    }

    return group;
  }

  @override
  List<AudioItem> nextExerciseChunk() {
    String group = _randomGroup();

    return [
      morseAudioItem(group),
      silenceBeforeTts(group),
      AudioItem.spell(group),
      silenceAfterTts(group),
    ];
  }
}

class RandomGroupsExercise extends RandomGroupsExerciseBase {
  RandomGroupsExercise(super._appConfig);

  @override
  String charPool() {
    return _config.letters;
  }
}
