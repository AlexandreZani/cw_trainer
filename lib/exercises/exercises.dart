import 'dart:collection';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:cw_trainer/exercises/exercise_definition.dart';
import 'package:cw_trainer/exercises/exercise_for_definition.dart';
import 'package:cw_trainer/exercises/exercise_list.dart';

enum CourseType with ConfigEnum {
  bc1(1, 'BC1'),
  bc2(2, 'BC2');

  const CourseType(this.i, this.displayName);
  CourseType? fromInt(int i) => ConfigEnum.fromIntInner(CourseType.values, i);

  @override
  final int i;
  @override
  final String displayName;
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

  static ExerciseDefinition getCurrentDefinition(AppConfig config) => exercises
      .firstWhere((e) => e.id == config.sharedExercise.currentExerciseId);

  static ExerciseController getCurrent(AppConfig config) {
    ExerciseDefinition def = getCurrentDefinition(config);
    return ExerciseController(config, ExerciseForDefinition(config, def));
  }

  static List<ExerciseDefinition> getAvailableExercises2(AppConfig config) =>
      exercises.where((e) => e.isAvailable(config)).toList();
}
