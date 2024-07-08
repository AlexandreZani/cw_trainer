import 'dart:collection';
import 'dart:math';

import 'package:cw_trainer/audio_item_type.dart';
import 'package:cw_trainer/config.dart';
import 'package:cw_trainer/itu_phonetic_alphabet.dart';
import 'package:logging/logging.dart';

enum ExerciseType {
  farnsworth,
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
      ExerciseType.farnsworth => FarnsworthExercise(config),
    };
  }
}

class FarnsworthExercise extends Exercise {
  final log = Logger('FarnsworthExercise');
  final Random _random = Random();
  final FarnsworthConfig _config;
  int _remainingGroups;
  final int _maxIndex;

  FarnsworthExercise(super._appConfig)
      : _config = _appConfig.farnsworth,
        _remainingGroups = _appConfig.farnsworth.groupNum,
        _maxIndex =
            _appConfig.farnsworth.letters.indexOf(_appConfig.farnsworth.level);

  String _randomGroup() {
    String group = '';
    while (group.length < _config.groupSize) {
      int i = _random.nextInt(_maxIndex + 1);
      group += _config.letters[i];
    }
    return group;
  }

  @override
  void _replenishQueue() {
    log.finest('_replenishQueue $_remainingGroups');
    if (_remainingGroups == 0) {
      return;
    }

    String group = _randomGroup();
    if (_remainingGroups > 0) {
      _remainingGroups -= 1;
    }

    _queue.addAll([
      AudioItem.morse(group),
      AudioItem.text(mapToItu(group)),
    ]);
  }
}
