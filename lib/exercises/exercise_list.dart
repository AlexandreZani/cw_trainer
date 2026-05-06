import 'package:cw_trainer/exercises/exercise_definition.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/wordlist.dart';

List<ExerciseDefinition> exercises = [
  ExerciseDefinition(
    id: 0,
    name: "TTR",
    kind: RandomGroup(),
    courses: [CourseType.bc1, CourseType.bc2],
    spellText: true,
  ),
  ExerciseDefinition(
    id: 1,
    name: "Familiarity",
    kind: RandomGroup(forceGroupSize: 1),
    courses: [CourseType.bc1, CourseType.bc2],
    spellText: true,
    voiceBefore: true,
    voiceAfter: false,
    repeatNum: 3,
  ),
  ExerciseDefinition(
    id: 2,
    name: "Flow Practice",
    kind: RandomGroup(),
    courses: [CourseType.bc1, CourseType.bc2],
    spellText: true,
    voiceAfter: false,
    recapAtEnd: true,
  ),
  ExerciseDefinition(
    id: 3,
    name: "Sending",
    kind: RandomGroup(),
    courses: [CourseType.bc1, CourseType.bc2],
    spellText: true,
    voiceAfter: false,
    recapAtEnd: false,
  ),
  ExerciseDefinition(
    id: 4,
    name: "Words",
    kind: FromList(wordlist: bcWordlist),
    courses: [CourseType.bc1, CourseType.bc2],
    spellText: false,
  ),
];
