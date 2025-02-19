import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:digitaler_notarzt/error_helper.dart';
import 'package:digitaler_notarzt/widgets/error_listener.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login({required bool isOrganization}) async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final authHelper =
        Provider.of<AuthenticationHelper>(context, listen: false);
    bool success = false;
    if (username.isEmpty || password.isEmpty) {
      ErrorNotifier().showError("Bitte alle Felder ausfüllen.");
      return;
    }

    if (!EmailValidator.validate(username)) {
      ErrorNotifier().showError("Angegebene E-Mail ist ungültig.");
      return;
    }

    if (isOrganization) {
      success = await authHelper.organizationLogin(username, password);
    } else {
      success = await authHelper.userLogin(username, password);
    }

    if (success) {
      if (isOrganization) {
        context.go('/organization');
      } else {
        context.go('/chat');
      }
    } else {
      ErrorNotifier().showError(authHelper.lastError);
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[100],
            title: const Text("Passwort zurücksetzen"),
            content: TextField(
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
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      return;
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Abbrechen"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<AuthenticationHelper>(context, listen: false).requestPasswordReset(_usernameController.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Weiter"),
                  ),
                ],
              )
            ],
          );
        });

    final email = _usernameController.text;
    if (!EmailValidator.validate(email)) {
      ErrorNotifier().showError(
          "Angegebene E-Mail, zum Passwort zurücksetzen, ist ungültig.");
      return;
    }

    //TODO authHelper.resetPassword
    context.push('/verification?email=${Uri.encodeComponent(email)}');
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
              Tab(
                child: Text(
                  "Organisations Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
                  if (!isOrganization) ...[
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () => _resetPassword(context),
                          child: const Text("Passwort vergessen")),
                    ),
                  ],
                  SizedBox(height: isOrganization ? 20 : 5),
                  ElevatedButton(
                    onPressed: () => _login(isOrganization: isOrganization),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Theme.of(context).indicatorColor,
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
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
