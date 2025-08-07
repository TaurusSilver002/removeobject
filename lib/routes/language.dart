import 'package:flutter/material.dart';
import 'package:objectremove/services/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// List of supported locales
const supportedLocales = [
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
];

// Language data for display (only showing well-supported languages)
const languageData = [
  {'locale': Locale('en', ''), 'name': 'English', 'flag': '🇺🇸'},
  {'locale': Locale('es', ''), 'name': 'Spanish', 'flag': '🇪🇸'},
  {'locale': Locale('fr', ''), 'name': 'French', 'flag': '🇫🇷'},
  {'locale': Locale('ar', ''), 'name': 'Arabic', 'flag': '🇸🇦'}, // Arabic flag emoji
  // Commented out languages that may cause crashes
  // {'locale': Locale('de', ''), 'name': 'German', 'flag': '��'},
  // {'locale': Locale('zh', ''), 'name': 'Chinese', 'flag': '��'},
  // {'locale': Locale('ja', ''), 'name': 'Japanese', 'flag': '��'},
  // {'locale': Locale('ko', ''), 'name': 'Korean', 'flag': '��'},
  // {'locale': Locale('pt', ''), 'name': 'Portuguese', 'flag': '🇵🇹'},
  // {'locale': Locale('hi', ''), 'name': 'Hindi', 'flag': '🇮🇳'},
  // {'locale': Locale('it', ''), 'name': 'Italian', 'flag': '🇮🇹'},
];

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({Key? key, required this.onLocaleChanged}) : super(key: key);

  final Function(Locale) onLocaleChanged;

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  Locale _selectedLocale = const Locale('en', ''); // Default to English

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale') ?? 'en';
    setState(() {
      _selectedLocale = Locale(savedLocale, '');
    });
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: TranslatableText(
                'Language',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languageData.length,
                itemBuilder: (context, index) {
                  final lang = languageData[index];
                  final isSelected = _selectedLocale == lang['locale'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Material(
                      color: isSelected ? Colors.red.shade900.withOpacity(0.3) : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _selectedLocale = lang['locale'] as Locale;
                          });
                        },
                        child: ListTile(
                          leading: Text(
                            lang['flag'] as String,
                            style: const TextStyle(fontSize: 24),
                            textDirection: TextDirection.ltr, // Ensure flag emoji is LTR
                          ),
                          title: Text(
                            lang['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.redAccent : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.radio_button_checked, color: Colors.redAccent)
                              : const Icon(Icons.radio_button_unchecked, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.onLocaleChanged(_selectedLocale);
                    _saveLocale(_selectedLocale); // Save locale
                    Navigator.pop(context);
                  },
                  child: TranslatableText(
                    'Continue',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}