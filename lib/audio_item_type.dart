enum AudioItemType {
  morse,
  text,
  silence,
}

class AudioItem {
  final String text;
  final int milliseconds;
  final AudioItemType type;

  AudioItem.Text(this.text) :
    type = AudioItemType.text,
    milliseconds = 0;

  AudioItem.Morse(this.text) :
    type = AudioItemType.morse,
    milliseconds = 0;

  AudioItem.Pause(this.milliseconds) :
    type = AudioItemType.silence,
    text = '';
}
