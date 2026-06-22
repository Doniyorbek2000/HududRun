import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'theme.dart';
import 'theme_colors.dart';

final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(MyApp(key: appKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = true;
  bool _isReady = false;
  bool _hasSeenOnboarding = false;
  Locale _locale = const Locale('uz');

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load locale first
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code') ?? 'uz';

    // Then initialize user
    final tokenAvailable = await _apiService.hasAccessToken();
    final seenOnboarding = await _storage.read(key: 'seenOnboarding') == 'true';

    if (tokenAvailable) {
      try {
        final user = await _apiService.fetchProfile();
        _user = user;
      } catch (_) {
        await _apiService.clearTokens();
      }
    }

    if (mounted) {
      setState(() {
        _locale = Locale(savedCode);
        _hasSeenOnboarding = seenOnboarding;
        _isLoading = false;
      });
    }
  }

  void setLocale(Locale locale) => setState(() => _locale = locale);

  void _handleReady() {
    setState(() {
      _isReady = true;
    });
  }

  Future<void> _finishOnboarding() async {
    await _storage.write(key: 'seenOnboarding', value: 'true');
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = true;
      });
    }
  }

  void _handleAuthenticated(User user) {
    setState(() {
      _user = user;
    });
  }

  Future<void> _handleLogout() async {
    await _apiService.clearTokens();
    if (mounted) {
      setState(() {
        _user = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HududRun',
      theme: HududRunTheme.dark,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: _isLoading
          ? const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : !_isReady
          ? SplashScreen(onReady: _handleReady)
          : (!_hasSeenOnboarding && _user == null)
          ? OnboardingScreen(onFinish: _finishOnboarding)
          : _user == null
          ? LoginScreen(
              apiService: _apiService,
              onAuthenticated: _handleAuthenticated,
            )
          : HomeScreen(
              apiService: _apiService,
              user: _user!,
              onLogout: _handleLogout,
            ),
    );
  }
}
