import 'dart:collection';
import 'dart:math';

import 'package:cw_trainer/audio_item_type.dart';
import 'package:cw_trainer/config.dart';

abstract class Exercise {
  final AppConfig _appConfig;
  final Queue<AudioItem> _queue = Queue();
  bool _exhausted = false;

  Exercise(this._appConfig);

  get appConfig => _appConfig;
  get complete => _exhausted && _queue.isEmpty;

  AudioItem? getNextAudioItem() {
    if (_queue.isEmpty) {
      _replenishQueue();
    }

    if (_queue.isEmpty) {
      return null;
    }

    return _queue.removeFirst();
  }

  void _replenishQueue();
}

class FarnsworthExercise extends Exercise {
  final Random _random = Random();
  final FarnsworthConfig _config;
  int _remainingGroups;
  final int _maxIndex;
  

  FarnsworthExercise(super._appConfig)
      : _config = _appConfig.farnsworthConfig,
        _remainingGroups = _appConfig.farnsworthConfig.groupNum,
        _maxIndex = _appConfig.farnsworthConfig.letters
            .indexOf(_appConfig.farnsworthConfig.level);

  String _randomGroup() {
    String group = '';
    while (group.length < _config.groupSize) {
      int i = _random.nextInt(_maxIndex + 1);
      group += _config.letters[i];
    }
    return group;
  }

  @override
  void _replenishQueue() {
    if (_remainingGroups == 0) {
      return;
    }


    String group = _randomGroup();
    if (_remainingGroups > 0) {
      _remainingGroups -= 1;
    }

    if (_remainingGroups == 0) {
      _exhausted = true;
    }

    _queue.addAll([
      (AudioItem(group, AudioItemType.morse)),
      (AudioItem(mapToItu(group), AudioItemType.text)),
    ]);
  }

}

Map<String, String> ituPhoneticAlphabet = {
  'A': 'Alpha',
  'B': 'Bravo',
  'C': 'Charlie',
  'D': 'Delta',
  'E': 'Echo',
  'F': 'Foxtrot',
  'G': 'Golf',
  'H': 'Hotel',
  'I': 'India',
  'J': 'Juliett',
  'K': 'Kilo',
  'L': 'Lima',
  'M': 'Mike',
  'N': 'November',
  'O': 'Oscar',
  'P': 'Papa',
  'Q': 'Quebec',
  'R': 'Romeo',
  'S': 'Sierra',
  'T': 'Tango',
  'U': 'Uniform',
  'V': 'Victor',
  'W': 'Whiskey',
  'X': 'X-ray',
  'Y': 'Yankee',
  'Z': 'Zulu',
  '0': 'Zero',
  '1': 'One',
  '2': 'Two',
  '3': 'Three',
  '4': 'Four',
  '5': 'Five',
  '6': 'Six',
  '7': 'Seven',
  '8': 'Eight',
  '9': 'Nine',
  '.': 'Full Stop',
  '=': 'Equal',
  ',': 'Comma',
  '/': 'Slash',
  '?': 'Question Mark',
};

String mapToItu(String input) {
  return input.toUpperCase().split('').map((char) {
    if (ituPhoneticAlphabet.containsKey(char)) {
      return ituPhoneticAlphabet[char];
    } else {
      return char;
    }
  }).join(' ');
}
