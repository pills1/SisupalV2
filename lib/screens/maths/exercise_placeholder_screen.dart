import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';

/// ============================================
/// EXERCISE PLACEHOLDER SCREEN (Sinhala Localized)
/// Reusable placeholder for future exercise engine integration.
/// ============================================
class ExercisePlaceholderScreen extends StatelessWidget {
  final String conceptId;
  final String conceptTitle;
  final String learningObjective;

  const ExercisePlaceholderScreen({
    super.key,
    required this.conceptId,
    required this.conceptTitle,
    required this.learningObjective,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.mathOrange,
        foregroundColor: Colors.white,
        title: const Text(
          'අභියෝගයට සූදානම්ද? ⚔️',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Challenge icon
              ScaleInWidget(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.glowShadow(AppColors.mathOrange),
                  ),
                  child: const Center(
                    child: Text(
                      '⚔️',
                      style: TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              SlideInWidget(
                child: const Text(
                  'අභියෝගයට සූදානම්ද? ⚔️',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.mathOrange,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Concept info card
              SlideInWidget(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.cardShadow,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ඔබ ඉගෙන ගත්තේ:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF636E72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        conceptTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        learningObjective,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.mathOrange.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.construction_rounded,
                                color: AppColors.mathOrange, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'අභියෝග ප්‍රශ්න ළඟදීම එකතු වේ!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Continue button — returns true to advance the story
              SlideInWidget(
                delay: const Duration(milliseconds: 400),
                beginOffset: const Offset(0, 0.5),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mathOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                    label: const Text(
                      'ගමන ඉදිරියට ගෙන යමු 🚀',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
