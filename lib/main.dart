import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitaler Notarzt',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFEB2340),
              dynamicSchemeVariant: DynamicSchemeVariant.fidelity),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFEB2340),
              foregroundColor: Colors.white,
              elevation: 20,
              centerTitle: true),
              ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
