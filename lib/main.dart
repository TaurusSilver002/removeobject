import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:objectremove/routes/gallary.dart';
import 'package:objectremove/routes/onbording.dart';
import 'package:objectremove/routes/paywall.dart';
import 'package:objectremove/routes/privacypolicy.dart';
import 'package:objectremove/routes/setting.dart';
import 'package:objectremove/routes/splash.dart';
import 'package:objectremove/routes/terms.dart';
import 'package:objectremove/routes/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale') ?? 'en';
    setState(() {
      _locale = Locale(savedLocale, '');
    });
  }

  Future<void> _setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    
    // Save locale to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
        Locale('de', ''), // German
        Locale('zh', ''), // Chinese
        Locale('ja', ''), // Japanese
        Locale('ko', ''), // Korean
        Locale('ar', ''), // Arabic
        Locale('pt', ''), // Portuguese
        Locale('hi', ''), // Hindi
        Locale('it', ''), // Italian
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/paywall': (context) => const UnlockProScreen(),
        '/gallery': (context) =>  GalleryFromDevice(),
        '/settings': (context) => const SettingPage(),
        '/terms': (context) => const TermsPage(),
        '/privacy': (context) => const PrivacyPolicyPage(),
        '/language': (context) => LanguageSettingsPage(onLocaleChanged: _setLocale),
      },
    );
  }
}

