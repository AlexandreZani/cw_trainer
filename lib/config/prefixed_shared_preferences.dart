import 'package:cw_trainer/config/config_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefixedSharedPreferences {
  final SharedPreferences _prefs;
  final String _prefix;

  PrefixedSharedPreferences(this._prefs, this._prefix);

  String _key(String k) {
    return '${_prefix}_$k';
  }

  int? getInt(String k) {
    return _prefs.getInt(_key(k));
  }

  double? getDouble(String k) {
    return _prefs.getDouble(_key(k));
  }

  String? getString(String k) {
    return _prefs.getString(_key(k));
  }

  bool? getBool(String k) {
    return _prefs.getBool(_key(k));
  }

  List<String>? getStringList(String k) {
    return _prefs.getStringList(_key(k));
  }

  Set<E>? getSet<E>(String k, E? Function(String) parse) {
    List<String>? strings = _prefs.getStringList(k);
    if (strings == null) {
      return null;
    }

    Set<E> es = {};
    for (final s in strings) {
      final e = parse(s);
      if (e == null) {
        return null;
      }

      es.add(e);
    }

    return es;
  }

  Set<int>? getIntSet(String k) {
    return getSet(k, int.tryParse);
  }

  T? getEnum<T>(String k, List<T> values) {
    int? i = _prefs.getInt(k);
    if (i == null) {
      return null;
    }

    for (T e in values) {
      var ce = e as ConfigEnum;
      if (ce.i == i && !ce.deprecated) {
        return e;
      }
    }
    return null;
  }

  void setInt(String k, int v) {
    _prefs.setInt(_key(k), v);
  }

  void setDouble(String k, double v) {
    _prefs.setDouble(_key(k), v);
  }

  void setString(String k, String v) {
    _prefs.setString(_key(k), v);
  }

  void setBool(String k, bool v) {
    _prefs.setBool(_key(k), v);
  }

  void setStringList(String k, List<String> v) {
    _prefs.setStringList(_key(k), v);
  }

  void setSet<E>(String k, Set<E> es, String Function(E) toString) {
    setStringList(k, es.map(toString).toList());
  }

  void setIntSet(String k, Set<int> v) {
    setStringList(k, v.map((i) => i.toString()).toList());
  }

  void setEnum(String k, ConfigEnum v) {
    setInt(k, v.i);
  }
}
