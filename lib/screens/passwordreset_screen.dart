import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:digitaler_notarzt/authentication_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String codeValue;

  const ResetPasswordScreen({Key? key, required this.email, required this.codeValue}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    codeController.text = widget.codeValue;
  }

  void _resetPassword() async {
    String email = emailController.text.trim();
    String code = codeController.text.trim();
    String newPassword = newPasswordController.text.trim();

    bool success = await Provider.of<AuthenticationHelper>(listen: false, context)
        .resetPassword(email, code, newPassword);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwort erfolgreich zurückgesetzt!")),
      );
      context.go('/login'); // Weiterleitung zum Login-Screen nach erfolgreicher Änderung
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fehler beim Zurücksetzen des Passworts")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Passwort zurücksetzen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8 > 400
                  ? 400
                  : MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "E-Mail",
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // E-Mail soll nicht geändert werden
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: "Bestätigungscode",
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // Code soll nicht geändert werden
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: "Neues Passwort",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text("Passwort ändern"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
