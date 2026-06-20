import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Resilient Firebase initialization that doesn't crash the application
  // if option credentials are placeholder/empty values.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    debugPrint('The app will run in demo/offline preview mode for testing.');
  }

  runApp(const SpaceNewsApp());
}

class SpaceNewsApp extends StatelessWidget {
  const SpaceNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E5FF),
        scaffoldBackgroundColor: const Color(0xFF070B19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF151D3B),
          error: Colors.redAccent,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white),
          bodyLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF070B19),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF070B19),
          selectedItemColor: Color(0xFF00E5FF),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
