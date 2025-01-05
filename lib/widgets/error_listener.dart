import 'package:flutter/material.dart';
import 'package:digitaler_notarzt/error_helper.dart';

class ErrorListener extends StatelessWidget {
  final Widget child;

  ErrorListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ErrorNotifier().errorMessageNotifier,
      builder: (context, errorMessage, _) {
        if (errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Fehler', textAlign: TextAlign.center,),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () {
                        ErrorNotifier().clearError();
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          });
        }
        return child;
      },
    );
  }
}
