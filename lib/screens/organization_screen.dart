import 'package:digitaler_notarzt/organization_helper.dart';
import 'package:flutter/material.dart';

class OrganizationScreen extends StatefulWidget {
  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  final OrganizationHelper organizationHelper = OrganizationHelper();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await organizationHelper.getUsers();
      setState(() {
        _users = response.map<Map<String, dynamic>>((user) {
          return {
            "email": user["email"],
            "isActive": user["is_active"],
            "isVerified": user["is_verified"],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Fehler beim Laden der Benutzer";
        _isLoading = false;
      });
    }
  }

  void _addUser(String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    if (await organizationHelper.addUser(email, password)) {
      _fetchUsers();
    }
  }

  void _deleteUser(String email) async {
    setState(() {
      _isLoading = true;
    });
    // if (await organizationHelper.deleteUser(email)) {
    //   _fetchUsers();
    // }
  }

  void _toggleUserStatus(String email, bool isActive) async {
    // bool success = isActive
    //     ? await organizationHelper.deactivateUser(email)
    //     : await organizationHelper.activateUser(email);
    // if (success) {
    //   _fetchUsers();
    // }
  }

  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Benutzer hinzufügen"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "E-Mail",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Passwort",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  _addUser(emailController.text, passwordController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Hinzufügen"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Organisations-Management"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.person_add),
              label: const Text("Benutzer hinzufügen"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(user["email"]),
                                subtitle: Text(
                                  user["isActive"] ? "Aktiv" : "Inaktiv",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        user["isActive"]
                                            ? Icons.toggle_off
                                            : Icons.toggle_on,
                                        color: user["isActive"]
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      onPressed: () => _toggleUserStatus(
                                          user["email"], user["isActive"]),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteUser(user["email"]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
