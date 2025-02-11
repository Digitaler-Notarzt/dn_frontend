import 'dart:async';
import 'dart:convert';
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

  ///Method to receive all Users as a list
  Future<List<dynamic>> getUsers() async {
    final String authToken = await AuthenticationHelper.getToken(true);
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/organization/list-users'), headers: {
        'Authorization': 'Bearer $authToken',
        HttpHeaders.acceptHeader: 'application/json',
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["details"]["users"];
      } else if (response.statusCode == 401) {
        throw Exception(json.decode(response.body));
      }
    } on TimeoutException {
      print("[Organization] Timeout");
    } on Exception catch (e) {
      print("[Organization] Error: $e");
    }
    throw Exception("Fehler beim Laden der Benutzer");
  }

  Future<bool> deleteUser(String email) async {
    final String authToken = await AuthenticationHelper.getToken(true);
    final encodedEmail = Uri.encodeComponent(email);
    try {
      final response = await http.delete(
          Uri.parse(
              '$baseUrl/organization/deleteuser?user_email=$encodedEmail'),
          headers: {
            'Authorization': 'Bearer $authToken',
            HttpHeaders.acceptHeader: 'application/json',
          }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return true;
      }
    } on TimeoutException {
      print("[Organization] Timeout");
    } on Exception catch (e) {
      print("[Organization] Error: $e");
    }
    return false;
  }

  Future<bool> activateUser(String email) async {
    final String authToken = await AuthenticationHelper.getToken(true);
    final encodedEmail = Uri.encodeComponent(email);
    try {
      final response = await http.post(
          Uri.parse(
              '$baseUrl/organization/activateuser?user_email=$encodedEmail'),
          headers: {
            'Authorization': 'Bearer $authToken',
            HttpHeaders.acceptHeader: 'application/json',
          }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return true;
      } else {
        print('[Organization] ${json.decode(response.body)["detail"]}');
        return false;
      }
    } on TimeoutException {
      print("[Organization] Timeout");
    } on Exception catch (e) {
      print("[Organization] Error: $e");
    }
    return false;
  }

  Future<bool> deactivateUser(String email) async {
    final String authToken = await AuthenticationHelper.getToken(true);
    final encodedEmail = Uri.encodeComponent(email);
    try {
      final response = await http.post(
          Uri.parse(
              '$baseUrl/organization/deactivateuser?user_email=$encodedEmail'),
          headers: {
            'Authorization': 'Bearer $authToken',
            HttpHeaders.acceptHeader: 'application/json',
          }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return true;
      }
    } on TimeoutException {
      print("[Organization] Timeout");
    } on Exception catch (e) {
      print("[Organization] Error: $e");
    }
    return false;
  }
}
