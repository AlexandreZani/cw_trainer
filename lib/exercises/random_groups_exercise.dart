import 'dart:math';

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
  final SharedExerciseConfig _sharedExerciseConfig;
  int _remainingExercises;
  List<AudioItem> _recap;

  RepeatedExerciseBase(super._appConfig,
      {required this.voiceBefore,
      required this.voiceAfter,
      required this.repeatNum,
      required this.recapAtEnd})
      : _sharedExerciseConfig = _appConfig.sharedExercise,
        _remainingExercises = _appConfig.sharedExercise.exerciseNum,
        _recap = [];

  String nextExerciseChunk();

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
        AudioItem.spell(text),
        AudioItem.silenceFromDouble(_sharedExerciseConfig.betweenGroups)
      ]);
    }

    List<AudioItem> chunk = [];
    if (voiceBefore) {
      chunk.addAll([
        AudioItem.spell(text),
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
      chunk.add(AudioItem.spell(text));
    }

    return chunk;
  }
}

class RandomGroupGenerator {
  final Random _random = Random();
  final RandomGroupsConfig _config;

  RandomGroupGenerator(this._config);

  String randomGroup(String characters, {int? groupSize}) {
    groupSize = groupSize ?? _config.groupSize;

    String group = '';
    while (group.length < groupSize) {
      int i = _random.nextInt(characters.length);
      group += characters[i];
    }

    return group;
  }
}

class RandomGroupsExercise extends RepeatedExerciseBase {
  final RandomGroupsConfig _config;
  final RandomGroupGenerator _gen;

  RandomGroupsExercise(super.appConfig)
      : _config = appConfig.randomGroups,
        _gen = RandomGroupGenerator(appConfig.randomGroups),
        super(
            voiceBefore: false,
            voiceAfter: true,
            repeatNum: 1,
            recapAtEnd: false);

  @override
  String nextExerciseChunk() {
    return _gen.randomGroup(_config.letters);
  }
}
