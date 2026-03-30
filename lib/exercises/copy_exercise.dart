import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';

class CopyGroupsExercise extends RepeatedExerciseBase {
  final LicwConfig _config;
  final CourseType _course;
  final RandomGroupGenerator _gen;

  CopyGroupsExercise(super.appConfig, this._course)
      : _config = appConfig.licw,
        _gen = RandomGroupGenerator(appConfig.randomGroups),
        super(
            voiceBefore: false,
            voiceAfter: false,
            repeatNum: 1,
            recapAtEnd: true);

  @override
  String nextExerciseChunk() {
    return _gen.randomGroup(licwSignsForCourse(_config, _course));
  }
}
