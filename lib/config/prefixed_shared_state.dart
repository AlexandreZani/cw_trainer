import 'package:cw_trainer/config/config_types.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefixedSharedState {
  final SharedPreferences _prefs;
  final String _prefix;

  PrefixedSharedState(this._prefs, this._prefix);

  NotifyingPrefixedSharedState notifying(VoidCallback notifyListeners) =>
      NotifyingPrefixedSharedState(_prefs, _prefix, notifyListeners);

  String _key(String k) {
    return '${_prefix}_$k';
  }

  T? get<T>(String k) {
    if (T == Set<int>) {
      return getSet(k, int.tryParse) as T?;
    }
    if (T == List<String>) {
      return _prefs.getStringList(_key(k)) as T?;
    }
    return _prefs.get(_key(k)) as T?;
  }

  Set<E>? getSet<E>(String k, E? Function(String) parse) {
    List<String>? strings = get(k);
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

  T? getEnum<T>(String k, List<T> values) {
    int? i = get(k);
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

  void set<T>(String k, T v) {
    final key = _key(k);
    switch (v) {
      case int i:
        _prefs.setInt(key, i);
      case double d:
        _prefs.setDouble(key, d);
      case String s:
        _prefs.setString(key, s);
      case bool b:
        _prefs.setBool(key, b);
      case List<String> l:
        _prefs.setStringList(key, l);
      case Set<int> s:
        _prefs.setStringList(key, s.map((i) => i.toString()).toList());
      case ConfigEnum e:
        _prefs.setInt(key, e.i);
      default:
        throw ArgumentError('Unsupported type: ${v.runtimeType}');
    }
  }

  void setSet<E>(String k, Set<E> es, String Function(E) toString) {
    set(k, es.map(toString).toList());
  }
}

class NotifyingPrefixedSharedState extends PrefixedSharedState {
  final VoidCallback notifyListeners;

  NotifyingPrefixedSharedState(
      super.prefs, super.prefix, this.notifyListeners);

  PrefixedSharedState nonNotifying() =>
      PrefixedSharedState(_prefs, _prefix);

  @override
  void set<T>(String k, T v) {
    super.set(k, v);
    notifyListeners();
  }
}
