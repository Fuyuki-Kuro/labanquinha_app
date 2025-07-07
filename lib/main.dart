import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:labanquinha_app/screens/services/login.dart';
import 'package:labanquinha_app/screens/services/register.dart';
import 'package:labanquinha_app/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Banquinha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      
      initialRoute: '/login',
      
      routes: {
        '/login': (context) => const LoginScreen(), 
        '/register': (context) => const RegisterScreen(),
        // A rota '/home' agora aponta para a nossa MainScreen
        '/home': (context) => const MainScreen(), 
      },
    );
  }
}