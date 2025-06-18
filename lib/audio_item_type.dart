enum AudioItemType {
  morse,
  text,
  silence,
  spell,
}

class AudioItem {
  final String textString;
  final int milliseconds;
  final AudioItemType type;

  AudioItem.text(this.textString)
      : type = AudioItemType.text,
        milliseconds = 0;

  AudioItem.morse(this.textString)
      : type = AudioItemType.morse,
        milliseconds = 0;

  AudioItem.spell(this.textString)
      : type = AudioItemType.spell,
        milliseconds = 0;

  AudioItem.silence(this.milliseconds)
      : type = AudioItemType.silence,
        textString = '';
}
