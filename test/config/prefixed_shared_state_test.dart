import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cw_trainer/config/prefixed_shared_state.dart';
import 'package:cw_trainer/exercises/exercises.dart';

void main() {
  late SharedPreferences prefs;
  late PrefixedSharedState psp;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    psp = PrefixedSharedState(prefs, 'pfx');
  });

  group('PrefixedSharedPreferences', () {
    test('get returns null for missing key', () {
      expect(psp.get<int>('x'), isNull);
    });

    test('set and get int', () {
      psp.set('n', 42);
      expect(psp.get<int>('n'), equals(42));
    });

    test('set and get double', () {
      psp.set('d', 3.14);
      expect(psp.get<double>('d'), equals(3.14));
    });

    test('set and get String', () {
      psp.set('s', 'hello');
      expect(psp.get<String>('s'), equals('hello'));
    });

    test('set and get bool', () {
      psp.set('b', true);
      expect(psp.get<bool>('b'), isTrue);
    });

    test('set and get List<String>', () {
      psp.set('l', ['a', 'b', 'c']);
      expect(psp.get<List<String>>('l'), equals(['a', 'b', 'c']));
    });

    test('get<List<String>> works when stored value is List<Object?>',
        () async {
      // SharedPreferences.get() returns List<Object?> on real platforms, not
      // List<String>. Seed the raw key to simulate that and verify the cast
      // doesn't throw.
      SharedPreferences.setMockInitialValues({
        'pfx_l': <Object?>['a', 'b', 'c']
      });
      prefs = await SharedPreferences.getInstance();
      psp = PrefixedSharedState(prefs, 'pfx');
      expect(psp.get<List<String>>('l'), equals(['a', 'b', 'c']));
    });

    test('set and get Set<int>', () {
      psp.set('si', {1, 2, 3});
      expect(psp.get<Set<int>>('si'), equals({1, 2, 3}));
    });

    test('set and get ConfigEnum via setEnum/getEnum', () {
      psp.set('e', CourseType.bc1);
      expect(psp.getEnum('e', CourseType.values), equals(CourseType.bc1));
    });

    test('getEnum returns null for unknown value', () {
      expect(psp.getEnum('e', CourseType.values), isNull);
    });

    test('keys are prefixed — different prefixes do not share values', () {
      final other = PrefixedSharedState(prefs, 'other');
      psp.set('k', 1);
      expect(other.get<int>('k'), isNull);
    });

    test('set unsupported type throws ArgumentError', () {
      expect(() => psp.set('x', Object()), throwsArgumentError);
    });

    test('notifying() returns a NotifyingPrefixedSharedPreferences', () {
      expect(psp.notifying(() {}), isA<NotifyingPrefixedSharedState>());
    });
  });

  group('NotifyingPrefixedSharedPreferences', () {
    test('set calls notifyListeners', () {
      int calls = 0;
      final npsp = psp.notifying(() => calls++);
      npsp.set('n', 7);
      expect(calls, equals(1));
    });

    test('multiple sets call notifyListeners each time', () {
      int calls = 0;
      final npsp = psp.notifying(() => calls++);
      npsp.set('a', 1);
      npsp.set('b', 2);
      expect(calls, equals(2));
    });

    test('get does not call notifyListeners', () {
      int calls = 0;
      final npsp = psp.notifying(() => calls++);
      npsp.set('n', 5);
      calls = 0;
      npsp.get<int>('n');
      expect(calls, equals(0));
    });

    test('set writes value readable by base class', () {
      final npsp = psp.notifying(() {});
      npsp.set('n', 99);
      expect(psp.get<int>('n'), equals(99));
    });

    test('nonNotifying() returns a PrefixedSharedPreferences', () {
      final npsp = psp.notifying(() {});
      expect(npsp.nonNotifying(), isA<PrefixedSharedState>());
    });
  });
}
