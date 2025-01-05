import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:digitaler_notarzt/error_helper.dart';
import 'package:digitaler_notarzt/widgets/error_listener.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationHelper _authHelper = AuthenticationHelper();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if(username.isEmpty || password.isEmpty) {
      ErrorNotifier().showError("Bitte E-Mail und Passwort eingeben.");
      return;
    }

    bool success = await _authHelper.login(username, password);

    if (success) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      ErrorNotifier().showError('Login fehlgeschlagen. Bitte überprüfen Sie ihre Eingabe.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ErrorListener(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Passwort'),
                obscureText: true,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
