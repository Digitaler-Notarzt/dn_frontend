import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  const PopupMenu({Key? key}) : super(key: key);

  void _onMenuSelected(BuildContext context, String result) {
    switch(result) {
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'profile':
        Navigator.pushNamed(context, '/profile');
        break;
      case 'logout':
        print('User pressed logout');
        break;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        _onMenuSelected(context, result);
      },
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'settings',
          child: Text('Einstellungen'),
        ),
        PopupMenuItem<String>(
          value: 'profile',
          child: Text('Profil'),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Text('Abmelden'),
        ),
      ],
    );
  }
}
