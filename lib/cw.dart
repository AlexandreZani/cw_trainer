import 'package:characters/characters.dart';

import 'dart:math' as math;

class MorseGenerator {
  final int sampleRate;
  final int dotNumFrames;
  final int dashNumFrames;
  final int interElementNumFrames;
  final int interCharacterNumFrames;
  final int interGroupNumFrames;
  final int frequency;

  MorseGenerator(
      this.sampleRate,
      this.dotNumFrames,
      this.dashNumFrames,
      this.interElementNumFrames,
      this.interCharacterNumFrames,
      this.interGroupNumFrames,
      this.frequency);

  static MorseGenerator fromEwpm(
      int wpm, int ewpm, int sampleRate, int frequency) {
    const parisWeight = 50;
    int unitNumFrames = ((sampleRate * 60) ~/ (parisWeight * wpm));

    const parisSpaceWeight = 4 * 3 + 7; // 3 character spaces + 1 word space.
    const parisNonSpaceWeight = parisWeight - parisSpaceWeight;

    int unitFNumFrames =
        ((60 * sampleRate / ewpm) - (parisNonSpaceWeight * unitNumFrames)) ~/
            parisSpaceWeight;

    return MorseGenerator(
      sampleRate,
      unitNumFrames,
      unitNumFrames * 3,
      unitNumFrames,
      unitFNumFrames * 3,
      unitFNumFrames * 7,
      frequency,
    );
  }

  int get wpm => (60 * sampleRate) ~/ (dotNumFrames * 50);

  int get ewpm => (60 * sampleRate) ~/ stringNumFrames('PARIS ');

  int charNumFrames(String c) {
    var code = cwChar(c);
    int numFrames = (code.length - 1) * interElementNumFrames;
    for (var e in code.characters) {
      if (e == '.') {
        numFrames += dotNumFrames;
      } else {
        numFrames += dashNumFrames;
      }
    }

    return numFrames;
  }

  int stringNumFrames(String s) {
    int numFrames = 0;

    for (int i = 0; i < s.length; i++) {
      if (s[i] == ' ') {
        numFrames += interGroupNumFrames;
        continue;
      }

      if (i != 0 && s[i - 1] != ' ') {
        numFrames += interCharacterNumFrames;
      }

      numFrames += charNumFrames(s[i]);
    }

    return numFrames;
  }

  List<int> stringToPcm(String s) {
    List<int> pcm = List.filled(stringNumFrames(s), 128);
    int curFrame = 0;

    for (int i = 0; i < s.length; i++) {
      if (s[i] == ' ') {
        curFrame += interGroupNumFrames;
        continue;
      }

      if (i != 0 && s[i - 1] != ' ') {
        curFrame += interCharacterNumFrames;
      }

      curFrame = addCharacter(pcm, curFrame, s[i]);
    }

    return pcm;
  }

  int addCharacter(List<int> pcm, int startFrame, String c) {
    var code = cwChar(c);
    var curFrame = startFrame;

    for (int i = 0; i < code.length; i++) {
      if (code[i] == '.') {
        curFrame = addSineWave(pcm, curFrame, dotNumFrames);
      } else {
        curFrame = addSineWave(pcm, curFrame, dashNumFrames);
      }
      if (i < code.length - 1) {
        curFrame += interElementNumFrames;
      }
    }

    return curFrame;
  }

  int addSineWave(List<int> pcm, int startFrame, int numFrames) {
    const max_value = 127;

    final numFramesPerCycles = sampleRate / frequency;
    final step = math.pi * 2 / numFramesPerCycles;
    print('has ramp');

    for (int i = 0; i < numFrames; i++) {
      double ramp = 1.0;
      if (i < numFrames * 0.1) {
        ramp = i / (numFrames * 0.1);
      }

      if (i > numFrames * 0.9) {
        ramp = 1.0 - ((i - (numFrames * 0.9)) / (numFrames * 0.1));
      }
      pcm[i + startFrame] = (math.sin(step * (i % numFramesPerCycles)) * ramp * max_value).toInt() + 128;
    }

    return numFrames + startFrame;
  }
}

String cwChar(String c) {
  const codes = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    '0': '-----',
  };

  if (c.length != 1) {
    throw UnsupportedError("Function expected a single character got: $c");
  }

  if (!codes.containsKey(c.toUpperCase())) {
    throw UnsupportedError('Unsupported character $c');
  }

  return codes[c]!;
}
