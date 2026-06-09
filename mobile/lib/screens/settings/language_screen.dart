// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_data.dart';
import '../../theme_colors.dart';

class LanguageScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;
  const LanguageScreen({super.key, required this.onLocaleChanged});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedCode = 'uz';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedCode = prefs.getString('language_code') ?? 'uz');
  }

  Future<void> _select(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    setState(() => _selectedCode = code);
    widget.onLocaleChanged(Locale(code));
    if (mounted) Navigator.pop(context);
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
          l10n.language,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kSupportedLanguages.length,
        itemBuilder: (context, index) {
          final lang = kSupportedLanguages[index];
          final isSelected = _selectedCode == lang.code;
          return GestureDetector(
            onTap: () => _select(lang.code),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : const Color(0xFF1E1E1E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.white.withOpacity(0.07),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      lang.nativeName,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
