import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';

class CopyGroupsExercise extends RepeatedExerciseBase {
  final LicwConfig _config;
  final RandomGroupGenerator _gen;

  CopyGroupsExercise(super.appConfig)
      : _config = appConfig.licw,
        _gen = RandomGroupGenerator(appConfig.randomGroups),
        super(
            voiceBefore: false,
            voiceAfter: false,
            repeatNum: 1,
            recapAtEnd: true);

  @override
  String nextExerciseChunk() {
    return _gen.randomGroup(licwCharacters(_config));
  }
}
