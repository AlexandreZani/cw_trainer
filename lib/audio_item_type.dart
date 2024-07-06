enum AudioItemType {
  morse,
  text,
}

class AudioItem {
  final String value;
  final AudioItemType type;

  AudioItem(this.value, this.type);
}
