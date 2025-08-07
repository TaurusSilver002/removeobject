import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoTranslateText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslateText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  State<AutoTranslateText> createState() => _AutoTranslateTextState();
}

class _AutoTranslateTextState extends State<AutoTranslateText> {
  String _translatedText = '';
  bool _isLoading = true;
  String _currentLanguage = 'en';
  
  // Cache for translations to avoid repeated API calls
  static final Map<String, Map<String, String>> _cache = {};

  @override
  void initState() {
    super.initState();
    _initializeAndTranslate();
  }

  Future<void> _initializeAndTranslate() async {
    await _loadCurrentLanguage();
    await _translateText();
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('locale') ?? 'en';
  }

  Future<void> _translateText() async {
    // If current language is English, no translation needed
    if (_currentLanguage == 'en') {
      setState(() {
        _translatedText = widget.text;
        _isLoading = false;
      });
      return;
    }

    // Check cache first
    if (_cache.containsKey(_currentLanguage) && 
        _cache[_currentLanguage]!.containsKey(widget.text)) {
      setState(() {
        _translatedText = _cache[_currentLanguage]![widget.text]!;
        _isLoading = false;
      });
      return;
    }

    try {
      final translator = GoogleTranslator();
      final translation = await translator.translate(
        widget.text,
        from: 'en',
        to: _currentLanguage,
      );

      // Store in cache
      _cache[_currentLanguage] ??= {};
      _cache[_currentLanguage]![widget.text] = translation.text;

      if (mounted) {
        setState(() {
          _translatedText = translation.text;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If translation fails, use original text
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Text(
        widget.text, // Show original text while loading
        style: widget.style?.copyWith(color: widget.style?.color?.withOpacity(0.7)),
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    return Text(
      _translatedText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

// Extension to make it easier to use
extension AutoTranslate on String {
  Widget autoTranslate({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AutoTranslateText(
      this,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
