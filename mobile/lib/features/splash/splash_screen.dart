import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onReady;

  const SplashScreen({super.key, required this.onReady});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    Timer(const Duration(milliseconds: 1800), widget.onReady);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            left: 40,
            top: 120,
            child: _GlowCircle(
              size: 110,
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
          Positioned(
            right: 20,
            top: 80,
            child: _GlowCircle(
              size: 70,
              color: AppColors.secondary.withOpacity(0.15),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 100,
            child: _GlowCircle(
              size: 90,
              color: AppColors.tertiary.withOpacity(0.08),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 0.85, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: AppColors.conquestGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFE6B00).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.directions_run, size: 52, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'HududRun',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.onSurface,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yugur. Egalla. Hukmronlik qil.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  height: 4,
                  width: 120,
                  child: LinearProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    backgroundColor: AppColors.surfaceContainerHigh,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 32, spreadRadius: 16)],
      ),
    );
  }
}
