import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<void> saveLoginInfo(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  static Future<Map<String, String>?> getLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      return {'username': username, 'password': password};
    } else {
      return null;
    }
  }
}
