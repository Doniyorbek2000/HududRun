// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme_colors.dart';
import '../../l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  final ApiService apiService;
  const NotificationsScreen({super.key, required this.apiService});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.apiService.fetchNotifications();
      if (mounted) setState(() { _notifications = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'territory_lost': return Icons.location_off_outlined;
      case 'level_up': return Icons.trending_up;
      case 'territory_captured': return Icons.flag_outlined;
      case 'challenge_won': return Icons.emoji_events_outlined;
      case 'friend_joined': return Icons.person_add_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'territory_lost': return AppColors.error;
      case 'level_up': return AppColors.tertiary;
      case 'territory_captured': return AppColors.secondary;
      case 'challenge_won': return const Color(0xFFFFD700);
      case 'friend_joined': return AppColors.primary;
      default: return AppColors.outline;
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m oldin';
    if (diff.inHours < 24) return '${diff.inHours}s oldin';
    return '${diff.inDays}k oldin';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                await widget.apiService.markAllNotificationsRead();
                setState(() {
                  _notifications = _notifications.map((n) => {...n, 'read': true}).toList();
                });
              },
              child: const Text(
                'Hammasini o\'qish',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmpty(l10n)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _buildItem(_notifications[i]),
                ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, color: AppColors.outline, size: 64),
          const SizedBox(height: 16),
          Text(
            l10n.noData,
            style: const TextStyle(color: AppColors.outline, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> n) {
    final type = n['type'] as String? ?? '';
    final read = n['read'] as bool? ?? false;
    final color = _colorFor(type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: read
            ? const Color(0xFF1E1E1E).withOpacity(0.4)
            : const Color(0xFF1E1E1E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: read ? Colors.white.withOpacity(0.05) : color.withOpacity(0.3),
          width: read ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(type), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['message'] as String? ?? '',
                  style: TextStyle(
                    color: read ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: read ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(n['createdAt'] as String?),
                  style: const TextStyle(color: AppColors.outline, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!read)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
