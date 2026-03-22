import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/licw_exercise.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';

class RecognitionExercise extends RepeatedExerciseBase {
  final LicwConfig _config;
  final RandomGroupGenerator _gen;

  RecognitionExercise(super.appConfig)
      : _config = appConfig.licw,
        _gen = RandomGroupGenerator(appConfig.randomGroups),
        super(
            voiceBefore: false,
            voiceAfter: true,
            repeatNum: 1,
            recapAtEnd: false);

  @override
  String nextExerciseChunk() {
    return _gen.randomGroup(licwCharacters(_config));
  }
}
