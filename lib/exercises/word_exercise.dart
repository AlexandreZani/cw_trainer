import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/exercises/random_word_selector.dart';
import 'package:cw_trainer/exercises/repeated_exercise_base.dart';
import 'package:cw_trainer/exercises/wordlist.dart';

class WordExercise extends RepeatedExerciseBase {
  final RandomWordSelector _gen;

  WordExercise(super.appConfig, CourseType course)
      : _gen = RandomWordSelector(appConfig.licw, course, bcWordlist),
        super(
            voiceBefore: false,
            voiceAfter: true,
            repeatNum: 1,
            recapAtEnd: false,
            spellText: false);

  @override
  String nextExerciseChunk() {
    // TODO: Add a way to terminate if the exercise stops being available.
    return _gen.getWord();
  }

  static bool isAvailable(AppConfig appConfig) {
    String curSigns = currentSigns(appConfig);
    return supportsAtLeast(curSigns, bcWordlist, 3);
  }
}
