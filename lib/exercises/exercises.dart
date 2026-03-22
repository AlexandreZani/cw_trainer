import 'dart:collection';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/config/config_types.dart';
import 'package:cw_trainer/exercises/copy_exercise.dart';
import 'package:cw_trainer/exercises/exercise_base.dart';
import 'package:cw_trainer/exercises/familiarity_exercise.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';
import 'package:cw_trainer/exercises/recognition_exercise.dart';
import 'package:cw_trainer/exercises/sending_exercise.dart';
import 'package:cw_trainer/exercises/words_exercise.dart';

enum CourseType with ConfigEnum {
  legacy(0, 'Legacy'),
  bc1(1, 'BC1');

  const CourseType(this.i, this.displayName, {this.deprecated = false});
  CourseType? fromInt(int i) => ConfigEnum.fromIntInner(CourseType.values, i);

  List<ExerciseType> get supportedExercises => switch (this) {
        CourseType.legacy => const [
            ExerciseType.randomGroups,
            ExerciseType.words
          ],
        CourseType.bc1 => const [
            ExerciseType.recognition,
            ExerciseType.familiarity,
            ExerciseType.copyGroups,
            ExerciseType.sending,
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
  recognition(2, 'Recognition'),
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

  static ExerciseBase _getExerciseByType(AppConfig config, ExerciseType type) {
    return switch (type) {
      ExerciseType.randomGroups => RandomGroupsExercise(config),
      ExerciseType.words => WordsExercise(config),
      ExerciseType.recognition => RecognitionExercise(config),
      ExerciseType.familiarity => FamiliarityExercise(config),
      ExerciseType.copyGroups => CopyGroupsExercise(config),
      ExerciseType.sending => SendingExercise(config),
    };
  }

  static ExerciseController getByType(AppConfig config, ExerciseType type) {
    return ExerciseController(config, _getExerciseByType(config, type));
  }

  static ExerciseController getCurrent(AppConfig config) {
    return getByType(config, config.sharedExercise.curExerciseType);
  }
}
