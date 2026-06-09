// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../theme_colors.dart';
import 'team_achievements_screen.dart';

class SquadSettingsScreen extends StatefulWidget {
  const SquadSettingsScreen({super.key});

  @override
  State<SquadSettingsScreen> createState() => _SquadSettingsScreenState();
}

class _SquadSettingsScreenState extends State<SquadSettingsScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Shadow Runners',
  );
  final TextEditingController _descController = TextEditingController(
    text: 'Shaharni zabt etamiz!',
  );

  bool _isPublic = true;
  bool _allowJoinRequests = true;
  bool _notifyNewMember = true;
  bool _notifyAchievement = true;
  bool _notifyChallenge = false;

  static const List<Map<String, dynamic>> _members = [
    {'name': 'ShadowRunner', 'role': 'Sardor', 'isLeader': true},
    {'name': 'NovaPulse', 'role': "A'zo", 'isLeader': false},
    {'name': 'Vortex', 'role': "A'zo", 'isLeader': false},
    {'name': 'EchoStorm', 'role': "A'zo", 'isLeader': false},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: const Text(
          'SQUAD SETTINGS',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: AppColors.secondary),
            tooltip: 'Yutuqlar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TeamAchievementsScreen()),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Saqlash',
              style: TextStyle(
                color: AppColors.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Squad identity section
          _buildSquadIdentity(),
          const SizedBox(height: 16),

          // Privacy settings
          _buildSectionHeader('Maxfiylik sozlamalari', Icons.lock_outline),
          const SizedBox(height: 8),
          _buildPrivacySettings(),
          const SizedBox(height: 16),

          // Members
          _buildSectionHeader("A'zolar", Icons.people_outline),
          const SizedBox(height: 8),
          _buildMembersList(),
          const SizedBox(height: 16),

          // Notification settings
          _buildSectionHeader('Bildirishnomalar', Icons.notifications_outlined),
          const SizedBox(height: 8),
          _buildNotificationSettings(),
          const SizedBox(height: 24),

          // Danger zone
          _buildDangerZone(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSquadIdentity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Squad avatar
          Center(
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x4DFE6B00),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: _inputDecoration('Squad nomi', Icons.group),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: _inputDecoration('Tavsif', Icons.description_outlined),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      hintStyle: const TextStyle(color: AppColors.outline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.tertiary, width: 1.5),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _ToggleRow(
            title: 'Ochiq squad',
            subtitle: 'Har kim qo\'shila oladi',
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          _ToggleRow(
            title: 'Qo\'shilish so\'rovlari',
            subtitle: 'Yangi a\'zolar ruxsat so\'rashadi',
            value: _allowJoinRequests,
            onChanged: (v) => setState(() => _allowJoinRequests = v),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ..._members.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isLast = index == _members.length - 1;
            return Column(
              children: [
                _MemberRow(member: member),
                if (!isLast)
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
              ],
            );
          }),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add, color: AppColors.primary, size: 18),
            label: const Text(
              "A'zo qo'shish",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _ToggleRow(
            title: "Yangi a'zo",
            subtitle: "A'zo qo'shilganda xabar",
            value: _notifyNewMember,
            onChanged: (v) => setState(() => _notifyNewMember = v),
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          _ToggleRow(
            title: 'Yutuqlar',
            subtitle: 'Jamoaviy yutuqlar haqida',
            value: _notifyAchievement,
            onChanged: (v) => setState(() => _notifyAchievement = v),
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          _ToggleRow(
            title: 'Musobaqalar',
            subtitle: 'Yangi musobaqa boshlanganida',
            value: _notifyChallenge,
            onChanged: (v) => setState(() => _notifyChallenge = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorContainer.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xavfli zona',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _confirmDeleteSquad(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Squadni o\'chirish',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  void _confirmDeleteSquad(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text(
          'Squadni o\'chirish',
          style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Haqiqatan ham squadni o\'chirmoqchimisiz? Bu amalni qaytarib bo\'lmaydi.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              "O'chirish",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.tertiary,
            inactiveThumbColor: AppColors.outline,
            inactiveTrackColor: AppColors.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final Map<String, dynamic> member;
  const _MemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    final isLeader = member['isLeader'] as bool? ?? false;
    final name = member['name'] as String? ?? 'User';
    final role = member['role'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: isLeader ? AppColors.secondary : AppColors.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isLeader)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.outline, size: 20),
              color: AppColors.surfaceContainer,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'promote',
                  child: Text(
                    'Sardorlikka ko\'tarish',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    "O'chirish",
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
              onSelected: (_) {},
            ),
          if (isLeader)
            const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
        ],
      ),
    );
  }
}
