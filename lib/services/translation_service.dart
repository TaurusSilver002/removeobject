import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();
  String _currentLanguage = 'en';
  
  // Cache to store translated texts to avoid repeated API calls
  final Map<String, Map<String, String>> _translationCache = {};
  
  // Supported languages by the translator package
  final Set<String> _supportedLanguages = {
    'en', 'es', 'fr', 'ar', 'de', 'zh', 'ja', 'ko', 'pt', 'hi', 'it', 'ru', 'nl'
  };

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('locale') ?? 'en';
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }

  String getCurrentLanguage() {
    return _currentLanguage;
  }

  /// Check if a language is supported for translation
  bool isLanguageSupported(String languageCode) {
    return _supportedLanguages.contains(languageCode);
  }

  /// Translate any text to the current language
  /// If already in English or current language, returns the original text
  Future<String> translate(String text) async {
    try {
      // If current language is English, return original text
      if (_currentLanguage == 'en') {
        return text;
      }

      // If language is not supported, return original text
      if (!isLanguageSupported(_currentLanguage)) {
        print('Language $_currentLanguage not supported, returning original text');
        return text;
      }

      // Check cache first
      if (_translationCache.containsKey(_currentLanguage) && 
          _translationCache[_currentLanguage]!.containsKey(text)) {
        return _translationCache[_currentLanguage]![text]!;
      }

      // Translate the text with timeout
      final translation = await _translator.translate(text, 
          from: 'en', to: _currentLanguage).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Translation timeout');
        },
      );
      
      // Store in cache
      _translationCache[_currentLanguage] ??= {};
      _translationCache[_currentLanguage]![text] = translation.text;
      
      return translation.text;
    } catch (e) {
      // If translation fails, return original text
      print('Translation failed for "$text" to $_currentLanguage: $e');
      return text;
    }
  }

  /// Translate multiple texts at once
  Future<List<String>> translateBatch(List<String> texts) async {
    if (_currentLanguage == 'en' || !isLanguageSupported(_currentLanguage)) {
      return texts;
    }

    final List<String> translatedTexts = [];
    
    for (String text in texts) {
      try {
        final translated = await translate(text);
        translatedTexts.add(translated);
      } catch (e) {
        // If individual translation fails, add original text
        translatedTexts.add(text);
      }
    }
    
    return translatedTexts;
  }

  /// Clear translation cache (useful when changing languages)
  void clearCache() {
    _translationCache.clear();
  }

  /// Get language name in its native script
  String getLanguageName(String languageCode) {
    final languageNames = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'ar': 'العربية',
      'de': 'Deutsch',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'pt': 'Português',
      'hi': 'हिन्दी',
      'it': 'Italiano',
    };
    return languageNames[languageCode] ?? languageCode;
  }

  /// Get all supported languages
  List<String> getSupportedLanguages() {
    return _supportedLanguages.toList();
  }
}
