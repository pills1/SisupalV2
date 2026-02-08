import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/parent_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for WEB with manual options
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAHn3e3YIOH-TvQOL6HF-JTvwXXH97tBS4",
        authDomain: "sisupal-782d3.firebaseapp.com",
        projectId: "sisupal-782d3",
        storageBucket: "sisupal-782d3.firebasestorage.app",
        messagingSenderId: "213942877787",
        appId: "1:213942877787:web:814aadc8f8fd5e523a497e"
    ),
  );

  runApp(const SisuPalApp());
}

class SisuPalApp extends StatelessWidget {
  const SisuPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SisuPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
        home: const LoginScreen()
    );
  }
}