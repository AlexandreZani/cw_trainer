mixin ConfigEnum on Enum {
  int get i;
  String get displayName;
  bool get deprecated;
  

  static T? fromIntInner<T extends Enum>(List<T> values, int i) {
    for (T e in values) {
      var ce = e as ConfigEnum;
      if (ce.i == i && !ce.deprecated) {
        return e;
      }
    }
    return null;
  }
}
