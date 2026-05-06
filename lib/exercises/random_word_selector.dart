import 'dart:math';

import 'package:cw_trainer/exercises/exercise_for_definition.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/config/config.dart';

List<String> filterWordlist(String supported, List<String> wordlist) {
  Set<String> supportedChars = supported.toLowerCase().split('').toSet();
  return wordlist
      .where((word) => supportedChars.containsAll(word.split('')))
      .toList();
}

bool supportsAtLeast(String supported, List<String> wordlist, int n) {
  Set<String> supportedChars = supported.toLowerCase().split('').toSet();
  return wordlist
          .where((word) => supportedChars.containsAll(word.split('')))
          .take(n)
          .length ==
      n;
}

class RandomWordSelector extends ChunkGeneratorBase {
  final Random _random = Random();
  final CourseType _course;
  final LicwConfig _licwConfig;
  final List<String> _baseWordlist;
  String _supported = "";
  List<String> _wordlist = [];

  RandomWordSelector(
      {required CourseType course,
      required LicwConfig licwConfig,
      required List<String> baseWordlist})
      : _course = course,
        _licwConfig = licwConfig,
        _baseWordlist = baseWordlist;

  String curSupported() => signsForCourse(_licwConfig, _course);

  List<String> curWordlist() {
    var curSigns = curSupported();
    if (curSigns != _supported) {
      _supported = curSigns;
      _wordlist = filterWordlist(_supported, _baseWordlist);
    }

    return _wordlist;
  }

  String getWord() {
    if (curWordlist().isEmpty) {
      return "not enough letters";
    }
    var i = _random.nextInt(curWordlist().length);
    return curWordlist()[i];
  }

  @override
  String? nextChunk() => getWord();
}
