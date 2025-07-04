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

extension StringX on String {
  bool isBetween(String min, String max) {
    final a = min.codeUnitAt(0);
    final z = max.codeUnitAt(0);
    final i = codeUnitAt(0);
    return i >= a && i <= z;
  }

  bool isLowerAlpha() => isBetween('a', 'z');

  bool isUpperAlpha() => isBetween('A', 'Z');

  bool isAlpha() => isLowerAlpha() || isUpperAlpha();

  bool isNum() => isBetween('0', '9');

  bool isAlphaNum() => isAlpha() || isNum();
}

String spellWithoutItu(String input) {
  return input.toUpperCase().split('').map((char) {
    if (char.isAlphaNum() || !ituPhoneticAlphabet.containsKey(char)) {
      return char;
    } else {
      return ituPhoneticAlphabet[char];
    }
  }).join('. ');
}

String spellWithItu(String input) {
  return input.toUpperCase().split('').map((char) {
    if (ituPhoneticAlphabet.containsKey(char)) {
      return ituPhoneticAlphabet[char];
    } else {
      return char;
    }
  }).join(' ');
}
