import 'dart:math';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:logging/logging.dart';

class RandomGroupsExercise extends ExerciseBase {
  final log = Logger('RandomGroupsExercise');
  final Random _random = Random();
  final RandomGroupsConfig _config;
  final SharedExerciseConfig _sharedExercise;
  int _remainingGroups;

  RandomGroupsExercise(super._appConfig)
      : _config = _appConfig.randomGroups,
        _remainingGroups = _appConfig.sharedExercise.exerciseNum,
        _sharedExercise = _appConfig.sharedExercise;

  String _randomGroup() {
    String group = '';
    int maxIndex = _config.levelI;
    while (group.length < _config.groupSize) {
      int i = _random.nextInt(maxIndex + 1);
      group += _config.letters[i];
    }

    String latest = _config.letters[maxIndex];
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
    ];
  }
}
