import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'student_dashboard.dart';
import 'parent_dashboard.dart';
import 'admin/admin_dashboard.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _loadingController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _shimmer;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();

    // Logo animation - bouncy entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    _logoRotate = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Content animations
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Loading bar
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Sequence the animations
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Step 1: Logo bounces in
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();

    // Step 2: Title and tagline slide in
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _contentController.forward();

    // Step 3: Loading bar starts
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _loadingController.forward();

    // Step 4: Navigate after loading completes
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already logged in — check role and navigate
      final authService = AuthService();
      final role = await authService.getUserRole(user.uid);
      if (!mounted) return;

      if (role == 'Admin') {
        Navigator.pushReplacement(
          context,
          _buildPageRoute(const AdminDashboard()),
        );
      } else if (role == 'Parent') {
        Navigator.pushReplacement(
          context,
          _buildPageRoute(const ParentDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          _buildPageRoute(const StudentDashboard()),
        );
      }
    } else {
      // Not logged in — go to login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        _buildPageRoute(const LoginScreen()),
      );
    }
  }

  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _loadingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Color(0xFF533483),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated floating particles
            ...List.generate(12, (index) => _buildParticle(index)),

            // Decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFf093fb).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotate.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFFf093fb)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: const Color(0xFFf093fb).withOpacity(0.3),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name with shimmer
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: const [
                                  Colors.white,
                                  Color(0xFFFFD700),
                                  Colors.white,
                                ],
                                stops: [
                                  (_shimmer.value - 0.3).clamp(0.0, 1.0),
                                  _shimmer.value.clamp(0.0, 1.0),
                                  (_shimmer.value + 0.3).clamp(0.0, 1.0),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'SisuPal',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  AnimatedBuilder(
                    animation: _taglineFade,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineFade.value,
                        child: child,
                      );
                    },
                    child: const Text(
                      'Learn. Play. Grow. 🌟',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white60,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading bar
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _loadingController.value > 0 ? 1.0 : 0.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: Column(
                            children: [
                              // Progress bar
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _loadingProgress.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFFf093fb),
                                            Color(0xFFFFD700),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667eea)
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getLoadingText(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Version text at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _taglineFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineFade.value * 0.5,
                    child: child,
                  );
                },
                child: const Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLoadingText() {
    final progress = _loadingProgress.value;
    if (progress < 0.3) return 'Preparing your adventure...';
    if (progress < 0.6) return 'Loading knowledge...';
    if (progress < 0.9) return 'Almost ready...';
    return 'Let\'s go! 🚀';
  }

  Widget _buildParticle(int index) {
    final random = Random(index * 42);
    final size = 4.0 + random.nextDouble() * 6;
    final startX = random.nextDouble();
    final startY = random.nextDouble();
    final speed = 0.5 + random.nextDouble() * 1.5;
    final opacity = 0.1 + random.nextDouble() * 0.25;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final screenW = MediaQuery.of(context).size.width;
        final screenH = MediaQuery.of(context).size.height;
        final t = (_particleController.value * speed) % 1.0;

        // Gentle floating upward motion
        final x = startX * screenW + sin(t * 2 * pi + index) * 30;
        final y = screenH * (1 - t) * startY + screenH * (1 - t) * 0.3;

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (index % 3 == 0
                      ? const Color(0xFF667eea)
                      : index % 3 == 1
                          ? const Color(0xFFf093fb)
                          : const Color(0xFFFFD700))
                  .withOpacity(opacity),
            ),
          ),
        );
      },
    );
  }
}
