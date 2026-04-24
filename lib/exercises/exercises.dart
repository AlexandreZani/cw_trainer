import 'dart:collection';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/exercises/copy_exercise.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:cw_trainer/exercises/familiarity_exercise.dart';
import 'package:cw_trainer/exercises/ttr_exercise.dart';
import 'package:cw_trainer/exercises/sending_exercise.dart';

enum CourseType with ConfigEnum {
  bc1(1, 'BC1'),
  bc2(2, 'BC2');

  const CourseType(this.i, this.displayName);
  CourseType? fromInt(int i) => ConfigEnum.fromIntInner(CourseType.values, i);

  List<ExerciseType> get supportedExercises => switch (this) {
        CourseType.bc1 => const [
            ExerciseType.ttr,
            ExerciseType.familiarity,
            ExerciseType.copyGroups,
            ExerciseType.sending,
          ],
        CourseType.bc2 => const [
            ExerciseType.ttr,
            ExerciseType.familiarity,
            ExerciseType.copyGroups,
            ExerciseType.sending,
          ],
      };

  @override
  final int i;
  @override
  final String displayName;
}

enum ExerciseType with ConfigEnum {
  ttr(2, 'TTR'),
  familiarity(3, 'Familiarity'),
  copyGroups(4, 'Copy Groups'),
  sending(5, 'Sending Exercise');

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
  final Queue<AudioItem> _queue = Queue.from([AudioItem.silence(300)]);
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

  static ExerciseBase _getExerciseByType(
      AppConfig config, CourseType course, ExerciseType type) {
    return switch (type) {
      ExerciseType.ttr => TTRExercise(config, course),
      ExerciseType.familiarity => FamiliarityExercise(config, course),
      ExerciseType.copyGroups => CopyGroupsExercise(config, course),
      ExerciseType.sending => SendingExercise(config, course),
    };
  }

  static ExerciseController getByType(
      AppConfig config, CourseType course, ExerciseType type) {
    return ExerciseController(config, _getExerciseByType(config, course, type));
  }

  static ExerciseController getCurrent(AppConfig config) {
    return getByType(config, config.sharedExercise.currentCourse,
        config.sharedExercise.curExerciseType);
  }
}
