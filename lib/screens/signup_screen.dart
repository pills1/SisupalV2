import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 1. Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. State Variables
  String _selectedRole = 'Student';
  int _selectedGrade = 5;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, size: 60, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Join SisuPal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 30),

              // 1. Name Input
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['Student', 'Parent'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: InputDecoration(
                  labelText: 'I am a...',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Grade Dropdown (Only if Student)
              if (_selectedRole == 'Student')
                DropdownButtonFormField<int>(
                  value: _selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'Grade (Shreniya)',
                    prefixIcon: const Icon(Icons.class_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 3, child: Text("Grade 3")),
                    DropdownMenuItem(value: 4, child: Text("Grade 4")),
                    DropdownMenuItem(value: 5, child: Text("Grade 5 (Scholarship)")),
                  ],
                  onChanged: (value) => setState(() => _selectedGrade = value!),
                ),
              const SizedBox(height: 24),

              // 6. SIGN UP BUTTON
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  print("🔵 BUTTON CLICKED"); // Check Console for this!

                  FocusScope.of(context).unfocus(); // Hide keyboard

                  String name = _nameController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill in all fields")),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);

                  try {
                    User? user = await _authService.signUp(
                      email,
                      password,
                      name,
                      _selectedRole,
                      grade: _selectedGrade,
                    );

                    if (user != null) {
                      print("🟢 SIGNUP SUCCESS");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Account Created! Please Login.")),
                        );
                        Navigator.pop(context); // Go back to Login
                      }
                    } else {
                      print("🔴 SIGNUP FAILED (User null)");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sign Up Failed. Check console.")),
                        );
                      }
                    }
                  } catch (e) {
                    print("🔴 CRASH: $e");
                  }

                  if (mounted) setState(() => _isLoading = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}