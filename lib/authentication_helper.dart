import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthenticationHelper extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  final String baseUrl = 'https://stuppnig.ddns.net';
  bool _isAuthenticated = false;
  bool _isOrganization = false;
  String _lastError =
      'Login fehlgeschlagen. Bitte überprüfen Sie Ihre Eingabe.';

  bool get isAuthenticated => _isAuthenticated;
  bool get isOrganization => _isOrganization;
  String get lastError => _lastError;

  AuthenticationHelper() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? userToken = await _storage.read(key: 'user_jwt_token');
    String? organizationToken =
        await _storage.read(key: 'organization_jwt_token');

    if (userToken != null) {
      _isAuthenticated = true;
      notifyListeners();
    } else if (organizationToken != null) {
      _isAuthenticated = true;
      _isOrganization = true;
      notifyListeners();
    }
  }

  ///User Login Funktion
  Future<bool> userLogin(String username, String password) async {
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
        await _storage.write(
            key: 'user_jwt_token', value: data['access_token']);
        await _storage.write(key: 'username', value: username);
        await _storage.write(key: 'password', value: password);
        print(
            '[Storage] User-Token: ${await _storage.read(key: 'user_jwt_token')}');
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
      _lastError =
          "Fehler beim Verbindungsaufbau. Bitter versuchen Sie es später erneut!";
      return false;
    } on Exception catch (e) {
      print('[Authentication] Fehler: $e');
      return false;
    }
  }

  Future<bool> organizationLogin(String username, String password) async {
    try {
      print('$username, $password');
      final body = {
        //'grant_type': 'password',
        'username': username,
        'password': password,
        //'scope': '',
        //'client_id': 'string',
        //'client_secret': 'string',
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/organization/login'),
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
        await _storage.write(
            key: 'organization_jwt_token', value: data['access_token']);
        await _storage.write(key: 'username', value: username);
        await _storage.write(key: 'password', value: password);
        print(
            '[Storage] Organization-Token: ${await _storage.read(key: 'organization_jwt_token')}');
        _isAuthenticated = true;
        _isOrganization = true;
        notifyListeners();
        return true;
      } else {
        print(
            '[Authentication] Failed ${response.statusCode}, ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('[Authentication] Timeout');
      _lastError =
          "Fehler beim Verbindungsaufbau. Bitter versuchen Sie es später erneut!";
      return false;
    } on Exception catch (e) {
      print('[Authentication] Fehler: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _isOrganization = false;
    notifyListeners();
    await _storage.deleteAll();
  }

  Future<bool> changePassword(String oldpw, String newpw) async {
    final encodedOldpw = Uri.encodeComponent(oldpw);
    final encodedNewpw = Uri.encodeComponent(newpw);
    final String authToken = await getToken(false);
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/user/changepassword?old_secret=$encodedOldpw&new_secret=$encodedNewpw'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("[Authentication] Password changed");
        return true;
      }else {
        print(
            '[Authentication] Failed ${response.statusCode}, ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('[Authentication] Timeout');
      _lastError =
          "Fehler beim Verbindungsaufbau. Bitter versuchen Sie es später erneut!";
      return false;
    } on Exception catch (e) {
      print('[Authentication] Fehler: $e');
      return false;
    }
  }

  static Future<String> getToken(bool organization) async {
    String? token;
    if (organization) {
      token = await _storage.read(key: 'organization_jwt_token');
    } else {
      token = await _storage.read(key: 'user_jwt_token');
    }
    if (token != null) {
      return token;
    } else {
      return '';
    }
  }
}
