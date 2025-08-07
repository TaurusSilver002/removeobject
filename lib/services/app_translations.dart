import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global translation manager that automatically translates text
/// No need to manually manage .arb files!
class AppTranslations {
  static String _currentLanguage = 'en';
  static final Map<String, Map<String, String>> _translations = {};
  static final ValueNotifier<String> _languageNotifier = ValueNotifier('en');
  
  /// Get the language notifier for widgets to listen to changes
  static ValueNotifier<String> get languageNotifier => _languageNotifier;
  
  /// Initialize the translation system
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('locale') ?? 'en';
    _languageNotifier.value = _currentLanguage;
  }
  
  /// Set the current language
  static Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    _languageNotifier.value = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
  }
  
  /// Get the current language
  static String getCurrentLanguage() => _currentLanguage;
  
  /// Add a translation to the cache
  static void addTranslation(String originalText, String translatedText, String languageCode) {
    _translations[languageCode] ??= {};
    _translations[languageCode]![originalText] = translatedText;
  }
  
  /// Get translation from cache
  static String? getCachedTranslation(String originalText, String languageCode) {
    return _translations[languageCode]?[originalText];
  }
  
  /// Clear all cached translations
  static void clearCache() {
    _translations.clear();
  }
}

/// Extension to make any String translatable
extension TranslatableString on String {
  /// Convert any string to a TranslatableText widget
  Widget tr({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
  }) {
    return TranslatableText(
      this,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Widget that automatically translates text based on current language
class TranslatableText extends StatefulWidget {
  final String originalText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const TranslatableText(
    this.originalText, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : super(key: key);

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  String _displayText = '';
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _updateText();
    // Listen to language changes
    AppTranslations.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppTranslations.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _updateText();
  }

  void _updateText() {
    final currentLang = AppTranslations.getCurrentLanguage();
    
    // If English, show original
    if (currentLang == 'en') {
      setState(() {
        _displayText = widget.originalText;
        _isTranslating = false;
      });
      return;
    }

    // Check cache first
    final cached = AppTranslations.getCachedTranslation(widget.originalText, currentLang);
    if (cached != null) {
      setState(() {
        _displayText = cached;
        _isTranslating = false;
      });
      return;
    }

    // Show original while translating
    setState(() {
      _displayText = widget.originalText;
      _isTranslating = true;
    });

    // Simulate translation (replace with actual API call)
    _translateText(currentLang);
  }

  Future<void> _translateText(String targetLanguage) async {
    try {
      // Here you would call your preferred translation API
      // For now, using a simple mapping for demo
      final translations = _getSimpleTranslations();
      
      final translationMap = translations[targetLanguage];
      final translated = translationMap?[widget.originalText] ?? widget.originalText;
      
      // Cache the translation
      AppTranslations.addTranslation(widget.originalText, translated, targetLanguage);
      
      if (mounted) {
        setState(() {
          _displayText = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      // If translation fails, keep original
      print('Translation error for "${widget.originalText}" to $targetLanguage: $e');
      if (mounted) {
        setState(() {
          _displayText = widget.originalText;
          _isTranslating = false;
        });
      }
    }
  }

  /// Simple translation mappings (replace with actual API)
  Map<String, Map<String, String>> _getSimpleTranslations() {
    return {
      'es': {
        'Settings': 'Configuraciones',
        'Language': 'Idioma',
        'Premium': 'Premium',
        'Continue': 'Continuar',
        'Gallery': 'Galería',
        'Camera': 'Cámara',
        'Edit': 'Editar',
        'Skip': 'Saltar',
        'Get Started': 'Comenzar',
        'Remove Object': 'Eliminar Objeto',
        'Photo Library': 'Biblioteca de Fotos',
        'Pick Image from Gallery': 'Seleccionar Imagen de Galería',
        'Other Setting': 'Otras Configuraciones',
        'Restore': 'Restaurar',
        'Rating': 'Calificación',
        'Share App': 'Compartir App',
        'Contact us': 'Contáctanos',
        'Privacy Policy': 'Política de Privacidad',
        'Terms and condition': 'Términos y condiciones',
        'Pro': 'Pro',
        'Upgrade now for unlimited High Quality Image': 'Actualiza ahora para imágenes ilimitadas de alta calidad',
        'Remove Unwanted\nObjects Instantly': 'Elimina Objetos\nNo Deseados Instantáneamente',
        'Just draw around anything you don\'t want in your photo—dobject will erase it cleanly and effortlessly using powerful AI.': 'Solo dibuja alrededor de cualquier cosa que no quieras en tu foto—dobject la borrará limpia y sin esfuerzo usando IA poderosa.',
        'Replace Objects\nwith Ease': 'Reemplaza Objetos\ncon Facilidad',
        'Select any object and swap it with something new—dobject makes intelligent replacements that blend naturally into your photo.': 'Selecciona cualquier objeto e intercámbialo por algo nuevo—dobject hace reemplazos inteligentes que se mezclan naturalmente en tu foto.',
        'Expand Your Image\nBeyond Borders': 'Expande tu Imagen\nMás Allá de las Fronteras',
        'Need more space? dobject uses AI to intelligently fill and extend your image—perfect for social posts, banners, or clean crops.': '¿Necesitas más espacio? dobject usa IA para llenar y extender inteligentemente tu imagen—perfecto para posts sociales, banners o recortes limpios.',
      },
      'fr': {
        'Settings': 'Paramètres',
        'Language': 'Langue',
        'Premium': 'Premium',
        'Continue': 'Continuer',
        'Gallery': 'Galerie',
        'Camera': 'Caméra',
        'Edit': 'Modifier',
        'Skip': 'Ignorer',
        'Get Started': 'Commencer',
        'Remove Object': 'Supprimer Objet',
        'Photo Library': 'Bibliothèque Photo',
        'Pick Image from Gallery': 'Choisir Image de la Galerie',
        'Other Setting': 'Autres Paramètres',
        'Restore': 'Restaurer',
        'Rating': 'Évaluation',
        'Share App': 'Partager App',
        'Contact us': 'Nous contacter',
        'Privacy Policy': 'Politique de Confidentialité',
        'Terms and condition': 'Termes et conditions',
        'Pro': 'Pro',
        'Upgrade now for unlimited High Quality Image': 'Mettez à niveau maintenant pour des images haute qualité illimitées',
        'Remove Unwanted\nObjects Instantly': 'Supprimez les Objets\nIndésirables Instantanément',
        'Just draw around anything you don\'t want in your photo—dobject will erase it cleanly and effortlessly using powerful AI.': 'Dessinez simplement autour de tout ce que vous ne voulez pas dans votre photo—dobject l\'effacera proprement et sans effort grâce à une IA puissante.',
        'Replace Objects\nwith Ease': 'Remplacez les Objets\navec Facilité',
        'Select any object and swap it with something new—dobject makes intelligent replacements that blend naturally into your photo.': 'Sélectionnez n\'importe quel objet et échangez-le contre quelque chose de nouveau—dobject fait des remplacements intelligents qui se fondent naturellement dans votre photo.',
        'Expand Your Image\nBeyond Borders': 'Étendez votre Image\nau-delà des Frontières',
        'Need more space? dobject uses AI to intelligently fill and extend your image—perfect for social posts, banners, or clean crops.': 'Besoin de plus d\'espace? dobject utilise l\'IA pour remplir et étendre intelligemment votre image—parfait pour les posts sociaux, bannières ou recadrages nets.',
      },
      'ar': {
        'Settings': 'الإعدادات',
        'Language': 'اللغة',
        'Premium': 'بريميوم',
        'Continue': 'متابعة',
        'Gallery': 'المعرض',
        'Camera': 'الكاميرا',
        'Edit': 'تحرير',
        'Skip': 'تخطي',
        'Get Started': 'البدء',
        'Remove Object': 'إزالة الكائن',
        'Photo Library': 'مكتبة الصور',
        'Pick Image from Gallery': 'اختيار صورة من المعرض',
        'Other Setting': 'إعدادات أخرى',
        'Restore': 'استعادة',
        'Rating': 'التقييم',
        'Share App': 'مشاركة التطبيق',
        'Contact us': 'اتصل بنا',
        'Privacy Policy': 'سياسة الخصوصية',
        'Terms and condition': 'الأحكام والشروط',
        'Pro': 'برو',
        'Upgrade now for unlimited High Quality Image': 'ترقية الآن للحصول على صور عالية الجودة غير محدودة',
        'Remove Unwanted\nObjects Instantly': 'إزالة الكائنات\nغير المرغوبة فوراً',
        'Just draw around anything you don\'t want in your photo—dobject will erase it cleanly and effortlessly using powerful AI.': 'ارسم حول أي شيء لا تريده في صورتك—dobject سيمحوه بنظافة وبدون مجهود باستخدام الذكاء الاصطناعي القوي.',
        'Replace Objects\nwith Ease': 'استبدال الكائنات\nبسهولة',
        'Select any object and swap it with something new—dobject makes intelligent replacements that blend naturally into your photo.': 'اختر أي كائن واستبدله بشيء جديد—dobject يقوم بعمليات استبدال ذكية تمتزج بشكل طبيعي في صورتك.',
        'Expand Your Image\nBeyond Borders': 'وسّع صورتك\nما وراء الحدود',
        'Need more space? dobject uses AI to intelligently fill and extend your image—perfect for social posts, banners, or clean crops.': 'تحتاج المزيد من المساحة؟ dobject يستخدم الذكاء الاصطناعي لملء وتوسيع صورتك بذكاء—مثالي للمنشورات الاجتماعية والشعارات أو القصاصات النظيفة.',
      },
      // For unsupported languages, we'll return original text
      'de': {}, // Empty map will cause fallback to original text
      'zh': {},
      'ja': {},
      'ko': {},
      'pt': {},
      'hi': {},
      'it': {},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: _isTranslating 
          ? widget.style?.copyWith(color: widget.style?.color?.withOpacity(0.8))
          : widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }
}
