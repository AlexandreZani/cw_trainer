import 'dart:math';

import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/exercises/licw_data.dart';
import 'package:cw_trainer/config/config.dart';

List<String> filterWordlist(Set<String> supported, List<String> wordlist) {
  return wordlist
      .where((word) => supported.containsAll(word.split('')))
      .toList();
}

bool supportsAtLeast(Set<String> supported, List<String> wordlist, int n) {
  return wordlist
          .where((word) => supported.containsAll(word.split('')))
          .take(n)
          .length ==
      n;
}

class RandomWordSelector {
  final Random _random = Random();
  final CourseType _course;
  final LicwConfig _licwConfig;
  final List<String> _baseWordlist;
  Set<String> _supported = {};
  List<String> _wordlist = [];

  RandomWordSelector(this._licwConfig, this._course, this._baseWordlist);

  Set<String> curSupported() =>
      licwSignsForCourse(_licwConfig, _course).split('').toSet();

  List<String> curWordlist() {
    var curSigns = curSupported();
    if (curSigns != _supported) {
      _supported = curSigns;
      _wordlist = filterWordlist(_supported, _baseWordlist);
    }

    return _wordlist;
  }

  String getWord() {
    var i = _random.nextInt(curWordlist().length);
    return curWordlist()[i];
  }
}
