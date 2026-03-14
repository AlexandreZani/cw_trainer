import 'dart:collection';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:cw_trainer/exercises/licw_exercise.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';
import 'package:cw_trainer/exercises/words_exercise.dart';

enum ExerciseType {
  randomGroups,
  words,
  licwRecognition,
}

class ExerciseController {
  final AppConfig _appConfig;
  final Queue<AudioItem> _queue = Queue.from([AudioItem.silence(300, "")]);
  final ExerciseBase _exercise;

  ExerciseController(this._appConfig, this._exercise);

  get appConfig => _appConfig;

  AudioItem? getNextAudioItem() {
    if (_queue.isEmpty) {
      _queue.addAll(_exercise.replenishQueue() ?? []);
    }

    if (_queue.isEmpty) {
      return null;
    }

    return _queue.removeFirst();
  }

  static ExerciseController getByType(AppConfig config, ExerciseType type) {
    return switch (type) {
      ExerciseType.randomGroups =>
        ExerciseController(config, RandomGroupsExercise(config)),
      ExerciseType.words => ExerciseController(config, WordsExercise(config)),
      ExerciseType.licwRecognition =>
        ExerciseController(config, LicwRecognitionExercise(config))
    };
  }

  static ExerciseController getCurrent(AppConfig config) {
    return getByType(config, config.sharedExercise.curExerciseType);
  }
}
