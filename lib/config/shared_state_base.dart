import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedStateBase extends ChangeNotifier {
  final SharedPreferences _prefs;
  final String _prefix;
  SharedStateBase(this._prefs, this._prefix) : super();

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

  void setInt(String k, int v) {
    _prefs.setInt(_key(k), v);
    notifyListeners();
  }

  void setDouble(String k, double v) {
    _prefs.setDouble(_key(k), v);
    notifyListeners();
  }

  void setString(String k, String v) {
    _prefs.setString(_key(k), v);
    notifyListeners();
  }

  void setBool(String k, bool v) {
    _prefs.setBool(_key(k), v);
    notifyListeners();
  }

  void setStringList(String k, List<String> v) {
    _prefs.setStringList(_key(k), v);
    notifyListeners();
  }
}
