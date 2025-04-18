import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:digitaler_notarzt/microphone_helper.dart';
import 'package:digitaler_notarzt/notifier/stream_notifier.dart';
import 'package:digitaler_notarzt/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  //runApp(const MyApp());
  final microphonehelper = MicrophoneHelper();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationHelper>(
          create: (_) => AuthenticationHelper(),
        ),
        Provider<StreamNotifier>(
          create: (_) => StreamNotifier(microphoneHelper: microphonehelper),
        )
      ],
      child: const MyApp(),
    ),
  );
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
        '/': (context) => LoginScreen(),
        '/chat': (context) => const ChatScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
