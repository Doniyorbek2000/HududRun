class LanguageData {
  final String code;
  final String nativeName;
  final String flag;
  const LanguageData({required this.code, required this.nativeName, required this.flag});
}

const List<LanguageData> kSupportedLanguages = [
  LanguageData(code: 'uz', nativeName: 'O\'zbek', flag: '🇺🇿'),
  LanguageData(code: 'ru', nativeName: 'Русский', flag: '🇷🇺'),
  LanguageData(code: 'en', nativeName: 'English', flag: '🇬🇧'),
  LanguageData(code: 'kk', nativeName: 'Қазақша', flag: '🇰🇿'),
  LanguageData(code: 'ky', nativeName: 'Кыргызча', flag: '🇰🇬'),
  LanguageData(code: 'de', nativeName: 'Deutsch', flag: '🇩🇪'),
  LanguageData(code: 'ar', nativeName: 'العربية', flag: '🇦🇪'),
  LanguageData(code: 'tr', nativeName: 'Türkçe', flag: '🇹🇷'),
  LanguageData(code: 'zh', nativeName: '中文', flag: '🇨🇳'),
  LanguageData(code: 'tg', nativeName: 'Тоҷикӣ', flag: '🇹🇯'),
];
