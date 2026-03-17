import 'dart:math';

import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';

final bc1Groups = ["TIN", "PSG", "LCD", "HOF", "UWB", "REA"];

String licwCharacters(LicwConfig config) {
  return bc1Groups.asMap().entries.fold("", (acc, e) {
    if (config.bc1GroupsSelected.contains(e.key)) {
      return acc + e.value;
    } else {
      return acc;
    }
  });
}

class LicwRecognitionExercise extends RandomGroupsExerciseBase {
  LicwRecognitionExercise(super._appConfig) : _config = _appConfig.licw;

  final LicwConfig _config;

  @override
  String charPool() {
    return licwCharacters(_config);
  }
}

class LicwFamiliarityExercise extends RepeatedExerciseBase {
  LicwFamiliarityExercise(super._appConfig) : _config = _appConfig.licw;

  final Random _random = Random();
  final LicwConfig _config;

  @override
  List<AudioItem> nextExerciseChunk() {
    String letters = licwCharacters(_config);
    int i = _random.nextInt(letters.length);

    return [
      AudioItem.spell(letters[i]),
      silenceAfterTts(letters[i], forceCaption: true),
      for (int j = 0; j < 3; j++) ...[
        AudioItem.morse(letters[i], letters[i]),
        silenceAfterTts(letters[i], forceCaption: true),
      ]
    ];
  }
}
