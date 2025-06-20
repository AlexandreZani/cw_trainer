import 'dart:collection';
import 'dart:math';

import 'package:cw_trainer/audio_item_type.dart';
import 'package:cw_trainer/config.dart';
import 'package:logging/logging.dart';

enum ExerciseType {
  randomGroups,
}

abstract class Exercise {
  final AppConfig _appConfig;
  final Queue<AudioItem> _queue = Queue.from([AudioItem.silence(300)]);

  Exercise(this._appConfig);

  get appConfig => _appConfig;

  AudioItem? getNextAudioItem() {
    if (_queue.isEmpty) {
      _replenishQueue();
    }

    if (_queue.isEmpty) {
      return null;
    }

    return _queue.removeFirst();
  }

  void _replenishQueue();

  static Exercise getByType(AppConfig config, ExerciseType type) {
    return switch (type) {
      ExerciseType.randomGroups => RandomGroupsExercise(config),
    };
  }
}

class RandomGroupsExercise extends Exercise {
  final log = Logger('RandomGroupsExercise');
  final Random _random = Random();
  final RandomGroupsConfig _config;
  final TtsConfig _ttsConfig;
  final SharedExerciseConfig _sharedExercise;
  int _remainingGroups;

  RandomGroupsExercise(super._appConfig)
      : _config = _appConfig.randomGroups,
        _ttsConfig = _appConfig.tts,
        _remainingGroups = _appConfig.sharedExercise.exerciseNum,
        _sharedExercise = _appConfig.sharedExercise;

  String _randomGroup() {
    String group = '';
    int maxIndex = _appConfig.randomGroups.levelI;
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
  void _replenishQueue() {
    log.finest('_replenishQueue $_remainingGroups');
    if (!_sharedExercise.repeat) {
      if (_remainingGroups <= 0) {
        return;
      }
      _remainingGroups -= 1;
    }

    String group = _randomGroup();
    int delayMs = (_ttsConfig.delay * 1000).round();

    _queue.addAll([
      AudioItem.morse(group),
      AudioItem.silence(delayMs),
      AudioItem.spell(group),
    ]);
  }
}
