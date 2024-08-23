import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digitaler Notarzt'),
        actions: [_buildPopupMenu(context),],
      ),
      body: Center(
        child: Text('Chat mit AI hier beginnen...'),
      ),
    );
    
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result){
        switch (result) {
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'logout':
            print('User pressed logout');
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Einstellungen'),
        ),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('Profil'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Abmelden'),
        ),
      ],
    );
  }
}