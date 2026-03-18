import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // Make sure this points to your file containing MainNavigationScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _logoOffset = 20.0;
  double _textOffset = 40.0; // Starting position for text (lower than logo)

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
            _logoOffset = 0.0;
            _textOffset = 0.0;
          });
        }
      });
    });

    // Navigation logic (stays the same)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const MotivationHome(),
            transitionsBuilder:
                (context, a1, a2, child) =>
                    FadeTransition(opacity: a1, child: child),
            transitionDuration: const Duration(milliseconds: 1400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. LOGO ANIMATION
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, _logoOffset, 0),
                child: _buildLogo(),
              ),
            ),

            const SizedBox(height: 30),

            // 2. TEXT ANIMATION (Slides from bottom)
            AnimatedOpacity(
              opacity: _opacity,
              // Slightly longer duration for the text to feel smoother
              duration: const Duration(milliseconds: 1500),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutBack, // Gives a slight "bounce" at the end
                transform: Matrix4.translationValues(0, _textOffset, 0),
                child: Column(
                  children: [
                    Text(
                      'AuraFrame',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crafted by Bhadri Prabhu K',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to keep build method clean
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          '../assets/logo/app_logo.jpg',
          width: 80,
          height: 80,
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.layers_rounded,
                size: 80,
                color: Colors.teal,
              ),
        ),
      ),
    );
  }
}
