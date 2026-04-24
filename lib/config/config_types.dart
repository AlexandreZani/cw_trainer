mixin ConfigEnum on Enum {
  int get i;
  String get displayName;

  static T? fromIntInner<T extends Enum>(List<T> values, int i) {
    for (T e in values) {
      var ce = e as ConfigEnum;
      if (ce.i == i) {
        return e;
      }
    }
    return null;
  }
}
