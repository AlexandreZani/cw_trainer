import 'dart:math';

import 'package:cw_trainer/config/config.dart';

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
