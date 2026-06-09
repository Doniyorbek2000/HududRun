import 'dart:async';

import 'package:flutter/material.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF020812), Color(0xFF101D40)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 40,
              top: 120,
              child: _GlowCircle(
                size: 110,
                color: const Color.fromRGBO(68, 138, 255, 0.18),
              ),
            ),
            Positioned(
              right: 20,
              top: 80,
              child: _GlowCircle(
                size: 70,
                color: const Color.fromRGBO(171, 71, 188, 0.24),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.8, end: 1.05).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 52,
                      backgroundColor: Color(0xFF2B3B76),
                      child: Icon(Icons.explore, size: 48, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HududRun',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Territory run battle',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(
                    height: 6,
                    width: 120,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Color(0x33FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
