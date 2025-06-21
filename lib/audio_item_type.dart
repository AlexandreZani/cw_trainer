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
  final String caption;

  AudioItem.text(this.textString)
      : type = AudioItemType.text,
        caption = textString.toUpperCase(),
        milliseconds = 0;

  AudioItem.morse(this.textString, this.caption)
      : type = AudioItemType.morse,
        milliseconds = 0;

  AudioItem.spell(this.textString)
      : type = AudioItemType.spell,
        caption = textString.toUpperCase(),
        milliseconds = 0;

  AudioItem.silence(this.milliseconds, this.caption)
      : type = AudioItemType.silence,
        textString = '';
}
