import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:sisupal/screens/parent_dashboard.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import 'admin/admin_dashboard.dart';
import 'signup_screen.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated mascot
                      FloatingWidget(
                        offset: 10,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Lottie.network(
                              'https://assets2.lottiefiles.com/packages/lf20_OT15QW.json',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) {
                                return const Icon(Icons.school_rounded, size: 60, color: Color(0xFF667eea));
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // App title with glow
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: const Text(
                          'SisuPal',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Text(
                        'Learn. Play. Grow.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Glassmorphism login card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Input
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password Input
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Login Button
                            BouncingButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login_rounded, color: Colors.white),
                                            SizedBox(width: 8),
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    User? user = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      String? role = await _authService.getUserRole(user.uid);
      if (mounted) {
        if (role == 'Admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
        } else if (role == 'Parent') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ParentDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StudentDashboard()));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text("Login Failed. Check your credentials."),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset, color: Color(0xFF667eea)),
            ),
            const SizedBox(width: 12),
            const Text("Reset Password"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email. We will send you a link to reset your password."),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await _authService.sendPasswordResetEmail(email);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Reset link sent! Check your email."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Send Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}