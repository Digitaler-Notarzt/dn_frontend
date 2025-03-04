import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  TextEditingController codeController = TextEditingController();

  void _verifyCode() async{
    String code = codeController.text.trim();
    bool valide = await Provider.of<AuthenticationHelper>(listen: false, context).verfiyResetAuthCode(code);
    if (valide) {
      context.go('/resetpassword?email=${widget.email}&code=$code');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ungültiger Code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifizierungscode eingeben")),
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
                Text("Ein Code wurde an ${widget.email} gesendet."),
                const SizedBox(height: 20),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: "Verifizierungscode",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: const Text("Bestätigen"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
