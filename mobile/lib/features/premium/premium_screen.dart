// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api_service.dart';
import '../../models/user.dart';
import '../../theme_colors.dart';

class PremiumScreen extends StatefulWidget {
  final ApiService apiService;
  final User user;
  final ValueChanged<Map<String, dynamic>>? onUpdated;

  const PremiumScreen({
    super.key,
    required this.apiService,
    required this.user,
    this.onUpdated,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  static const Map<String, int> _planPrices = {
    'monthly': 29000,
    'yearly': 249000,
  };

  String _selectedPlan = 'monthly';
  String _selectedProvider = 'payme';
  bool _isProcessing = false;
  String? _error;
  Timer? _pollTimer;
  late bool _isPremium;

  @override
  void initState() {
    super.initState();
    _isPremium = widget.user.isPremium;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String _formatPrice(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return "${buffer.toString()} so'm";
  }

  Future<void> _startCheckout() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      final result = await widget.apiService.createPayment(_selectedPlan, _selectedProvider);
      final payment = result['payment'] as Map<String, dynamic>?;
      final checkoutUrl = result['checkoutUrl'] as String?;
      final paymentId = payment?['id'] as String?;
      if (checkoutUrl == null || paymentId == null) {
        throw Exception('Invalid response');
      }

      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Could not open checkout');
      }

      _pollPaymentStatus(paymentId);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "To'lovni boshlashda xatolik yuz berdi.";
          _isProcessing = false;
        });
      }
    }
  }

  void _pollPaymentStatus(String paymentId) {
    var attempts = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      try {
        final status = await widget.apiService.checkPaymentStatus(paymentId);
        final state = status['status'] as String?;
        if (state == 'completed') {
          timer.cancel();
          await _onPaymentCompleted();
          return;
        }
        if (state == 'cancelled' || state == 'failed') {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _error = "To'lov bekor qilindi.";
            });
          }
          return;
        }
      } catch (_) {}

      if (attempts >= 40) {
        timer.cancel();
        if (mounted) setState(() => _isProcessing = false);
      }
    });
  }

  Future<void> _onPaymentCompleted() async {
    try {
      final user = await widget.apiService.fetchProfile();
      widget.onUpdated?.call({
        'isPremium': user.isPremium,
        'level': user.level,
        'xp': user.xp,
      });
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isPremium = true;
      _isProcessing = false;
    });
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text(
          'Tabriklaymiz!',
          style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Premium muvaffaqiyatli faollashtirildi.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tushunarli', style: TextStyle(color: AppColors.tertiary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          if (!_isPremium) ...[
            const Text(
              'Rejani tanlang',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildPlanSelector(),
            const SizedBox(height: 20),
            const Text(
              "To'lov usuli",
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildProviderSelector(),
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            _buildCheckoutButton(),
            const SizedBox(height: 28),
          ],
          const Text(
            'Premium imtiyozlar',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _RewardTile(
            title: '2x XP bonusi',
            subtitle: 'Har bir yugurish uchun ikki barobar tajriba ochkosi.',
            icon: Icons.whatshot,
            color: AppColors.secondary,
          ),
          const _RewardTile(
            title: 'Hudud qalqoni',
            subtitle: 'Hududlaringizni uzoqroq vaqt davomida himoya qiling.',
            icon: Icons.shield,
            color: AppColors.primary,
          ),
          const _RewardTile(
            title: 'Maxsus belgilar',
            subtitle: 'Profilingizda eksklyuziv premium nishonlari.',
            icon: Icons.workspace_premium,
            color: AppColors.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.conquestGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x4DFE6B00), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'HududRun Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isPremium
                ? 'Premium faol — barcha imtiyozlardan foydalaning!'
                : "Hududlaringizni ko'proq himoya qiling, tezroq rivojlaning.",
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          if (_isPremium) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Faol',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Row(
      children: [
        Expanded(
          child: _PlanCard(
            title: 'Oylik',
            price: _formatPrice(_planPrices['monthly']!),
            period: '/ oy',
            isSelected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlanCard(
            title: 'Yillik',
            price: _formatPrice(_planPrices['yearly']!),
            period: '/ yil',
            badge: '2 oy bepul',
            isSelected: _selectedPlan == 'yearly',
            onTap: () => setState(() => _selectedPlan = 'yearly'),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSelector() {
    return Row(
      children: [
        Expanded(
          child: _ProviderCard(
            label: 'Payme',
            color: const Color(0xFF00CDDB),
            isSelected: _selectedProvider == 'payme',
            onTap: () => setState(() => _selectedProvider = 'payme'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProviderCard(
            label: 'Click',
            color: const Color(0xFF0073C7),
            isSelected: _selectedProvider == 'click',
            onTap: () => setState(() => _selectedProvider = 'click'),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _startCheckout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.conquestGradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x4DFE6B00), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Center(
          child: _isProcessing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  "To'lovga o'tish",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : const Color(0xFF1E1E1E).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.07),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              period,
              style: const TextStyle(color: AppColors.outline, fontSize: 12),
            ),
            if (badge != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF1E1E1E).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.07),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _RewardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
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
