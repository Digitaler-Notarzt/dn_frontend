import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modi Auswahl'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Row(
              children: [
                _buildModeCard(context, "Audio Modus",
                    "assets/images/logo.png", "Subtitle", () {
                  Navigator.pushNamed(context, '/mode1');
                }),
                const SizedBox(
                  width: 16,
                ),
                _buildModeCard(context, "Chat Modus", "assets/images/logo.png",
                    "Subtitle", () {
                  Navigator.pushNamed(context, '/mode2');
                })
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, String title, String imagePath,
      String description, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
