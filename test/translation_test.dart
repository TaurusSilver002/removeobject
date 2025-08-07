import 'package:flutter_test/flutter_test.dart';
import 'package:objectremove/services/app_translations.dart';

void main() {
  group('Translation Tests', () {
    test('AppTranslations initializes correctly', () async {
      await AppTranslations.initialize();
      expect(AppTranslations.getCurrentLanguage(), 'en');
    });

    test('Language setting works correctly', () async {
      await AppTranslations.initialize();
      await AppTranslations.setLanguage('es');
      expect(AppTranslations.getCurrentLanguage(), 'es');
    });

    test('Translation caching works', () {
      AppTranslations.addTranslation('Hello', 'Hola', 'es');
      final cached = AppTranslations.getCachedTranslation('Hello', 'es');
      expect(cached, 'Hola');
    });

    test('Cache clearing works', () {
      AppTranslations.addTranslation('Hello', 'Hola', 'es');
      AppTranslations.clearCache();
      final cached = AppTranslations.getCachedTranslation('Hello', 'es');
      expect(cached, null);
    });
  });
}
