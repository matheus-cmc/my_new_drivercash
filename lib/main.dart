import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drivercash/firebase_options.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriverCash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Color(0xFF111111),
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black87,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white30),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: WelcomeScreen(), // Splash animada com texto
    );
  }
}
