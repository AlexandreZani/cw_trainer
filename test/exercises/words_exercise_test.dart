import 'package:flutter_test/flutter_test.dart';

import 'package:cw_trainer/exercises/random_word_selector.dart';

void main() {
  group('filterWordlist', () {
    test('finds some', () {
      const wordlist = ['hello', 'elo', 'world'];
      var supported = 'helo';

      const expected = ['hello', 'elo'];

      expect(filterWordlist(supported, wordlist), equals(expected));
    });

    test('finds none', () {
      const wordlist = ['hello', 'elo', 'world'];
      var supported = 'l';

      expect(filterWordlist(supported, wordlist), equals([]));
    });
  });

  group('supportsAtLeast', () {
    test('finds 2', () {
      const wordlist = ['hello', 'elo', 'world'];
      var supported = 'helo';

      expect(supportsAtLeast(supported, wordlist, 2), isTrue);
      expect(supportsAtLeast(supported, wordlist, 3), isFalse);
    });
  });
}
