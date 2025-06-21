import 'dart:collection';
import 'dart:math';

import 'package:cw_trainer/audio_item_type.dart';
import 'package:cw_trainer/config.dart';
import 'package:cw_trainer/words.dart';
import 'package:logging/logging.dart';

enum ExerciseType {
  randomGroups,
  words,
}

abstract class Exercise {
  final AppConfig _appConfig;
  final Queue<AudioItem> _queue = Queue.from([AudioItem.silence(300, "")]);

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
      ExerciseType.words => WordsExercise(config),
    };
  }

  static Exercise getCurrent(AppConfig config) {
    return getByType(config, config.sharedExercise.curExerciseType);
  }

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

class RandomGroupsExercise extends Exercise {
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

    _queue.addAll([
      morseAudioItem(group),
      silenceBeforeTts(group),
      AudioItem.spell(group),
    ]);
  }
}

class WordsExercise extends Exercise {
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
  void _replenishQueue() {
    log.finest('_replenishQueue $_remainingWords');
    if (!_sharedExercise.repeat) {
      if (_remainingWords <= 0) {
        return;
      }
      _remainingWords -= 1;
    }

    var c = _pickLetter();
    var words = wordsForExercise[c]!;

    int i = _random.nextInt(words.length);
    String word = words[i];

    _queue.addAll([
      morseAudioItem(word),
      silenceBeforeTts(word),
      AudioItem.text(word),
    ]);
  }
}
