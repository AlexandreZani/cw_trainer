import 'package:flutter_test/flutter_test.dart';

import 'package:cw_trainer/exercises/words_exercise.dart';

void main() {
  group('filterWordlist', () {
    test('finds some', () {
      const wordlist = ['hello', 'elo', 'world'];
      var supported = 'helo'.split('').toSet();

      const expected = ['hello', 'elo'];

      expect(filterWordlist(supported, wordlist), equals(expected));
    });

    test('finds none', () {
      const wordlist = ['hello', 'elo', 'world'];
      var supported = 'l'.split('').toSet();

      expect(filterWordlist(supported, wordlist), equals([]));
    });
  });
}
