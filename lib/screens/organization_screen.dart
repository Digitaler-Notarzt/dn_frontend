import 'package:flutter/material.dart';

class OrganizationScreen extends StatefulWidget {
  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  final List<Map<String, dynamic>> _users = [
    {"email": "user1@example.com", "isActive": true},
    {"email": "user2@example.com", "isActive": false},
  ];

  void _addUser(String email, String password) {
    setState(() {
      _users.add({"email": email, "isActive": true});
    });
  }

  void _deleteUser(String email) {
    setState(() {
      _users.removeWhere((user) => user["email"] == email);
    });
  }

  void _toggleUserStatus(String email) {
    setState(() {
      for (var user in _users) {
        if (user["email"] == email) {
          user["isActive"] = !user["isActive"];
        }
      }
    });
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
                if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
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
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(user["email"]),
                      subtitle: Text(user["isActive"] ? "Aktiv" : "Inaktiv"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              user["isActive"] ? Icons.toggle_off : Icons.toggle_on,
                              color: user["isActive"] ? Colors.red : Colors.green,
                            ),
                            onPressed: () => _toggleUserStatus(user["email"]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user["email"]),
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
