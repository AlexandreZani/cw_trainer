import 'dart:math';

import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercise_for_description.dart';
import 'package:cw_trainer/exercises/licw_data.dart';

class RandomGroupGenerator {
  final Random _random = Random();
  final RandomGroupsConfig _config;

  RandomGroupGenerator(this._config);

  int randomGroupSize() =>
      _random.nextInt(_config.maxGroupSize - _config.minGroupSize + 1) +
      _config.minGroupSize;

  String randomGroup(String characters, {int? groupSize}) {
    groupSize = groupSize ?? randomGroupSize();

    String group = '';
    while (group.length < groupSize) {
      int i = _random.nextInt(characters.length);
      group += characters[i];
    }

    return group;
  }
}

class RandomGroupsGenerator2 extends ChunkGeneratorBase {
  final Random _random = Random();
  final RandomGroupsConfig _randomGroupsConfig;
  final LicwConfig _licwConfig;
  final SharedExerciseConfig _sharedExerciseConfig;
  final int? _forceGroupSize;

  RandomGroupsGenerator2(
      {required RandomGroupsConfig randomGroupsConfig,
      required LicwConfig licwConfig,
      required SharedExerciseConfig sharedExerciseConfig,
      required int? forceGroupSize})
      : _randomGroupsConfig = randomGroupsConfig,
        _licwConfig = licwConfig,
        _sharedExerciseConfig = sharedExerciseConfig,
        _forceGroupSize = forceGroupSize;

  int randomGroupSize() {
    int min = _randomGroupsConfig.minGroupSize;
    int max = _randomGroupsConfig.maxGroupSize;
    return _random.nextInt(max - min + 1) + min;
  }

  @override
  String nextChunk() {
    String characters =
        signsForCourse(_licwConfig, _sharedExerciseConfig.currentCourse);
    int groupSize = _forceGroupSize ?? randomGroupSize();

    String group = '';
    while (group.length < groupSize) {
      int i = _random.nextInt(characters.length);
      group += characters[i];
    }

    return group;
  }
}
