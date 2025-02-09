import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthenticationHelper extends ChangeNotifier{
  static const _storage = FlutterSecureStorage();
  final String baseUrl = 'https://stuppnig.ddns.net';
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  AuthenticationHelper() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await _storage.read(key: 'jwt_token');

    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  } 

  ///Login Funktion
  Future<bool> login(String username, String password) async {
    try {
      print('$username, $password');
      final body = {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': '',
        'client_id': 'string',
        'client_secret': 'string',
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/user/login'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);
        await _storage.write(key: 'jwt_token', value: data['access_token']);
        await _storage.write(key: 'username', value: username);
        await _storage.write(key: 'password', value: password);
        print('[Storage] Token: ${await _storage.read(key: 'jwt_token')}');
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        print(
            '[Authentication] Failed ${response.statusCode}, ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('[Authentication] Timeout');
      return false;
    } on Exception catch (e) {
      print('[Authentication] Fehler: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
    await _storage.deleteAll();
  }

  static Future<String> getToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      return token;
    } else {
      return '';
    }
  }
}
