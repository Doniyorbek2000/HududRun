// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../home/home_screen.dart';
import '../../../theme.dart';

class VictoryScreen extends StatefulWidget {
  final double conqueredAreaKm2;
  final double totalTerritoryKm2;
  final int pointsEarned;

  const VictoryScreen({
    super.key,
    required this.conqueredAreaKm2,
    required this.totalTerritoryKm2,
    required this.pointsEarned,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _slideController;
  late Animation<double> _floatAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.totalTerritoryKm2 / 20).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: HududRunTheme.background,
      body: Stack(
        children: [
          // Background animated rays
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) => CustomPaint(
                painter: _VictoryRaysPainter(_floatController.value),
              ),
            ),
          ),
          // Vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    HududRunTheme.background.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    ),
                    child: AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HududRunTheme.secondaryContainer
                                  .withOpacity(0.15 * _glowAnim.value),
                            ),
                          ),
                          Icon(
                            Icons.emoji_events,
                            size: 100,
                            color: HududRunTheme.secondary,
                            shadows: [
                              Shadow(
                                color: HududRunTheme.secondary.withOpacity(
                                    0.6 * _glowAnim.value),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  ScaleTransition(
                    scale: _slideAnim,
                    child: Column(
                      children: [
                        const Text(
                          "G'ALABA!",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFD700),
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Color(0x80FFD700),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yangi hudud egallandi!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: HududRunTheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Stats card
                  SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.3), end: Offset.zero)
                        .animate(_slideAnim),
                    child: FadeTransition(
                      opacity: _slideAnim,
                      child: _GlassCard(
                        child: Column(
                          children: [
                            _StatRow(
                              label: 'EGALLANGAN HUDUD',
                              value:
                                  '${widget.conqueredAreaKm2.toStringAsFixed(1)} km²',
                            ),
                            Divider(
                              color: Colors.white.withOpacity(0.05),
                              height: 20,
                            ),
                            _StatRow(
                              label: 'JAMI HUDUD',
                              value:
                                  '${widget.totalTerritoryKm2.toStringAsFixed(1)} km²',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'RANK PROGRESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: HududRunTheme.outlineVariant,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  '+${widget.pointsEarned} XP',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: HududRunTheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: HududRunTheme.surfaceVariant,
                                valueColor: const AlwaysStoppedAnimation(
                                  HududRunTheme.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // CTA
                  SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.5), end: Offset.zero)
                        .animate(_slideAnim),
                    child: FadeTransition(
                      opacity: _slideAnim,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: HududRunTheme.tertiary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: HududRunTheme.tertiary.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'DAVOM ETISH',
                                style: TextStyle(
                                  color: Color(0xFF053900),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right,
                                  color: Color(0xFF053900), size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: HududRunTheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: HududRunTheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _VictoryRaysPainter extends CustomPainter {
  final double t;
  _VictoryRaysPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD700).withOpacity(0.04);

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2 + t * math.pi * 2;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(
          cx + math.cos(angle - 0.15) * size.longestSide,
          cy + math.sin(angle - 0.15) * size.longestSide,
        )
        ..lineTo(
          cx + math.cos(angle + 0.15) * size.longestSide,
          cy + math.sin(angle + 0.15) * size.longestSide,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_VictoryRaysPainter old) => old.t != t;
}
