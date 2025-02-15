import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:digitaler_notarzt/microphone_helper.dart';
import 'package:digitaler_notarzt/notifier/stream_notifier.dart';
import 'package:digitaler_notarzt/screens/login_screen.dart';
import 'package:digitaler_notarzt/screens/organization_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        ChangeNotifierProvider<AuthenticationHelper>(
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
    return MaterialApp.router(
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
      routerConfig: _createRouter(context),
    );
  }

  GoRouter _createRouter(BuildContext context) {
    return GoRouter(
      refreshListenable:
          Provider.of<AuthenticationHelper>(context, listen: true),
      redirect: (context, state) {
        final authHelper =
            Provider.of<AuthenticationHelper>(context, listen: false);
        final isLoggedIn = authHelper.isAuthenticated;
        final isOrganization = authHelper.isOrganization;

        final goingToLogin = state.matchedLocation == '/';

        if (!isLoggedIn && !goingToLogin) {
          return '/';
        }
        if (isLoggedIn && goingToLogin) {
          if (isOrganization) {
            return '/organization';
          } else {
            return '/chat';
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => ProfileScreen(),//LoginScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/organization',
          builder: (context, state) => OrganizationScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    );
  }
}
