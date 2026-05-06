import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/exercises/random_word_selector.dart';

// Part of the new way to define exercises.

enum PracticeSettings {
  cwSpeed,
  delayAfterSpeaking,
  delayBeforeSpeaking,
  numberOfGroups,
  groupSize,
  timeBetweenGroups,
}

class ExerciseDefinition {
  final int id; // Unique id for exercises.
  final String name; // Display name of the exercise.
  final ExerciseKind kind; // Which kind of exercise and related configuration.
  final List<CourseType> courses; // List of courses supported by the exercise.
  final bool
      voiceBefore; // Should the text be spoken before the code? (default: false)
  final bool
      voiceAfter; // Should the text be spoken after the code? (default: true)
  final int
      repeatNum; // How many times should the code be repeated? (default: 1)
  final bool
      recapAtEnd; // Should the text be spoken at the end of the exercise? (default: false)
  final bool spellText; // Should the text be spelled out or spoken?
  final bool
      isDisabled; // A disabled exercise definition is treated the same as not existing. (default: false)
  final List<PracticeSettings>?
      practiceSettings; // If not set we try to set reasonable defaults.

  ExerciseDefinition(
      {required this.id,
      required this.name,
      required this.kind,
      required this.courses,
      this.voiceBefore = false,
      this.voiceAfter = true,
      this.repeatNum = 1,
      this.recapAtEnd = false,
      required this.spellText,
      this.practiceSettings,
      this.isDisabled = false});

  bool isAvailable(AppConfig appConfig) {
    return !isDisabled &&
        courses.contains(appConfig.sharedExercise.currentCourse) &&
        kind.isAvailable(appConfig);
  }

  List<PracticeSettings> getPracticeSettings() {
    if (practiceSettings != null) {
      return practiceSettings!;
    }

    List<PracticeSettings> settings = [PracticeSettings.cwSpeed];

    if (voiceAfter) {
      settings.add(PracticeSettings.delayBeforeSpeaking);
    } else {
      settings.add(PracticeSettings.timeBetweenGroups);
    }

    if (voiceBefore) {
      settings.add(PracticeSettings.delayAfterSpeaking);
    }

    if (recapAtEnd) {
      settings.add(PracticeSettings.numberOfGroups);
    }

    switch (kind) {
      case RandomGroup(forceGroupSize: null):
        settings.add(PracticeSettings.numberOfGroups);
      default:
    }

    return settings;
  }
}

sealed class ExerciseKind {
  bool isAvailable(AppConfig appConfig);
}

class RandomGroup extends ExerciseKind {
  final int? forceGroupSize;

  RandomGroup({this.forceGroupSize});

  @override
  bool isAvailable(AppConfig appConfig) {
    return true;
  }
}

class FromList extends ExerciseKind {
  final List<String> wordlist;

  FromList({required this.wordlist});

  @override
  bool isAvailable(AppConfig appConfig) {
    String signs = currentSigns(appConfig);
    // The exercise is available if at least 3 words from the list are supported.
    return supportsAtLeast(signs, wordlist, 3);
  }
}
