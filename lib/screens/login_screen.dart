import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:digitaler_notarzt/error_helper.dart';
import 'package:digitaler_notarzt/widgets/error_listener.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final AuthenticationHelper _authHelper = AuthenticationHelper();

  Future<void> _login({required bool isOrganization}) async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final orgName = _orgNameController.text;

    if (username.isEmpty ||
        password.isEmpty ||
        (isOrganization && orgName.isEmpty)) {
      ErrorNotifier().showError("Bitte alle Felder ausfüllen.");
      return;
    }

    bool success = await _authHelper.login(username, password);

    if (success) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      ErrorNotifier().showError(
          'Login fehlgeschlagen. Bitte überprüfen Sie Ihre Eingabe.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Anmeldung"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  "Standard Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(child: Text("Organisations Login", style: TextStyle(color: Colors.white),)),
            ],
          ),
        ),
        body: ErrorListener(
          child: TabBarView(
            children: [
              _buildLoginForm(isOrganization: false),
              _buildLoginForm(isOrganization: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({required bool isOrganization}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOrganization ? Icons.apartment : Icons.lock_outline,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              isOrganization ? 'Organisations-Login' : 'Willkommen!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOrganization
                  ? 'Bitte geben Sie Ihre Organisationsdaten ein.'
                  : 'Bitte einloggen um fortzufahren.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
            ),
            const SizedBox(height: 30),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8 > 400
                    ? 400
                    : MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                children: [
                  if (isOrganization) ...[
                    TextField(
                      controller: _orgNameController,
                      decoration: InputDecoration(
                        labelText: 'Organisationsname',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Passwort',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _login(isOrganization: isOrganization),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Theme.of(context).indicatorColor,
                    ),
                    child: const Text('Login',
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
