// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_data.dart';
import '../../theme_colors.dart';
import 'language_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;
  const SettingsScreen({super.key, required this.onLocaleChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _langCode = 'uz';
  bool _notifyTerritory = true;
  bool _notifyChallenge = true;
  bool _notifyFriends = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _langCode = prefs.getString('language_code') ?? 'uz';
      _notifyTerritory = prefs.getBool('notify_territory') ?? true;
      _notifyChallenge = prefs.getBool('notify_challenge') ?? true;
      _notifyFriends = prefs.getBool('notify_friends') ?? false;
    });
  }

  Future<void> _setNotify(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  String get _currentLangName {
    return kSupportedLanguages
        .firstWhere((l) => l.code == _langCode, orElse: () => kSupportedLanguages.first)
        .nativeName;
  }

  String get _currentLangFlag {
    return kSupportedLanguages
        .firstWhere((l) => l.code == _langCode, orElse: () => kSupportedLanguages.first)
        .flag;
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
          l10n.settings,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('TIL VA MINTAQA', Icons.language),
          const SizedBox(height: 8),
          _buildCard([
            _RowItem(
              icon: Icons.translate,
              title: l10n.language,
              trailing: '$_currentLangFlag $_currentLangName',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageScreen(
                      onLocaleChanged: (locale) {
                        setState(() => _langCode = locale.languageCode);
                        widget.onLocaleChanged(locale);
                      },
                    ),
                  ),
                );
                _loadPrefs();
              },
            ),
          ]),
          const SizedBox(height: 20),

          _sectionHeader('BILDIRISHNOMALAR', Icons.notifications_outlined),
          const SizedBox(height: 8),
          _buildCard([
            _SwitchItem(
              icon: Icons.map_outlined,
              title: 'Hudud yo\'qotildi',
              subtitle: 'Kimdir hududingizni olganda',
              value: _notifyTerritory,
              onChanged: (v) {
                setState(() => _notifyTerritory = v);
                _setNotify('notify_territory', v);
              },
            ),
            _Divider(),
            _SwitchItem(
              icon: Icons.emoji_events_outlined,
              title: 'Musobaqalar',
              subtitle: 'Yangi musobaqa boshlanganda',
              value: _notifyChallenge,
              onChanged: (v) {
                setState(() => _notifyChallenge = v);
                _setNotify('notify_challenge', v);
              },
            ),
            _Divider(),
            _SwitchItem(
              icon: Icons.people_outline,
              title: 'Do\'stlar',
              subtitle: 'Do\'stlar faoliyati haqida',
              value: _notifyFriends,
              onChanged: (v) {
                setState(() => _notifyFriends = v);
                _setNotify('notify_friends', v);
              },
            ),
          ]),
          const SizedBox(height: 20),

          _sectionHeader('ILOVA HAQIDA', Icons.info_outline),
          const SizedBox(height: 8),
          _buildCard([
            _RowItem(
              icon: Icons.verified_outlined,
              title: 'Versiya',
              trailing: '1.0.0',
              onTap: null,
            ),
            _Divider(),
            _RowItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Maxfiylik siyosati',
              onTap: () {},
            ),
            _Divider(),
            _RowItem(
              icon: Icons.description_outlined,
              title: 'Foydalanish shartlari',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.outline,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: children),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  const _RowItem({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.outline, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchItem({
    required this.icon,
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
          Icon(icon, color: AppColors.outline, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onSurface, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.white.withOpacity(0.05), height: 1);
}
