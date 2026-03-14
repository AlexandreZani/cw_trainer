import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/random_groups_exercise.dart';

final bc1Groups = ["TIN", "PSG", "LCD", "HOF", "UWB", "REA"];

class LicwRecognitionExercise extends RandomGroupsExerciseBase {
  LicwRecognitionExercise(super._appConfig) : _config = _appConfig.licw;

  final LicwConfig _config;

  @override
  String charPool() {
    return bc1Groups.asMap().entries.fold("", (acc, e) {
      if (_config.bc1GroupsSelected.contains(e.key)) {
        return acc + e.value;
      } else {
        return acc;
      }
    });
  }
}
