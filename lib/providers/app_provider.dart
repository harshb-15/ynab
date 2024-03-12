import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AppProvider extends ChangeNotifier{
  String? _username;
  Color ?_color;
  String? _currency;
  SharedPreferences? _preferences;

  String? get username => _username;
  Color? get color => _color;
  String? get currency => _currency;

  static Future<AppProvider> getInstance() async {
    AppProvider provider =  AppProvider();
    provider._preferences = await SharedPreferences.getInstance();
    try {
      int? color = provider._preferences?.getInt("color");
      String? username = provider._preferences?.getString("username");
      String? currency = provider._preferences?.getString("currency");

      provider._color = color != null ? Color(color) : Colors.red;
      provider._username = username;
      provider._currency = currency;
      provider.notifyListeners();
    } catch(err){
      debugPrint("Something wrong....");
    }
    return provider;

  }

  sync() async {
    if(_username!=null) await _preferences!.setString("username", _username!);
    if(_currency!=null) await _preferences!.setString("currency", _currency!);
    if(_color!=null) await _preferences!.setInt("currency", _color!.value);
  }

  Future<void> update({String? username, String? currency}) async {
    _currency = currency;
    _username = username;
    await sync();
    notifyListeners();
  }

  Future<void> updateUsername(username) async {
    _username = username;
    await sync();
    notifyListeners();
  }

  Future<void> updateCurrency(currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", currency);
    notifyListeners();
  }
  Future<void> updateThemeColor(Color color) async {
    _color = color;
    await sync();
    notifyListeners();
  }

  Future<void> reset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("currency");
    await prefs.remove("color");
    await prefs.remove("username");

    _username = null;
    _currency = null;
    _color = null;

    notifyListeners();
  }

}