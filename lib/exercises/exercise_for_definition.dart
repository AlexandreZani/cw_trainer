import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_definition.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';
import 'package:cw_trainer/exercises/random_word_selector.dart';
import 'package:cw_trainer/exercises/repeated_exercise_base.dart';

abstract class ChunkGeneratorBase {
  String? nextChunk();

  static ChunkGeneratorBase makeGenerator(
      ExerciseKind kind, AppConfig appConfig) {
    switch (kind) {
      case RandomGroup r:
        return RandomGroupsGenerator2(
            randomGroupsConfig: appConfig.randomGroups,
            licwConfig: appConfig.licw,
            sharedExerciseConfig: appConfig.sharedExercise,
            forceGroupSize: r.forceGroupSize);
      case FromList f:
        return RandomWordSelector(
            course: appConfig.sharedExercise.currentCourse,
            licwConfig: appConfig.licw,
            baseWordlist: f.wordlist);
    }
  }
}

class ExerciseForDefinition extends RepeatedExerciseBase {
  final ChunkGeneratorBase _gen;

  ExerciseForDefinition(super.appConfig, ExerciseDefinition desc)
      : _gen = ChunkGeneratorBase.makeGenerator(desc.kind, appConfig),
        super(
            voiceBefore: desc.voiceBefore,
            voiceAfter: desc.voiceAfter,
            repeatNum: desc.repeatNum,
            recapAtEnd: desc.recapAtEnd,
            spellText: desc.spellText);

  @override
  String nextExerciseChunk() {
    return _gen.nextChunk()!;
  }
}
