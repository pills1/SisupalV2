import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp
    (options: const FirebaseOptions(
      apiKey: "AIzaSyAHn3e3YIOH-TvQOL6HF-JTvwXXH97tBS4",
      authDomain: "sisupal-782d3.firebaseapp.com",
      projectId: "sisupal-782d3",
      storageBucket: "sisupal-782d3.firebasestorage.app",
      messagingSenderId: "213942877787",
      appId: "1:213942877787:web:814aadc8f8fd5e523a497e"
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SisuPalApp(),
    ),
  );
}

class SisuPalApp extends StatelessWidget {
  const SisuPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'SisuPal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
