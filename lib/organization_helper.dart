import 'dart:async';
import 'dart:io';

import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:http/http.dart' as http;

class OrganizationHelper {
  final String baseUrl = 'https://stuppnig.ddns.net';

  Future<bool> addUser(String email, String password) async {
    final encodedEmail = Uri.encodeComponent(email);
    final encodedPassword = Uri.encodeComponent(password);
    final String authToken = await AuthenticationHelper.getToken(true);
    try {
      print('$encodedEmail, $encodedPassword');
      print(authToken);
      final response = await http.post(
        Uri.parse(
            '$baseUrl/organization/adduser?email=$encodedEmail&secret=$encodedPassword'),
        headers: {
          'Authorization': 'Bearer $authToken',
          HttpHeaders.acceptHeader: '*/*',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        print('[Organization] User created: ${response.body}');
        return true;
      } else {
        print(
            '[Organization] Create User failed ${response.statusCode}, ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('[Organization] Timeout');
      return false;
    } on Exception catch (e) {
      print('[Organization] Fehler: $e');
      return false;
    }
  }
}
