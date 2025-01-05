import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopupMenu extends StatelessWidget {
  final void Function() dismissKeyboard;

  const PopupMenu({Key? key, required this.dismissKeyboard}) : super(key: key);

  void _onMenuSelected(BuildContext context, String result) async {
    switch (result) {
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'profile':
        Navigator.pushNamed(context, '/profile');
        break;
      case 'logout':
        print('clicked logout');
        final authHelper =
            Provider.of<AuthenticationHelper>(context, listen: false);
        await authHelper.logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        break;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        dismissKeyboard();
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
