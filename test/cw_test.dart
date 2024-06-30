import 'package:test/test.dart';

import 'package:cw_trainer/cw.dart';

void main() {
  test('wpm and ewpm round trip', () {
    int wpm = 10;
    int ewpm = 5;
    int sampleRate = 10000;
    int f = 600;
    var gen = MorseGenerator.fromEwpm(wpm, ewpm, sampleRate, f);

    int unitNumFrames = sampleRate * 60 ~/ (50 * wpm);
    expect(gen.dotNumFrames, equals(unitNumFrames));
    expect(gen.dashNumFrames, equals(3 * unitNumFrames));

    expect(gen.wpm, equals(wpm));
    expect(gen.ewpm, equals(ewpm));
  });

  test('stringFrameNum', () {
    int wpm = 6;
    int ewpm = 6;
    int sampleRate = 10000;
    int f = 600;
    var gen = MorseGenerator.fromEwpm(wpm, ewpm, sampleRate, f);

    expect(gen.charNumFrames('P'), equals(22000));

    expect(gen.dotNumFrames, equals(2000));
    expect(gen.dashNumFrames, equals(6000));
    expect(gen.interElementNumFrames, equals(2000));
    expect(gen.interCharacterNumFrames, equals(6000));
    expect(gen.interGroupNumFrames, equals(14000));
    expect(gen.stringNumFrames("PARIS "), equals(100000));
  });

  test('stringToPcm does something', () {
    int wpm = 6;
    int ewpm = 6;
    int sampleRate = 10000;
    int f = 600;
    var gen = MorseGenerator.fromEwpm(wpm, ewpm, sampleRate, f);

    expect(gen.stringNumFrames("E"), equals(2000));
    var pcm = gen.stringToPcm("PARIS ");
    expect(pcm.length, equals(10 * sampleRate));
    expect(pcm[10], isNot(0));
  });
}