class CountryData {
  final String code;
  final String name;
  final String flag;
  const CountryData({required this.code, required this.name, required this.flag});
}

const List<CountryData> kCountries = [
  CountryData(code: 'UZ', name: 'O\'zbekiston', flag: '🇺🇿'),
  CountryData(code: 'RU', name: 'Россия', flag: '🇷🇺'),
  CountryData(code: 'KZ', name: 'Қазақстан', flag: '🇰🇿'),
  CountryData(code: 'KG', name: 'Кыргызстан', flag: '🇰🇬'),
  CountryData(code: 'TJ', name: 'Тоҷикистон', flag: '🇹🇯'),
  CountryData(code: 'TM', name: 'Türkmenistan', flag: '🇹🇲'),
  CountryData(code: 'AZ', name: 'Azərbaycan', flag: '🇦🇿'),
  CountryData(code: 'TR', name: 'Türkiye', flag: '🇹🇷'),
  CountryData(code: 'AE', name: 'الإمارات', flag: '🇦🇪'),
  CountryData(code: 'SA', name: 'السعودية', flag: '🇸🇦'),
  CountryData(code: 'DE', name: 'Deutschland', flag: '🇩🇪'),
  CountryData(code: 'GB', name: 'United Kingdom', flag: '🇬🇧'),
  CountryData(code: 'US', name: 'United States', flag: '🇺🇸'),
  CountryData(code: 'CN', name: '中国', flag: '🇨🇳'),
  CountryData(code: 'KR', name: '한국', flag: '🇰🇷'),
  CountryData(code: 'JP', name: '日本', flag: '🇯🇵'),
  CountryData(code: 'FR', name: 'France', flag: '🇫🇷'),
  CountryData(code: 'IT', name: 'Italia', flag: '🇮🇹'),
  CountryData(code: 'ES', name: 'España', flag: '🇪🇸'),
  CountryData(code: 'PL', name: 'Polska', flag: '🇵🇱'),
  CountryData(code: 'UA', name: 'Україна', flag: '🇺🇦'),
  CountryData(code: 'BY', name: 'Беларусь', flag: '🇧🇾'),
  CountryData(code: 'AF', name: 'افغانستان', flag: '🇦🇫'),
  CountryData(code: 'PK', name: 'Pakistan', flag: '🇵🇰'),
  CountryData(code: 'IN', name: 'India', flag: '🇮🇳'),
  CountryData(code: 'ID', name: 'Indonesia', flag: '🇮🇩'),
  CountryData(code: 'MY', name: 'Malaysia', flag: '🇲🇾'),
  CountryData(code: 'BR', name: 'Brasil', flag: '🇧🇷'),
  CountryData(code: 'MX', name: 'México', flag: '🇲🇽'),
  CountryData(code: 'NG', name: 'Nigeria', flag: '🇳🇬'),
  CountryData(code: 'EG', name: 'مصر', flag: '🇪🇬'),
  CountryData(code: 'ZA', name: 'South Africa', flag: '🇿🇦'),
  CountryData(code: 'AU', name: 'Australia', flag: '🇦🇺'),
  CountryData(code: 'CA', name: 'Canada', flag: '🇨🇦'),
];

String countryFlag(String? code) {
  if (code == null) return '🌍';
  return kCountries.firstWhere(
    (c) => c.code == code,
    orElse: () => const CountryData(code: '', name: '', flag: '🌍'),
  ).flag;
}

String countryName(String? code) {
  if (code == null) return '';
  return kCountries.firstWhere(
    (c) => c.code == code,
    orElse: () => const CountryData(code: '', name: code, flag: ''),
  ).name;
}
