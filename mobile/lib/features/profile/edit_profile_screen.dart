// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api_service.dart';
import '../../models/user.dart';
import '../../theme_colors.dart';
import '../../l10n/countries.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final ApiService apiService;
  final Function(Map<String, dynamic>) onUpdated;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.apiService,
    required this.onUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _regionCtrl;
  late TextEditingController _districtCtrl;
  String? _selectedCountry;
  String? _avatarBase64;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _bioCtrl = TextEditingController();
    _regionCtrl = TextEditingController(text: widget.user.region ?? '');
    _districtCtrl = TextEditingController(text: widget.user.district ?? '');
    _selectedCountry = null;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _regionCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (image == null) return;
    final bytes = await File(image.path).readAsBytes();
    final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    setState(() => _avatarBase64 = base64Str);
  }

  Future<void> _save() async {
    setState(() { _isSaving = true; _error = null; });
    try {
      final updates = <String, dynamic>{};
      if (_usernameCtrl.text.trim().isNotEmpty &&
          _usernameCtrl.text.trim() != widget.user.username) {
        updates['username'] = _usernameCtrl.text.trim();
      }
      if (_bioCtrl.text.trim().isNotEmpty) {
        updates['bio'] = _bioCtrl.text.trim();
      }
      if (_selectedCountry != null) {
        updates['country'] = _selectedCountry;
      }
      if (_regionCtrl.text.trim().isNotEmpty) {
        updates['region'] = _regionCtrl.text.trim();
      }
      if (_districtCtrl.text.trim().isNotEmpty) {
        updates['district'] = _districtCtrl.text.trim();
      }
      if (_avatarBase64 != null) {
        updates['avatar'] = _avatarBase64;
      }
      if (updates.isNotEmpty) {
        final result = await widget.apiService.updateProfile(updates);
        widget.onUpdated(result);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Xatolik yuz berdi. Qayta urinib ko\'ring.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
          'PROFILNI TAHRIRLASH',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.tertiary, strokeWidth: 2))
                : const Text('SAQLASH',
                    style: TextStyle(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w700,
                    )),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    backgroundImage: _avatarBase64 != null
                        ? MemoryImage(
                            base64Decode(_avatarBase64!.split(',').last))
                            as ImageProvider
                        : null,
                    child: _avatarBase64 == null
                        ? Text(
                            widget.user.username.isNotEmpty
                                ? widget.user.username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF053900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Rasmni o\'zgartirish uchun bosing',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const SizedBox(height: 28),
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
          _buildField(
            label: 'FOYDALANUVCHI NOMI',
            controller: _usernameCtrl,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'HAQIMDA',
            controller: _bioCtrl,
            icon: Icons.info_outline,
            maxLines: 3,
            hint: 'O\'zingiz haqingizda yozing...',
          ),
          const SizedBox(height: 16),
          // Country picker
          GestureDetector(
            onTap: _showCountryPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined,
                      color: AppColors.outline, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MAMLAKAT',
                          style: TextStyle(
                            color: AppColors.outline,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedCountry != null
                              ? '${countryFlag(_selectedCountry)} ${countryName(_selectedCountry)}'
                              : 'Mamlakatni tanlang',
                          style: TextStyle(
                            color: _selectedCountry != null
                                ? AppColors.onSurface
                                : AppColors.outline,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.outline, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(label: 'VILOYAT', controller: _regionCtrl, icon: Icons.location_city_outlined),
          const SizedBox(height: 16),
          _buildField(label: 'TUMAN', controller: _districtCtrl, icon: Icons.pin_drop_outlined),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.outline),
            prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.07)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.07)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountryPickerSheet(
        selected: _selectedCountry,
        onSelect: (code) {
          setState(() => _selectedCountry = code);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final String? selected;
  final Function(String) onSelect;
  const _CountryPickerSheet({required this.selected, required this.onSelect});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = kCountries
        .where((c) =>
            c.name.toLowerCase().contains(_query.toLowerCase()) ||
            c.code.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Mamlakat qidirish...',
              hintStyle: const TextStyle(color: AppColors.outline),
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final c = filtered[i];
              final isSelected = c.code == widget.selected;
              return ListTile(
                leading: Text(c.flag,
                    style: const TextStyle(fontSize: 24)),
                title: Text(c.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    )),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => widget.onSelect(c.code),
              );
            },
          ),
        ),
      ],
    );
  }
}
