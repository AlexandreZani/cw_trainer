import 'dart:math';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:logging/logging.dart';

abstract class RandomGroupsExerciseBase extends ExerciseBase {
  final log = Logger('RandomGroupsExercise');
  final Random _random = Random();
  final RandomGroupsConfig _config;
  final SharedExerciseConfig _sharedExercise;
  int _remainingGroups;

  RandomGroupsExerciseBase(super._appConfig)
      : _config = _appConfig.randomGroups,
        _remainingGroups = _appConfig.sharedExercise.exerciseNum,
        _sharedExercise = _appConfig.sharedExercise;

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
  List<AudioItem>? replenishQueue() {
    log.finest('_replenishQueue $_remainingGroups');
    if (!_sharedExercise.repeat) {
      if (_remainingGroups <= 0) {
        return null;
      }
      _remainingGroups -= 1;
    }

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
