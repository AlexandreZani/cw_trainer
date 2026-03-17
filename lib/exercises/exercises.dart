import 'dart:collection';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:cw_trainer/exercises/licw_exercise.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';
import 'package:cw_trainer/exercises/words_exercise.dart';

enum CourseType with ConfigEnum {
  legacy(0, 'Legacy'),
  licwBc1(1, 'LICW BC1');

  const CourseType(this.i, this.displayName, {this.deprecated = false});
  CourseType? fromInt(int i) => ConfigEnum.fromIntInner(CourseType.values, i);

  List<ExerciseType> get supportedExercises => switch (this) {
        CourseType.legacy => const [ExerciseType.randomGroups, ExerciseType.words],
        CourseType.licwBc1 => const [
            ExerciseType.licwRecognition,
            ExerciseType.licwFamiliarity
          ],
      };

  @override
  final int i;
  @override
  final String displayName;
  @override
  final bool deprecated;
}

enum ExerciseType with ConfigEnum {
  randomGroups(0, 'Random Groups'),
  words(1, 'Random Words'),
  licwRecognition(2, 'Recognition'),
  licwFamiliarity(3, 'Familiarity');

  const ExerciseType(this.i, this.displayName, {this.deprecated = false});
  ExerciseType? fromInt(int i) =>
      ConfigEnum.fromIntInner(ExerciseType.values, i);

  @override
  final int i;
  @override
  final String displayName;
  @override
  final bool deprecated;
}

class ExerciseController {
  final AppConfig _appConfig;
  final Queue<AudioItem> _queue = Queue.from([AudioItem.silence(300, '')]);
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

  static ExerciseBase _getExerciseByType(AppConfig config, ExerciseType type) {
    return switch (type) {
      ExerciseType.randomGroups => RandomGroupsExercise(config),
      ExerciseType.words => WordsExercise(config),
      ExerciseType.licwRecognition => LicwRecognitionExercise(config),
      ExerciseType.licwFamiliarity => LicwFamiliarityExercise(config),
    };
  }

  static ExerciseController getByType(AppConfig config, ExerciseType type) {
    return ExerciseController(config, _getExerciseByType(config, type));
  }

  static ExerciseController getCurrent(AppConfig config) {
    return getByType(config, config.sharedExercise.curExerciseType);
  }
}
