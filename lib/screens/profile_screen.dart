import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 20),
              Text(
                'Profil bearbeiten',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[600],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Angemeldet als: email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _showChangePasswordDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Theme.of(context).indicatorColor,
                ),
                child: const Text('Passwort ändern',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(context) {
    final TextEditingController _currentPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Passwort ändern"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Aktuelles Passwort',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Neues Passwort',
                  prefixIcon: const Icon(Icons.lock_reset),
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
                onPressed: () {
                  Provider.of<AuthenticationHelper>(context, listen: false).changePassword(_currentPasswordController.text, _newPasswordController.text);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Theme.of(context).indicatorColor,
                ),
                child: const Text('Passwort ändern',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}
