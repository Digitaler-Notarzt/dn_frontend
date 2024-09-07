//import 'dart:convert';
//import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  String errorMessage = '';

  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  /*void login() async {
    final response = await http.post(
      Uri.parse('https://ip.com'),
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8';
      },
      body: jsonEncode(<String, String> {
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      //TODO: save token
      await storage.write(key: 'auth_token', value: token);

      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      setState(() {
        errorMessage = 'Login fehlgeschlagen. Überprüfe die eingegebenen Daten.';
      });
    }
  }*/

  void login() async {
    if(email == "test@test.com" && password == "test123") {
      await storage.write(key: 'auth_token', value: "Authenticated123");
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      setState(() {
        errorMessage = 'Login fehlgeschlagen. Überprüfe die eingegebenen Daten.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              decoration: const InputDecoration(labelText: 'Passwort'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
          ],
        ),
      ),
    );
  }
}
